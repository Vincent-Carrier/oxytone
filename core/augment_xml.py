from typing import Iterator, NamedTuple, cast
from core.treebank.perseus import PerseusTB
from lxml.builder import E
from lxml import etree
from lxml.etree import _Element as Element


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
            speaker = n.find(".//speaker", **kwargs) if (n := m.getnext()) else None
            if speaker is None:
                continue
            yield Milestone(line, speaker.text)  # type: ignore

    def body(self):
        body = []
        words = []
        milestones = {n: spk for n, spk in self.get_milestones()}
        print("\tmilestones:", len(milestones))
        for sentence in self.tb.sentences():
            subdoc = sentence.attrib.get("subdoc")
            if subdoc and (ref := self.tb.parse_ref(subdoc)):
                if (n := str(ref.start)) in milestones:
                    body.append(E.speaker(milestones.pop(n)))
            for w in sentence.iterchildren():
                words.append(w)
            body.append(E.sentence(*words, **sentence.attrib))  # type: ignore
            words = []
        return E.body(*body)

    def render(self) -> str:
        return etree.tostring(self.body(), encoding="unicode", pretty_print=True)
