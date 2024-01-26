from enum import Enum, auto
from functools import singledispatch
from typing import NamedTuple, TypeAlias

import IPython
from lxml import etree
from lxml.builder import E
from lxml.etree import Element, _Element
from more_itertools import peekable

from core.ref import Ref
from core.treebank.treebank import Treebank
from core.utils import cx, filter_none
from core.word import Word


class Format(Enum):
    SPACE = auto()
    SENTENCE_END = auto()
    LINE_BREAK = auto()


class Header(str):
    ...


class LineNumber(int):
    ...


Token: TypeAlias = Word | Ref | Header | LineNumber | Format


@singledispatch
def render(obj) -> _Element | str:
    ...


@render.register(Word)
def _(w: Word) -> _Element | str:
    if w.form == '"':
        return ""
    el = Element(
        "w-token",
        filter_none(
            n=str(w.id),
            head=str(w.head),
            lemma=w.lemma,
            flags=w.flags,
            role=w.role,
            definition=w.definition,
            case=w.case,
            pos=w.pos,
            # punct=str(w.lemma in RIGHT_PUNCT),
        ),
    )
    el.text = w.form
    return el


@render.register(Ref)
def _(ref: Ref) -> _Element:
    return E.a(f"[{ref.start}]", cx("ref"), id=str(ref.start), href=f"#{ref.start}")


@render.register(LineNumber)
def _(n: LineNumber) -> _Element | str:
    return E.a(str(n), cx("ln", visible=n % 5 == 0), id=str(n), href=f"#{n}")


@render.register(Header)
def _(h: Header) -> _Element | str:
    return E.h2(h)


class HtmlPartialRenderer(NamedTuple):
    """Renders a treebank as an HTML partial"""

    tb: Treebank

    def body(self):
        s, sentences = [], []
        for t in (itr := peekable(self.tb)):
            nxt = itr.peek() if itr else None
            match t:
                case Format.LINE_BREAK:
                    s.append(E.br())
                case Format.SPACE:
                    s.append(" ")
                case Format.SENTENCE_END:
                    sentences.append(E.span(*s, cx("sentence")))
                    s = []
                case Header():
                    sentences.append(render(t))
                    if nxt == Format.LINE_BREAK:
                        next(itr)
                case _:
                    s.append(render(t))
        if len(s):
            sentences.append(s)
        print(*sentences[:5])
        return E.div(*sentences, cx("syntax", "verse" if self.tb.is_verse else "prose"))

    def render(self) -> str:
        return etree.tostring(self.body(), encoding="unicode", pretty_print=True)
