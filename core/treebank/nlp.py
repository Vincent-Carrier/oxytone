from typing import TYPE_CHECKING, Iterator, final

from cltk import NLP
from more_itertools import peekable

from core.constants import LEFT_PUNCT, RIGHT_PUNCT
from core.render import Format
from core.word import Case, Word

if TYPE_CHECKING:
    from core.render import Token

from .treebank import Treebank

nlp = NLP(language="grc", suppress_banner=True)


@final
class NLPTreebank(Treebank):
    text: str

    def __init__(self, text: str, **kwargs) -> None:
        super().__init__(is_verse=False, **kwargs)
        self.text = text

    def words(self) -> Iterator[Word]:
        for w in nlp.analyze(self.text):
            yield NLPTreebank.make_word(w)

    def __iter__(self) -> Iterator["Token"]:
        for w in (itr := peekable(self.words())):
            n = itr.peek() if itr else None
            if n and n.id == 0:
                yield Format.SENTENCE_END
            yield w
            if n and n.form not in RIGHT_PUNCT and w.form not in LEFT_PUNCT:
                yield Format.SPACE

    @staticmethod
    def make_word(w) -> Word:
        feats = {str(k): next((str(f) for f in v)) for k, v in w.features.items()}
        return Word(
            w.string or "",
            lemma=w.lemma,
            id=w.index_token,
            head=w.governor,
            case=Case(case) if (case := feats.get("Case")) else None,
            role=None,
            pos=None,
        )


_get = lambda feat: next((str(f) for f in feat), None)
