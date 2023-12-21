from functools import singledispatch
from typing import NamedTuple, assert_never

import dominate.tags as h

from core.ref import Ref
from core.token import FT
from core.treebank import Treebank
from core.utils import cx
from core.word import POS, Word


@singledispatch
def render(obj) -> h.html_tag:
    ...


@render.register(Word)
def _(word: Word) -> h.html_tag:
    return h.span(
        word.form,
        cls=cx(word.case, word.pos == POS.verb and word.pos),
        data_id=str(word.id),
        data_head=str(word.head),
        data_lemma=word.lemma,
        data_flags=word.flags,
        data_def=word.definition,
    )


@render.register(Ref)
def _(ref: Ref) -> h.html_tag:
    if hasattr(ref.value, "render"):  # TODO: use __str__
        return ref.value.render()  # type: ignore
    return h.span(str(ref), cls="ref")


class HtmlPartialRenderer(NamedTuple):
    """Renders a treebank as an HTML partial"""

    tb: Treebank

    def body(self) -> h.html_tag:
        sentence = h.span(cls="sentence")
        paragraph = h.p()
        container = h.div(cls="treebank syntax")

        for t in iter(self.tb):
            match t:
                case Word() | Ref():
                    sentence += render(t)
                case FT.SPACE:
                    sentence += " "
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
        return self.body().render()
