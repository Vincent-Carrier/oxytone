from abc import ABCMeta, abstractmethod
from typing import (
    TYPE_CHECKING,
    Generic,
    Iterator,
    NotRequired,
    Type,
    TypeAlias,
    TypedDict,
    Unpack,
)

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
    ref: NotRequired[str]
    urn: NotRequired[str | bytes]
    eng_urn: NotRequired[str | bytes]


class Treebank(Generic[T], metaclass=ABCMeta):
    meta: Metadata
    ref_cls: Type[T]

    def __init__(
        self,
        ref_cls: Type[T],
        **meta: Unpack[Metadata],
    ) -> None:
        self.meta = meta
        self.ref_cls = ref_cls

    @abstractmethod
    def __iter__(self) -> Iterator["Token"]:
        ...

    def parse_ref(self, ref: str | bytes) -> Ref[T]:
        return Ref.parse(str(ref), self.ref_cls)
