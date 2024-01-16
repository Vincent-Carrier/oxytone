from functools import singledispatch
from typing import Any, Iterator, NamedTuple, cast
from core.ref import Ref
from core.render import FT
from core.treebank.perseus import PerseusTB
from lxml.builder import E
from lxml import etree
from lxml.etree import _Element as Element
from core.utils import filter_none

from core.word import Word


@singledispatch
def render(obj) -> Any:
    ...


@render.register(Word)
def _(w: Word) -> Any:
    return E.word(
        w.form,
        **filter_none(
            id=str(w.id),
            head=str(w.head),
            lemma=w.lemma,
            flags=w.flags,
            case=str(w.case),
            pos=str(w.pos),
            role=w.role,
            definition=w.definition,
        ),
    )


@render.register(Ref)
def _(ref: Ref) -> Any:
    return E.ref(start=ref.start, end=ref.end)


class Milestone(NamedTuple):
    line: int
    speaker: str


class TreebankAugmenter(NamedTuple):
    tb: PerseusTB
    canonical: Element

    def get_milestones(self) -> Iterator[Milestone]:
        ns = cast(dict[str, str], {None: "http://www.tei-c.org/ns/1.0"})
        kwargs = {"namespaces": ns}
        body = self.canonical.find(".//text/body", **kwargs)
        assert body is not None
        for m in body.findall(".//milestone", **kwargs):
            line = m.attrib.get("n")
            if line is None:
                continue
            speaker = (next := m.getnext()) and next.find(".//speaker", **kwargs)
            if speaker is None:
                continue
            yield Milestone(int(line), speaker.text)  # type: ignore

    def body(self):
        is_verse = self.tb.is_verse
        body = []
        sentence = []
        milestones = {n: spk for n, spk in self.get_milestones()}
        print(self.tb.meta.slug, len(milestones))
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
