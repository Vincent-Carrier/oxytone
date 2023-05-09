from abc import ABC, ABCMeta
from dataclasses import astuple, dataclass
from typing import Generic, Self, Type, TypeAlias, TypeVar, final

from dominate.tags import span
from ordered_enum import OrderedEnum  # type: ignore


@dataclass(order=True, frozen=True)
class Ref(metaclass=ABCMeta):
    @classmethod
    def parse(cls, ref: str) -> Self:
        return cls(*(int(x) for x in ref.split(".")))

    def __iter__(self):
        yield from astuple(self)

    def __str__(self) -> str:
        return ".".join(str(x) for x in self if x is not None)

    def __contains__(self, ref: object) -> bool:
        if not isinstance(ref, Ref):
            raise TypeError(f"Cannot check if {ref} is in {self}")
        for a, b in zip(self, ref):
            if a is None and b is not None:
                return True
            if a != b:
                return False
        return True

    def render(self):
        ...


T = TypeVar("T", bound=Ref)

@final
@dataclass(order=True, frozen=True)
class RefRange(Generic[T]):
    start: T
    end: T

    @classmethod
    def parse(cls, ref_cls: Type[Ref], ref: str) -> Self:
        start, end = ref.split("-")
        return cls(ref_cls.parse(start), ref_cls.parse(end))

    def __str__(self) -> str:
        return f"{self.start}-{self.end}"

    def __contains__(self, obj: object) -> bool:
        match obj:
            case RefRange():
                return self.start <= obj.start <= obj.end <= self.end
            case Ref():
                return self.start <= obj <= self.end
            case _:
                raise TypeError(f"Cannot check if {obj} is in {self}")


RefLike: TypeAlias = T | RefRange[T]


def parse_reflike(ref_cls, subdoc: str) -> RefLike:
    return RefRange.parse(ref_cls, subdoc) if "-" in subdoc else ref_cls.parse(subdoc)


@final
@dataclass(order=True, frozen=True, slots=True)
class BCV(Ref):
    book: int
    chapter: int | None = None
    verse: int | None = None


@final
@dataclass(order=True, frozen=True, slots=True)
class CV(Ref):
    chapter: int
    verse: int | None = None


@final
@dataclass(order=True, frozen=True, slots=True)
class Line(Ref):
    line: int


class NT_Book(OrderedEnum):
    MATT = "MATT"
    MARK = "MARK"
    LUKE = "LUKE"
    JOHN = "JOHN"
    ACTS = "ACTS"
    ROM = "ROM"
    COR1 = "1COR"
    COR2 = "2COR"
    GAL = "GAL"
    EPH = "EPH"
    PHIL = "PHIL"
    COL = "COL"
    THESS1 = "1THESS"
    THESS2 = "2THESS"
    TIM1 = "1TIM"
    TIM2 = "2TIM"
    TIT = "TIT"
    PHILEM = "PHILEM"
    HEB = "HEB"
    JAS = "JAS"
    PET1 = "1PET"
    JOHN3 = "3JOHN"
    JUDE = "JUDE"
    REV = "REV"


@final
@dataclass(order=True, frozen=True, slots=True)
class NT_Ref(Ref):
    book: NT_Book
    chapter: int = 0
    verse: int = 0

    def __str__(self):
        if self.is_chapter:
            return f"{self.book.value}_{self.chapter}"
        else:
            return f"{self.book.value}_{self.chapter}.{self.verse}"

    @property
    def is_book(self) -> bool:
        return self.chapter == 0 and self.verse == 0

    @property
    def is_chapter(self) -> bool:
        return self.chapter > 0 and self.verse == 0

    @property
    def is_verse(self) -> bool:
        assert self.chapter > 0
        return self.verse != 0

    def render(self) -> span:
        if self.is_chapter:
            return span(self.chapter, cls="chapter")
        elif self.is_verse:
            return span(self.verse, cls="verse")
        else:
            raise ValueError("cannot render {self}")

    @classmethod
    def parse(cls, ref: str) -> Self:
        b, cv = ref.split("_")
        if "." in cv:
            c, v = cv.split(".")
            return cls(NT_Book(b), int(c), int(v))
        else:
            return cls(NT_Book(b), int(cv), 0)


# TODO: make RefLike a class
def lt_reflike(a: RefLike, b: RefLike | None):
    if b is None:
        return True
    a = a.end if isinstance(a, RefRange) else a
    b = b.start if isinstance(b, RefRange) else b
    return a < b  # type: ignore