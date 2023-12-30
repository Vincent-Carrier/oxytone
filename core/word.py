from dataclasses import dataclass
from greek_accentuation.characters import breathing, SMOOTH, strip_breathing
from enum import StrEnum, auto
from typing import Optional

from core.ref import Ref


class POS(StrEnum):
    noun = auto()
    verb = auto()
    participle = auto()
    adjective = auto()
    adverb = auto()
    article = auto()
    particle = auto()
    conjunction = auto()
    preposition = auto()
    pronoun = auto()
    numeral = auto()
    interjection = auto()
    exclamation = auto()
    punctuation = auto()

    @staticmethod
    def parse_agldt(pos: str | None) -> Optional["POS"]:
        pairings = {
            "n": POS.noun,
            "v": POS.verb,
            "t": POS.participle,
            "a": POS.adjective,
            "d": POS.adverb,
            "l": POS.article,
            "g": POS.particle,
            "c": POS.conjunction,
            "r": POS.preposition,
            "p": POS.pronoun,
            "m": POS.numeral,
            "i": POS.interjection,
            "e": POS.exclamation,
            "u": POS.punctuation,
            "-": None,
        }
        return pairings.get(pos) if pos else None

    @staticmethod
    def parse_conll(pos: str | None) -> Optional["POS"]:
        pairings = {
            "ADJ": POS.adjective,
            "ADP": POS.preposition,
            "ADV": POS.adverb,
            "AUX": POS.verb,
            "CCONJ": POS.conjunction,
            "DET": POS.article,
            "INTJ": POS.interjection,
            "NOUN": POS.noun,
            "NUM": POS.numeral,
            "PART": POS.particle,
            "PRON": POS.pronoun,
            "PROPN": POS.noun,
            "PUNCT": POS.punctuation,
            "SCONJ": POS.conjunction,
            "SYM": None,
            "VERB": POS.verb,
            "X": None,
        }
        return pairings.get(pos) if pos else None


class Case(StrEnum):
    nominative = auto()
    accusative = auto()
    dative = auto()
    genitive = auto()
    vocative = auto()

    @staticmethod
    def parse_agldt(case: str | None) -> Optional["Case"]:
        pairings = {
            "n": Case.nominative,
            "a": Case.accusative,
            "d": Case.dative,
            "g": Case.genitive,
            "v": Case.vocative,
            "-": None,
        }
        return pairings.get(case) if case else None

    @staticmethod
    def parse_conll(case: str) -> Optional["Case"]:
        pairings = {
            "Nom": Case.nominative,
            "Acc": Case.accusative,
            "Dat": Case.dative,
            "Gen": Case.genitive,
            "Voc": Case.vocative,
        }
        return pairings.get(case)


@dataclass(slots=True)
class Word:
    form: str
    id: int | None
    head: int | None
    lemma: str | None
    pos: POS | None
    case: Case | None
    role: str | None
    flags: str | None = None
    definition: str | None = None
    ref: Ref | None = None

    def __post_init__(self):
        if breathing(self.form) == SMOOTH:
            self.form = strip_breathing(self.form)

    def __str__(self) -> str:
        return self.form
