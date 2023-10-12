import os
import re
from copy import copy
from pathlib import Path
import shelve
from typing import Iterator, Self, Type, cast, final

from lxml import etree
from pyCTS import CTS_URN

from core.constants import LSJ, PUNCTUATION
from core.ref import Ref, T
from core.token import FT, Token
from core.treebank import Treebank
from core.utils import at, eprint, parse_int
from core.word import POS, Case, Word


@final
class PerseusTB(Treebank[T]):
    body: etree._Element
    gorman: bool
    refs: list[Ref] = []

    def __init__(
        self,
        f: os.PathLike[str],
        ref_cls: Type[T],
        gorman: bool = False,
        **kwargs,
    ) -> None:
        super().__init__(ref_cls=ref_cls, **kwargs)
        self.gorman = gorman

        if not self.ref:
            tree = etree.parse(f)
            root = tree.getroot()
            if gorman:
                self.body = root
            else:
                self.body = cast(etree._Element, root.find(".//body"))

            self.refs = [
                self.parse_ref(r)
                for sentence in self.body.findall("./sentence")
                if (r := sentence.get("subdoc")) is not None
            ]

    def __getitem__(self, ref: Ref | str) -> Self:
        if isinstance(ref, str):
            return self[self.parse_ref(ref)]
        if ref not in self:
            raise KeyError(f"Cannot find {ref} in {self!r}")
        nearest = self.nearest(ref)
        if nearest != ref:
            eprint(f"Warning: {ref} not found, using {nearest}")
        tb = copy(self)
        tb.ref = nearest
        return tb

    def __contains__(self, r: Ref) -> bool:
        return any(r in ref for ref in self.refs)

    def nearest(self, r: Ref) -> Ref:
        return next(ref for ref in self.refs if r in ref)

    def sentences(self) -> Iterator[etree._Element]:
        if self.ref:
            nearest = self.nearest(self.ref)
            el = self.body.find(f"./sentence[@subdoc='{nearest}']")
            if el is None:
                raise KeyError(
                    f"Could not find ./sentence[@subdoc='{nearest}' in {self!r}]"
                )
            yield el
            path = f"./sentence[@subdoc='{nearest}']/following-sibling::sentence"
            for sentence in cast(Iterator[etree._Element], self.body.xpath(path)):
                if self.parse_ref(sentence.attrib["subdoc"]) > self.ref.end:  # type: ignore
                    return
                yield sentence
        else:
            yield from self.body.findall("./sentence")

    def __iter__(self) -> Iterator[Token]:
        prev_ref: Ref | None = None
        prev_form: str = ""
        for sentence in self.sentences():
            yield FT.SENTENCE_START
            for el in sentence.findall("./word"):
                word = self.word(el.attrib)
                # TODO: yield paragraph tokens
                if word:
                    if word.ref and word.ref > prev_ref:
                        if self.meta.writing_style == "prose":
                            yield FT.LINE_BREAK
                        prev_ref = word.ref
                    if prev_form and (prev_form not in PUNCTUATION):
                        yield FT.SPACE
                    prev_form = word.form
                    yield word
            yield FT.SENTENCE_END

    def normalize_urn(self, urn: str | bytes) -> str:
        return re.search(r"^(urn:cts:greekLit:tlg\d{4}.tlg\d{3}).*", str(urn)).group(1)  # type: ignore

    def word(self, attr) -> Word | None:
        if attr.get("insertion_id") is not None:  # TODO
            return None
        tags = attr.get("postag")
        pos = POS.parse_agldt(at(tags, 0))
        case = Case.parse_agldt(at(tags, 7))
        lemma = attr.get("lemma")
        if lemma:
            lemma = re.sub(r"\d+$", "", lemma)
        ref = None
        cite = attr.get("cite")
        if cite:
            first = cite.split(" ")[0]
            urn = CTS_URN(first)
            ref_str = cast(str, urn.passage_component)
            ref = Ref(self.ref_cls.parse(ref_str))
        return Word(
            id=parse_int(attr.get("id")),
            head=parse_int(attr.get("head")),
            form=attr["form"],
            lemma=lemma,
            pos=pos,
            case=case,
            flags=tags,
            definition=lsj.get(lemma) if lemma else None,
            ref=ref,
        )


lsj = shelve.open(str(LSJ), 'r')
