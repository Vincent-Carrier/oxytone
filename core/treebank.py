from abc import ABCMeta, abstractmethod
from dataclasses import dataclass
from typing import (
    Generic,
    Iterator,
    Literal,
    NamedTuple,
    Optional,
    Protocol,
    Self,
    Type,
)

from core.ref import Ref, T
from core.token import FT, Token
from core.word import Word

Format = Literal["prose", "verse"]


@dataclass(slots=True)
class Metadata:
    title: str | None = None
    author: str | None = None
    lang: str | None = None
    urn: str | bytes | None = None
    eng_urn: str | bytes | None = None
    format: Format = "prose"


class Treebank(Generic[T], metaclass=ABCMeta):
    meta: Metadata
    ref_cls: Type[T]
    ref: Ref | None = None
    chunker: "Chunker"

    def __init__(
        self,
        ref_cls: Type[T],
        chunker: Optional["Chunker"] = None,
        metadata: Metadata = Metadata(),
    ) -> None:
        self.meta = metadata
        self.ref_cls = ref_cls
        self.chunker = chunker or WholeChunker(self)

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
