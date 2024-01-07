from abc import ABCMeta, abstractmethod
from typing import (
    TYPE_CHECKING,
    Generic,
    Iterator,
    NotRequired,
    Type,
    TypeAlias,
    TypedDict,
)
from box import Box

from lxml import etree

from core.ref import Ref, T

if TYPE_CHECKING:
    from core.render import Token

Sentence: TypeAlias = etree._Element


class Metadata(TypedDict):
    lang: str
    slug: str
    title: str
    original_title: str
    author: NotRequired[str]
    genre: NotRequired[str]
    chunker: NotRequired[str]
    span: NotRequired[str]
    ref: NotRequired[str]
    urn: NotRequired[str | None]
    eng_urn: NotRequired[str]


class Treebank(Generic[T], metaclass=ABCMeta):
    meta: Box
    ref_cls: Type[T] | None

    def __init__(
        self,
        **meta,
    ) -> None:
        self.meta = Box(meta)

    @abstractmethod
    def __iter__(self) -> Iterator["Token"]:
        ...

    def parse_ref(self, ref: str | bytes) -> Ref[T]:
        return Ref.parse(str(ref), self.ref_cls)
