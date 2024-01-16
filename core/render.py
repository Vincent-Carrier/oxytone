from enum import Enum, auto
from functools import singledispatch
from typing import NamedTuple, TypeAlias, no_type_check

from lxml import etree
from lxml.builder import E
from lxml.etree import _Element, Element
from core.constants import RIGHT_PUNCT
from core.ref import Ref
from core.treebank.treebank import Treebank
from core.utils import cx, filter_none
from core.word import POS, Word


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


class HtmlPartialRenderer(NamedTuple):
    """Renders a treebank as an HTML partial"""

    tb: Treebank

    @no_type_check
    def body(self):
        sentence = []
        sentences = []

        for t in iter(self.tb):
            match t:
                case Word() | Ref():
                    sentence.append(render(t))
                case FT.SPACE:
                    sentence.append(" ")
                case FT.SENTENCE_END:
                    sentences.append(E.span(*sentence, cx("sentence")))
                    sentence = []
                case FT.LINE_BREAK:
                    sentence.append(E.br())
                case int(n):  # verse line numbers
                    sentence.append(
                        E.a(
                            str(n),
                            cx("ln", visible=t % 5 == 0),
                            id=str(t),
                            href=f"#{t}",
                        )
                    )
                case None:
                    pass
        if len(sentence):
            sentences.append(sentence)
        return E.div(*sentences, cx("syntax", "verse" if self.tb.is_verse else "prose"))

    def render(self) -> str:
        return etree.tostring(self.body(), encoding="unicode", pretty_print=True)


class FT(Enum):  # Formatting Token
    SPACE = auto()
    SENTENCE_START = auto()
    SENTENCE_END = auto()
    PARAGRAPH_START = auto()
    PARAGRAPH_END = auto()
    LINE_BREAK = auto()


Token: TypeAlias = Word | Ref | int | FT
