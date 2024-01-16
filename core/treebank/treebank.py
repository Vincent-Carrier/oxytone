from abc import ABCMeta, abstractmethod
from typing import (
    TYPE_CHECKING,
    Any,
    Generic,
    Iterator,
    Type,
    TypeAlias,
)
from box import Box

from lxml import etree

from core.ref import Ref, T
from core.treebank.chunker import Chunker

if TYPE_CHECKING:
    from core.render import Token

Sentence: TypeAlias = etree._Element


class Treebank(Generic[T], metaclass=ABCMeta):
    meta: Box
    lang: str
    slug: str
    is_verse: bool
    title: str
    original_title: str
    author: str
    genre: str
    span: str
    ref: str
    urn: str | None
    eng_urn: str
    # chunker: Type[Chunker]
    ref_cls: Type[T] | None

    def __init__(
        self,
        **meta,
    ) -> None:
        self.meta = Box(meta)

    def __getattr__(self, __name: str) -> Any:
        if attr := self.meta.get(__name):
            return attr

    @abstractmethod
    def __iter__(self) -> Iterator["Token"]:
        ...

    def parse_ref(self, ref: str | bytes) -> Ref[T]:
        return Ref.parse(str(ref), self.ref_cls)
