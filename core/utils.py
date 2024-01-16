from typing import Any, TypeVar

T = TypeVar("T")


class safelist(list[T]):
    def get(self, i: int, default: T | None = None) -> T | None:
        try:
            return self[i]
        except IndexError:
            return default


def filter_none(**kwargs: Any | None) -> dict[str, Any]:
    return {k: v for k, v in kwargs.items() if v is not None}


def cx(*args: Any, **kwargs: Any) -> dict[str, str | None]:
    """Joins a list of CSS class strings"""
    classes = [str(v) for v in args if v]
    classes += [k for k, v in kwargs.items() if v]
    return {"class": " ".join(classes) or None}
