from abc import ABCMeta
from copy import deepcopy
import copy
from dataclasses import astuple, dataclass
from functools import total_ordering
import re
from typing import Generic, Self, Type, TypeVar, final

from core.utils import safelist


@dataclass(order=True, frozen=True, slots=True)
class RefPoint(metaclass=ABCMeta):
    @classmethod
    def parse(cls, s: str) -> Self:
        try:
            parts = safelist(re.split(r"([a-z])$", s))
            return cls(*(int(n) for n in parts[0].split(".")), letter=parts.get(1, ""))  # type: ignore
        except:
            raise ValueError(f"Unable to parse {s} as {cls}")

    def __iter__(self):
        yield from astuple(self)

    def __str__(self) -> str:
        return ".".join(str(x) for x in self if x != 0)


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

    def __lt__(self, other: "Ref[T] | None") -> bool:
        if other is None:
            return False
        return self.a < other.a

    def __str__(self) -> str:
        return f"{self.start}-{self.end}" if self.is_range else str(self.a)

    @staticmethod
    def parse(string: str, ref_cls: Type[T] | None = None) -> "Ref":
        prs = ref_cls.parse if ref_cls else Ref.guess_parse
        if "-" in string:
            start, end = string.split("-")
            if re.match(r"^\d+\.\d+", start) and re.match(r"^\d+$", end):
                a = prs(start)
                b = CV(a.chapter, int(end))  # type: ignore
                return Ref(a, b)  # type: ignore
            return Ref(prs(start), prs(end))
        else:
            return Ref(prs(string))

    @staticmethod
    def guess_parse(string: str) -> "RefPoint":
        if re.match(r"^\d+\.\d+\.\d+$", string):
            return BCV.parse(string)
        elif re.match(r"^\d+\.\d+$", string):
            return CV.parse(string)
        elif re.match(r"^\d+$", string):
            return Verse.parse(string)
        else:
            raise ValueError(f"tried to parse {string}")


@dataclass(order=True, frozen=True, slots=True)
class Verse(RefPoint):
    verse: int
    letter: str = ""


@final
@dataclass(order=True, frozen=True, slots=True)
class CV(RefPoint):
    chapter: int
    verse: int
    letter: str = ""


@final
@dataclass(order=True, frozen=True, slots=True)
class BCV(RefPoint):
    book: int
    chapter: int
    verse: int = 0
    letter: str = ""
