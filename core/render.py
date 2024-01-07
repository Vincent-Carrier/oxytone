from enum import Enum, auto
from functools import singledispatch
from typing import Any, NamedTuple, assert_never, TypeAlias, no_type_check

import dominate.tags as h
from core.constants import RIGHT_PUNCT
from core.ref import Ref
from core.treebank.treebank import Treebank
from core.utils import cx
from core.word import POS, Word


@singledispatch
def render(obj) -> Any:
    ...


@render.register(Word)
def _(word: Word) -> Any:
    if word.form == '"':
        return ""
    return h.span(
        word.form,
        cls=cx(
            word.case,
            word.pos == POS.verb and word.pos,
            word.lemma in RIGHT_PUNCT and "punct",
        ),
        data_id=str(word.id),
        data_head=str(word.head),
        data_lemma=word.lemma,
        data_flags=word.flags,
        data_role=word.role,
        data_def=word.definition,
    )


@render.register(Ref)
def _(ref: Ref) -> Any:
    return h.a(f"[{ref.start}]", cls="ref", id=str(ref.start), href=f"#{ref.start}")


class HtmlPartialRenderer(NamedTuple):
    """Renders a treebank as an HTML partial"""

    tb: Treebank

    @no_type_check
    def body(self):
        is_verse = self.tb.is_verse
        verse_cls = "verse" if is_verse else "prose"
        sentence = h.span(cls="sentence")
        container = h.div(cls=f"syntax {verse_cls}")

        for t in iter(self.tb):
            match t:
                case Word() | Ref():
                    sentence += render(t)
                case FT.SPACE:
                    sentence += " "
                case FT.SENTENCE_END:
                    container += sentence
                    sentence = h.span(cls="sentence")
                case FT.LINE_BREAK:
                    sentence += h.br()
                case int():  # verse line numbers
                    visible = "visible" if t % 5 == 0 else ""
                    sentence += h.a(t, cls=f"ln {visible}", id=str(t), href=f"#{t}")
                case None:
                    pass
                case _:
                    assert_never(t)
        if len(sentence):
            container += sentence
        return container

    def render(self) -> str:
        return self.body().render(pretty=False)


class FT(Enum):  # Formatting Token
    SPACE = auto()
    SENTENCE_START = auto()
    SENTENCE_END = auto()
    PARAGRAPH_START = auto()
    PARAGRAPH_END = auto()
    LINE_BREAK = auto()


Token: TypeAlias = Word | Ref | int | FT
