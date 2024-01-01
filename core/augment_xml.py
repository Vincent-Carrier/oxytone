from functools import singledispatch
from typing import Any, Iterator, NamedTuple, cast
from core.ref import Ref
from core.render import FT
from core.treebank.perseus import PerseusTB
from lxml.builder import E
from lxml import etree
from lxml.etree import _Element as Element

from core.word import Word


@singledispatch
def render(obj) -> Any:
    ...


@render.register(Word)
def _(word: Word) -> Any:
    data = dict(
        id=str(word.id),
        head=str(word.head),
        lemma=word.lemma,
        flags=word.flags,
        case=str(word.case),
        pos=str(word.pos),
        role=word.role,
        definition=word.definition,
    )
    return E.word(word.form, **{k: v for k, v in data.items() if v is not None})


@render.register(Ref)
def _(ref: Ref) -> Any:
    return E.ref(start=ref.start, end=ref.end)


class Milestone(NamedTuple):
    line: int
    speaker: str


class AugmentedXmlRenderer(NamedTuple):
    tb: PerseusTB
    canonical: Element

    def get_milestones(self) -> Iterator[Milestone]:
        ns = {"tei": "http://www.tei-c.org/ns/1.0"}
        body = self.canonical.find(".//tei:text/tei:body", namespaces=ns)
        assert body is not None
        milestones = body.findall(".//tei:milestone", namespaces=ns)
        for m in milestones:
            line = m.attrib.get("n")
            if line is None:
                continue
            speaker = m.find("../tei:sp/tei:speaker", namespaces=ns)
            if speaker is None:
                continue
            yield Milestone(int(line), speaker.text)  # type: ignore

    def body(self):
        is_verse = self.tb.is_verse
        body = []
        sentence = []
        milestones = {n: spk for n, spk in self.get_milestones()}
        for t in iter(self.tb):
            match t:
                case Word() | Ref():
                    el = render(t)
                    sentence.append(el)
                case FT.SPACE:
                    sentence += " "
                case FT.SENTENCE_END:
                    body.append(E.sentence(*sentence))
                    sentence = []
                case int(n):  # verse line numbers
                    if n in milestones:
                        body.append(E.speaker(milestones[n]))
                    sentence.append(E.line(str(n)))
                case None:
                    pass
                case _:
                    pass
        return E.body(*body)

    def render(self) -> str:
        return etree.tostring(self.body(), encoding="unicode", pretty_print=True)