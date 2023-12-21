from abc import ABCMeta
from dataclasses import astuple, dataclass
from functools import total_ordering
from typing import Generic, Self, Type, TypeVar, final


@dataclass(order=True, frozen=True, slots=True)
class RefPoint(metaclass=ABCMeta):
    @classmethod
    def parse(cls, ref: str) -> Self:
        return cls(*(int(x) for x in ref.split(".")))

    def __iter__(self):
        yield from astuple(self)

    def __str__(self) -> str:
        return ".".join(str(x) for x in self if x is not None)

    # def __contains__(self, ref: object) -> bool:
    #     if not isinstance(ref, RefPoint):
    #         raise TypeError(f"Cannot check if {ref} is in {self}")
    #     for a, b in zip(self, ref):
    #         if a is None and b is not None:
    #             return True
    #         if a != b:
    #             return False
    #     return True


T = TypeVar("T", bound=RefPoint)


@total_ordering
@dataclass(frozen=True, slots=True)
class Ref(Generic[T]):
    a: T
    b: T | None = None

    # def __post_init__(self) -> None:
    #     assert self.start <= self.end, f"got {self.start} - {self.end}"

    @property
    def start(self) -> T:
        return self.a

    @property
    def end(self) -> T:
        return self.b or self.a

    @property
    def is_range(self) -> bool:
        return self.b is not None

    def __lt__(self, other: "Ref[T]") -> bool:
        return self.a < other.a

    def __str__(self) -> str:
        return f"{self.start}-{self.end}" if self.is_range else str(self.a)

    @staticmethod
    def parse(ref_cls: Type[T], string: str) -> "Ref[T]":
        if "-" in string:
            start, end = string.split("-")
            return Ref(ref_cls.parse(start), ref_cls.parse(end))
        else:
            return Ref(ref_cls.parse(string))


@final
@dataclass(order=True, frozen=True, slots=True)
class BCV(RefPoint):
    book: int
    chapter: int | None = None
    verse: int | None = None


@final
@dataclass(order=True, frozen=True, slots=True)
class CV(RefPoint):
    chapter: int
    verse: int | None = None


@final
@dataclass(order=True, frozen=True, slots=True)
class Line(RefPoint):
    line: int
