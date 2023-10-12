from abc import ABCMeta, abstractmethod
from dataclasses import dataclass
from pathlib import Path
from typing import (Generic, Iterator, Literal, NamedTuple, Optional, Protocol,
                    Self, Type)

from slugify import slugify

from core.constants import BUILD
from core.ref import Ref, T
from core.token import FT, Token
from core.word import Word

WritingStyle = Literal["prose", "verse"]


@dataclass(slots=True, frozen=True)
class Metadata:
    lang: str
    title: str
    author: str | None = None
    ref: str | None = None
    urn: str | bytes | None = None
    eng_urn: str | bytes | None = None
    writing_style: WritingStyle = "prose"

    @property
    def authorship(self) -> str:
        return self.author or "unknown"

    @property
    def slug(self) -> str:
        return slugify(self.title)

    @property
    def partial_path(self) -> Path:
        folder = BUILD / self.lang / slugify(self.authorship)
        if self.ref:
            return folder / self.slug / f"{self.ref}.html"
        else:
            return folder / self.slug / "index.html"


class Treebank(Generic[T], metaclass=ABCMeta):
    meta: Metadata
    ref_cls: Type[T]
    ref: Ref | None = None
    chunker: "Chunker"

    def __init__(
        self,
        meta: Metadata,
        ref_cls: Type[T],
        chunker: Optional["Chunker"] = None,
    ) -> None:
        self.meta = meta
        self.ref_cls = ref_cls
        self.chunker = chunker or WholeChunker(self)
        self.chunker.tb = self # type: ignore

    def chunks(self) -> Iterator["Treebank"]:
        return self.chunker()

    @abstractmethod
    def __getitem__(self, ref: Ref | str) -> Self:
        ...

    @abstractmethod
    def __contains__(self, ref: Ref) -> bool:
        ...

    @abstractmethod
    def __iter__(self) -> Iterator[Token]:
        ...

    def __str__(self) -> str:
        def render(t: Token) -> str:
            match t:
                case Word() as word:
                    return str(word)
                case FT.SPACE:
                    return " "
                case FT.LINE_BREAK | FT.PARAGRAPH_END:
                    return "\n"
                case _:
                    return ""

        return "".join(render(t) for t in iter(self))

    def __repr__(self) -> str:
        return f"<{self.__class__.__name__} title='{self.meta.title}' ref={self.ref}>"

    def parse_ref(self, ref: str) -> Ref[T]:
        return Ref.parse(self.ref_cls, ref)


class Chunker(Protocol):
    def __call__(self) -> Iterator[Treebank]:
        ...


class WholeChunker(NamedTuple):
    tb: Treebank

    def __call__(self) -> Iterator[Treebank]:
        return iter([self.tb])


class BookChunker():
    tb: Treebank
    n: int

    def __init__(self, n: int) -> None:
        self.n = n

    def __call__(self) -> Iterator[Treebank]:
        for i in range(self.n):
            ref = str(i+1)
            yield self.tb[ref]
