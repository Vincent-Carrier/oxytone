from abc import ABCMeta, abstractmethod
from typing import TYPE_CHECKING, Any, Generic, Iterator, Type, TypeAlias

from box import Box
from lxml import etree

from core.ref import Ref, T

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
    ref_cls: Type[T] | None

    def __init__(
        self,
        **kwargs,
    ) -> None:
        self.meta = Box(kwargs)

    def __getattr__(self, __name: str) -> Any | None:
        return attr if (attr := self.meta.get(__name)) else None

    @abstractmethod
    def __iter__(self) -> Iterator["Token"]:
        ...

    def parse_ref(self, ref: str | bytes) -> Ref[T]:
        return Ref.parse(str(ref), self.ref_cls)
