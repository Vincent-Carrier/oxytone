from importlib import import_module
from itertools import pairwise
import re
from pathlib import Path
import shelve
from typing import (
    Iterator,
    Type,
    Unpack,
    cast,
    final,
)

from lxml import etree

from pyCTS import CTS_URN

from core.constants import LEFT_PUNCT, LSJ, RIGHT_PUNCT
from core.ref import Ref, T
from core.render import FT, Token
from core.treebank.chunker import Chunker
from core.treebank.treebank import Metadata, Sentence, Treebank
from core.utils import at, parse_int
from core.word import POS, Case, Word


@final
class PerseusTB(Treebank[T]):
    filepath: Path
    body: etree._Element
    gorman: bool
    is_verse: bool
    chunker: "Chunker | None"

    def __init__(
        self,
        f: Path,
        ref_cls: Type[T],
        is_verse: bool,
        chunker=None,
        gorman=False,
        **meta: Unpack[Metadata],
    ) -> None:
        super().__init__(ref_cls=ref_cls, **meta)
        self.filepath = f
        self.gorman = gorman
        self.chunker = chunker
        self.is_verse = is_verse
        tree = etree.parse(f)
        root = tree.getroot()
        self.body = root if gorman else cast(etree._Element, root.find(".//body"))
        self.ref_cls = self.ref_cls or getattr(
            import_module("core.ref"), str(root.attrib["refcls"])
        )
        self.is_verse = self.is_verse
        if self.is_verse is None:
            self.is_verse = root.attrib["isverse"] == "True"

    def sentences(self) -> Iterator[Sentence]:
        yield from self.body.findall("./sentence")

    def chunks(self) -> Iterator[list[Sentence]]:
        if self.chunker is None:
            raise ValueError("called .chunks() without chunker")
        return self.chunker.chunks(self)

    def __iter__(self) -> Iterator[Token]:
        return self._iter_verse() if self.is_verse else self._iter_prose()

    def _iter_prose(self) -> Iterator[Token]:
        prev_ref: Ref | None = None
        for sentence in self.sentences():
            sentence_ref = self.parse_ref(sentence.attrib["subdoc"])
            if sentence_ref > prev_ref:
                yield sentence_ref
            for word, next in pairwise(sentence.findall("./word")):
                w, n = (self.word(el) for el in (word, next))
                if not w:
                    continue
                yield w
                if n and n.form not in RIGHT_PUNCT and w.form not in LEFT_PUNCT:
                    yield FT.SPACE
            prev_ref = sentence_ref
            yield FT.SENTENCE_END

    def _iter_verse(self) -> Iterator[Token]:
        prev_ref: Ref | None = None
        yield 1
        for sentence in self.sentences():
            for word, next in pairwise(sentence.findall("./word")):
                w, n = (self.word(el) for el in (word, next))
                if not w:
                    continue
                if w.ref and prev_ref and w.ref > prev_ref:
                    yield FT.LINE_BREAK
                    yield prev_ref.start.verse + 1
                yield w
                if n and n.form not in RIGHT_PUNCT and w.form not in LEFT_PUNCT:
                    yield FT.SPACE
                prev_ref = w.ref or prev_ref
            yield FT.SENTENCE_END

    def word(self, el) -> Word | None:
        if el is None:
            return None
        attr = el.attrib
        if attr.get("insertion_id") is not None:  # TODO
            return None
        tags = attr.get("postag")
        pos = POS.parse_agldt(at(tags, 0))
        case = Case.parse_agldt(at(tags, 7))
        lemma = attr.get("lemma")
        if lemma:
            lemma = re.sub(r"\d+$", "", lemma)
        ref = None
        cite = attr.get("cite")
        if cite:
            first = cite.split(" ")[0]
            urn = CTS_URN(first)
            ref_str = cast(str, urn.passage_component)
            ref = Ref(self.ref_cls.parse(ref_str))
        return Word(
            id=parse_int(attr.get("id")),
            head=parse_int(attr.get("head")),
            form=attr["form"],
            lemma=lemma,
            pos=pos,
            case=case,
            flags=tags,
            role=attr.get("relation"),
            definition=lsj.get(lemma) if lemma else None,
            ref=ref,
        )


lsj = shelve.open(str(LSJ), "r")
