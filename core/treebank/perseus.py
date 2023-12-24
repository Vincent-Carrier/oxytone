from importlib import import_module
import re
from pathlib import Path
import shelve
from typing import (
    Callable,
    Iterator,
    Self,
    Type,
    Unpack,
    cast,
    final,
    TypeAlias,
)

from lxml import etree
from more_itertools import first, split_when

from pyCTS import CTS_URN

from core.constants import LSJ, PUNCTUATION
from core.ref import CV, Ref, T
from core.token import FT, Token
from core.treebank.treebank import Metadata, Sentence, Treebank
from core.utils import at, parse_int
from core.word import POS, Case, Word


@final
class PerseusTB(Treebank[T]):
    body: etree._Element
    gorman: bool
    is_verse: bool
    chunker: "Chunker"

    def __init__(
        self,
        f: Path,
        ref_cls: Type[T],
        chunker: "Chunker",
        is_verse,
        gorman: bool = False,
        **meta: Unpack[Metadata],
    ) -> None:
        super().__init__(ref_cls=ref_cls, **meta)
        self.gorman = gorman
        self.chunker = chunker
        self.is_verse = is_verse
        tree = etree.parse(f)
        root = tree.getroot()
        if gorman or (self.chunker is None):
            self.body = root
        else:
            self.body = cast(etree._Element, root.find(".//body"))
        if self.ref_cls is None:
            self.ref_cls = getattr(
                import_module("core.ref"), str(self.body.attrib["refcls"])
            )
        if self.is_verse is None:
            self.is_verse = self.body.attrib["isverse"] == "True"

    @classmethod
    def from_chunk(cls, f: Path) -> Self:
        ...

    @classmethod
    def from_agldt(cls, f: Path) -> Self:
        ...

    def sentences(self) -> Iterator[Sentence]:
        yield from self.body.findall("./sentence")

    def chunks(self) -> Iterator[list[Sentence]]:
        return self.chunker(self)

    def __iter__(self) -> Iterator[Token]:
        prev: Word | None = None
        prev_ref: Ref | None = None
        first_word = self.word(next(self.sentences()).find("./word").attrib)
        yield first_word.ref.start.verse  # type: ignore
        print(first_word.ref.start.verse)
        for sentence in self.sentences():
            for el in sentence.findall("./word"):
                word = self.word(el.attrib)
                # TODO: yield paragraph tokens
                if word:
                    if prev and word.form not in PUNCTUATION:
                        yield FT.SPACE
                    if self.is_verse and word.ref and prev_ref and word.ref > prev_ref:
                        yield FT.LINE_BREAK
                        yield prev_ref.start.verse + 1
                    yield word
                    prev = word
                    if word.ref:
                        prev_ref = word.ref
            yield FT.SENTENCE_END
            yield FT.SENTENCE_START

    def normalize_urn(self, urn: str | bytes) -> str:
        return re.search(r"^(urn:cts:greekLit:tlg\d{4}.tlg\d{3}).*", str(urn)).group(1)  # type: ignore

    def word(self, attr) -> Word | None:
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


Chunker: TypeAlias = Callable[[PerseusTB], Iterator[list[Sentence]]]


def whole_chunk(tb: PerseusTB) -> Iterator[list[Sentence]]:
    yield list(tb.sentences())


def chapter_chunks(tb: PerseusTB) -> Iterator[list[Sentence]]:
    def same_chapter(a: Sentence, b: Sentence):
        a_ref, b_ref = (tb.parse_ref(x.attrib["subdoc"]).start.chapter for x in (a, b))
        return a_ref != b_ref

    return split_when(tb.sentences(), same_chapter)


lsj = shelve.open(str(LSJ), "r")
