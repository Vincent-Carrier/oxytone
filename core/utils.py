from typing import Any, TypeVar

T = TypeVar("T")
U = TypeVar("U")


class safelist[T](list[T]):
    def get(self, i: int, default: T | None = None) -> T | None:
        try:
            return self[i]
        except IndexError:
            return default


def filter_none(d: dict[T, U | None]) -> dict[T, U]:
    return {k: v for k, v in d.items() if v is not None}


def cx(*args: Any) -> str | None:
    return " ".join(str(a) for a in args if a) or None
