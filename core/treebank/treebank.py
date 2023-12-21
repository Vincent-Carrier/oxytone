from abc import ABCMeta, abstractmethod
from typing import (
    Generic,
    Iterator,
    Literal,
    NotRequired,
    Optional,
    Protocol,
    Type,
    TypeAlias,
    TypedDict,
    Unpack,
)

from lxml import etree

from core.ref import Ref, T
from core.token import FT, Token
from core.word import Word

WritingStyle = Literal["prose", "verse"]
Sentence: TypeAlias = etree._Element


class Metadata(TypedDict):
    lang: str
    title: str
    author: NotRequired[str]
    ref: NotRequired[str]
    urn: NotRequired[str | bytes]
    eng_urn: NotRequired[str | bytes]
    # writing_style: WritingStyle

    # @property
    # def authorship(self) -> str:
    #     return self.author or "unknown"

    # @property
    # def slug(self) -> str:
    #     return slugify(self.title)

    # @property
    # def partial_path(self) -> Path:
    #     folder = BUILD / self.lang / slugify(self.authorship)
    #     if self.ref:
    #         return folder / self.slug / f"{self.ref}.html"
    #     else:
    #         return folder / self.slug / "index.html"


class Treebank(Generic[T], metaclass=ABCMeta):
    meta: Metadata = {"lang": "ag", "title": ""}
    ref_cls: Type[T]
    # ref: Ref | None = None

    def __init__(
        self,
        ref_cls: Type[T],
        **meta: Unpack[Metadata],
    ) -> None:
        self.meta = meta
        self.ref_cls = ref_cls

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

    # def __repr__(self) -> str:
    #     return (
    #         f"<{self.__class__.__name__} title='{self.meta['title']}' ref={self.ref}>"
    #     )

    def parse_ref(self, ref: str | bytes) -> Ref[T]:
        return Ref.parse(self.ref_cls, str(ref))
