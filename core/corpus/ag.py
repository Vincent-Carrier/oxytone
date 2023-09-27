from core.constants import DATA
from core.ref import BCV, CV, Line
from core.treebank import GntTB, Metadata, PerseusTB

from .corpus_entry import CorpusEntry, DocId

corpus = {
    # DocId("iliad"): CorpusEntry(
    #     Metadata(
    #         lang="ag",
    #         title="Iliad",
    #         author="Homer",
    #         writing_style="verse",
    #     ),
    #     lambda meta: PerseusTB(
    #         AG / "perseus/2.1/iliad.xml", ref_cls=CV, meta=meta
    #     ),
    # ),
    # DocId("persians"): CorpusEntry(
    #     Metadata(
    #         lang="ag",
    #         title="Persians",
    #         author="Aeschylus",
    #         writing_style="verse",
    #     ),
    #     lambda meta: PerseusTB(
    #         AG / "perseus/2.1/persians.xml", ref_cls=Line, meta=meta
    #     ),
    # ),
    # DocId("histories"): CorpusEntry(
    #     Metadata(
    #         lang="ag",
    #         title="Histories, Book 1",
    #         author="Thucydides",
    #     ),
    #     lambda meta: PerseusTB(
    #         AG / "perseus/2.1/thucydides.xml", ref_cls=BCV, meta=meta
    #     ),
    # ),
    # DocId("historiae"): CorpusEntry(
    #     Metadata(
    #         lang="ag",
    #         title="Historiae, Book 1",
    #         author="Herodotus",
    #     ),
    #     lambda meta: PerseusTB(
    #         AG / "perseus/2.1/herodotus.xml", ref_cls=BCV, meta=meta
    #     ),
    # ),
    # DocId("anabasis"): CorpusEntry(
    #     Metadata(
    #         lang="ag",
    #         title="Anabasis, Book 1",
    #         author="Xenophon",
    #     ),
    #     lambda meta: PerseusTB(
    #         AG / "vgorman/Xen_Anab_book_1.1-5.xml",
    #         ref_cls=BCV,
    #         gorman=True,
    #         meta=meta,
    #     ),
    # ),
    DocId("nt"): CorpusEntry(
        Metadata(
            lang="ag",
            title="New Testament",
        ),
        lambda meta: GntTB(DATA / "ag/new-testament.conllu", meta=meta),
    ),
}
