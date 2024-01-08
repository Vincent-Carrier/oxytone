from importlib import import_module
from itertools import pairwise
import re
from pathlib import Path
import shelve
from typing import (
    Iterator,
    Type,
    cast,
    final,
)

from lxml import etree
from pyCTS import CTS_URN

from core.constants import LEFT_PUNCT, LSJ, RIGHT_PUNCT
from core.ref import Ref, T
from core.render import FT, Token
from core.treebank.chunker import Chunker
from core.treebank.treebank import Sentence, Treebank
from core.utils import safelist
from core.word import POS, Case, Word


@final
class PerseusTB(Treebank[T]):
    is_verse: bool
    ref_cls: Type[T]
    chunker: "Chunker | None"
    filepath: Path

    def __init__(
        self,
        f: Path,
        **meta,
    ) -> None:
        super().__init__(**meta)
        self.filepath = f
        self.is_verse = self.meta.is_verse
        self.ref_cls = self.meta.ref_cls
        for _, el in etree.iterparse(f, events=("start",)):
            if el.tag == "treebank" and (urn := el.attrib.get("cts")):
                self.meta.urn = str(urn)
                if urn is not None:
                    break
            if el.tag == "sentence":
                self.meta.urn = el.attrib.get("document_id")
                break
        if chunker := meta.get("chunker"):
            self.chunker = getattr(import_module("core.treebank.chunker"), chunker)

    def sentences(self) -> Iterator[Sentence]:
        tree = etree.parse(self.filepath)
        root = tree.getroot()
        body = body if (body := root.find(".//body")) is not None else root
        yield from body.findall("./sentence")

    def chunks(self) -> Iterator[list[Sentence]]:
        if self.chunker is None:
            raise ValueError("called .chunks() without chunker")
        return self.chunker.chunks(self)

    def __iter__(self) -> Iterator[Token]:
        return self._iter_verse() if self.is_verse else self._iter_prose()

    def _iter_prose(self) -> Iterator[Token]:
        prev_ref: Ref | None = None
        for sentence in self.sentences():
            if self.ref_cls:
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
            if self.ref_cls:
                prev_ref = sentence_ref  # type: ignore
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
        tags = safelist(flags := attr.get("postag"))
        lemma = re.sub(r"\d+$", "", s) if (s := attr.get("lemma")) else None
        ref = None
        cite = attr.get("cite")
        if cite:
            first = cite.split(" ")[0]
            urn = CTS_URN(first)
            ref_str = cast(str, urn.passage_component)
            if self.ref_cls:
                try:
                    ref = Ref(self.ref_cls.parse(ref_str))
                except ValueError:
                    ...
        return Word(
            id=int(n) if (n := attr.get("id")) else None,
            head=int(n) if (n := attr.get("head")) else None,
            form=attr["form"],
            lemma=lemma,
            pos=POS.parse_agldt(tags.get(0)),
            case=Case.parse_agldt(tags.get(7)),
            flags=flags,
            role=attr.get("relation"),
            definition=lsj.get(lemma) if lemma else None,
            ref=ref,
        )


lsj = shelve.open(str(LSJ), "r")
