from collections.abc import Iterator
import sys
from typing import Any, TypeVar

T = TypeVar("T")
U = TypeVar("U")


class safelist[T](list[T]):
    def get(self, i: int, default: T | None = None) -> T | None:
        try:
            return self[i]
        except IndexError:
            return default

    def __iter__(self) -> Iterator[T | None]:
        yield from super().__iter__()
        yield None


def filter_none(d: dict) -> dict:
    return {k: v for k, v in d.items() if v is not None}


def parse_int(s: str | None) -> int | None:
    return int(s) if s else None


def cx(*args: Any) -> str | None:
    return " ".join(str(a) for a in args if a) or None


def invert(d: dict[T, U]) -> dict[U, T]:
    return {v: k for k, v in d.items()}


def errprint(*args: Any) -> None:
    print(*args, file=sys.stderr)
