from functools import singledispatch
from typing import Any, NamedTuple, assert_never

import dominate.tags as h

from dominate.util import raw
from core.constants import PUNCTUATION
from core.ref import Ref
from core.token import FT
from core.treebank.treebank import Treebank
from core.utils import cx
from core.word import POS, Word


@singledispatch
def render(obj) -> Any:
    ...


@render.register(Word)
def _(word: Word) -> Any:
    return h.span(
        word.form,
        cls=cx(
            word.case,
            word.pos == POS.verb and word.pos,
            word.lemma in PUNCTUATION and "punct",
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

    def body(self) -> h.html_tag:
        is_verse = self.tb.is_verse  # type: ignore
        sentence = h.span(cls="sentence")
        paragraph = h.p()
        container = h.div(cls="treebank syntax")

        for t in iter(self.tb):
            match t:
                case Word() | Ref():
                    sentence += render(t)
                case FT.SPACE:
                    sentence += raw("&nbsp;") if is_verse else " "
                case FT.PARAGRAPH_START:
                    paragraph = h.p()
                case FT.SENTENCE_START:
                    sentence = h.span(cls="sentence")
                case FT.PARAGRAPH_END:
                    if len(paragraph):
                        container += paragraph
                case FT.SENTENCE_END:
                    if len(sentence):
                        paragraph += sentence
                case FT.LINE_BREAK:
                    sentence += h.br()
                case int():  # verse line numbers
                    visible = "visible" if t % 5 == 0 else ""
                    sentence += h.span(t, cls=f"ln {visible}")
                case None:
                    pass
                case _:
                    assert_never(t)
        if len(sentence):
            paragraph += sentence
        if len(paragraph):
            container += paragraph
        return container

    def render(self) -> str:
        return self.body().render(pretty=False)
