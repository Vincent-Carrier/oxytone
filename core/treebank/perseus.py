import re
from pathlib import Path
import shelve
from typing import (
    Callable,
    Iterator,
    NamedTuple,
    Protocol,
    Type,
    Unpack,
    cast,
    final,
    TypeAlias,
)

from lxml import etree
from more_itertools import split_when

# from pyCTS import CTS_URN

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
    chunker: "Chunker"
    # refs: list[Ref] = []

    def __init__(
        self,
        f: Path,
        ref_cls: Type[T],
        chunker: "Chunker",
        gorman: bool = False,
        **meta: Unpack[Metadata],
    ) -> None:
        super().__init__(ref_cls=ref_cls, **meta)
        self.gorman = gorman
        self.chunker = chunker or whole_chunk
        tree = etree.parse(f)
        root = tree.getroot()
        if gorman:
            self.body = root
        else:
            self.body = cast(etree._Element, root.find(".//body"))

    def sentences(self) -> Iterator[Sentence]:
        yield from self.body.findall("./sentence")

    def chunks(self) -> Iterator[list[Sentence]]:
        return self.chunker(self)

    def __iter__(self) -> Iterator[Token]:
        prev_ref: Ref | None = None
        prev_form: str = ""
        for sentence in self.sentences():
            yield FT.SENTENCE_START
            for el in sentence.findall("./word"):
                word = self.word(el.attrib)
                # TODO: yield paragraph tokens
                if word:
                    if word.ref and word.ref > prev_ref:
                        # if self.meta.writing_style == "prose":
                        #     yield FT.LINE_BREAK
                        prev_ref = word.ref
                    if prev_form and (prev_form not in PUNCTUATION):
                        yield FT.SPACE
                    prev_form = word.form
                    yield word
            yield FT.SENTENCE_END

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
        # cite = attr.get("cite")
        # if cite:
        #     first = cite.split(" ")[0]
        #     urn = CTS_URN(first)
        #     ref_str = cast(str, urn.passage_component)
        #     ref = Ref(self.ref_cls.parse(ref_str))
        return Word(
            id=parse_int(attr.get("id")),
            head=parse_int(attr.get("head")),
            form=attr["form"],
            lemma=lemma,
            pos=pos,
            case=case,
            flags=tags,
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
