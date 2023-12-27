from typing import Iterator, Protocol

from more_itertools import split_when
from core.ref import Ref

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from core.treebank.perseus import PerseusTB
    from core.treebank.treebank import Sentence


class Chunker(Protocol):
    @staticmethod
    def chunks(tb: "PerseusTB") -> Iterator[list["Sentence"]]:
        ...

    @staticmethod
    def label(ref: Ref) -> str:
        ...

    @staticmethod
    def short_label(ref: Ref) -> str:
        ...


class ChapterChunker:
    @staticmethod
    def chunks(tb: "PerseusTB") -> Iterator[list["Sentence"]]:
        def same_chapter(a: "Sentence", b: "Sentence"):
            a_ref, b_ref = (
                tb.parse_ref(x.attrib["subdoc"]).start.chapter for x in (a, b)
            )
            return a_ref != b_ref

        return split_when(tb.sentences(), same_chapter)

    @staticmethod
    def short_label(ref: Ref) -> str:
        return ref.start.chapter

    @staticmethod
    def label(chunk: str) -> str:
        return f"Book {chunk}"
