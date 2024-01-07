from box import Box
from core.constants import CHUNKS, TREEBANKS
from core.ref import BCV, CV, Verse
from core.treebank.perseus import PerseusTB

PERSEUS1 = TREEBANKS / "perseus/1.6"
PERSEUS2 = TREEBANKS / "perseus/2.1"


corpus: dict[str, PerseusTB] = {
    # Homer
    "iliad": PerseusTB(
        PERSEUS2 / "iliad.xml",
        ref_cls=CV,
        is_verse=True,
        chunker="ChapterChunker",
        lang="ag",
        slug="iliad",
        title="Iliad",
        original_title="Ἰλιάς",
        author="Homer",
        genre="Epic",
    ),
    "odyssey": PerseusTB(
        PERSEUS2 / "odyssey.xml",
        ref_cls=CV,
        is_verse=True,
        chunker="ChapterChunker",
        lang="ag",
        slug="odyssey",
        title="Odyssey",
        original_title="Ὀδύσσεια",
        author="Homer",
        genre="Epic",
    ),
    # Hesiod
    "theogony": PerseusTB(
        PERSEUS1 / "hesiod-theogony-perseus-grc1.xml",
        ref_cls=BCV,
        is_verse=True,
        lang="ag",
        slug="theogony",
        title="Theogony",
        original_title="Θεογονία",
        author="Hesiod",
        genre="Epic",
    ),
    "works-and-days": PerseusTB(
        PERSEUS1 / "hesiod-works-and-days-perseus-grc1.xml",
        ref_cls=Verse,
        is_verse=False,
        lang="ag",
        slug="works-and-days",
        title="Works and Days",
        original_title="Ἔργα καὶ Ἡμέραι",
        author="Hesiod",
        genre="Epic",
    ),
    # Aeschylus
    "persians": PerseusTB(
        PERSEUS2 / "persians.xml",
        ref_cls=Verse,
        is_verse=True,
        lang="ag",
        slug="persians",
        title="Persians",
        original_title="Πέρσαι",
        author="Aeschylus",
        genre="Tragedy",
    ),
    "seven-against-thebes": PerseusTB(
        PERSEUS2 / "seven-against-thebes.xml",
        ref_cls=Verse,
        is_verse=True,
        lang="ag",
        slug="seven-against-thebes",
        title="Seven Against Thebes",
        original_title="Ἑπτὰ ἐπὶ Θήβας",
        author="Aeschylus",
        genre="Tragedy",
    ),
    "suppliants": PerseusTB(
        PERSEUS2 / "suppliants.xml",
        ref_cls=Verse,
        is_verse=True,
        lang="ag",
        slug="suppliants",
        title="Suppliants",
        original_title="Ἱκέτιδες",
        author="Aeschylus",
        genre="Tragedy",
    ),
    "agamemnon": PerseusTB(
        PERSEUS2 / "agamemnon.xml",
        ref_cls=Verse,
        is_verse=True,
        lang="ag",
        slug="agamemnon",
        title="Agamemnon",
        original_title="Ἀγαμέμνων",
        author="Aeschylus",
        genre="Tragedy",
    ),
    "libation-bearers": PerseusTB(
        PERSEUS2 / "libation-bearers.xml",
        ref_cls=Verse,
        is_verse=True,
        lang="ag",
        slug="libation-bearers",
        title="Libation Bearers",
        original_title="Χοηφόροι",
        author="Aeschylus",
        genre="Tragedy",
    ),
    "eumenides": PerseusTB(
        PERSEUS2 / "eumenides.xml",
        ref_cls=Verse,
        is_verse=False,
        lang="ag",
        slug="eumenides",
        title="Eumenides",
        original_title="Εὐμενίδες",
        author="Aeschylus",
        genre="Tragedy",
    ),
    "prometheus-bound": PerseusTB(
        PERSEUS2 / "prometheus-bound.xml",
        ref_cls=Verse,
        is_verse=True,
        lang="ag",
        slug="prometheus-bound",
        title="Prometheus Bound",
        original_title="Προμηθεὺς Δεσμώτης",
        author="Aeschylus",
        genre="Tragedy",
    ),
    # Sophocles
    "ajax": PerseusTB(
        PERSEUS1 / "sophocles-ajax-perseus-grc1.xml",
        ref_cls=Verse,
        is_verse=True,
        lang="ag",
        slug="ajax",
        title="Ajax",
        original_title="Αἴας",
        author="Sophocles",
        genre="Tragedy",
    ),
    "antigone": PerseusTB(
        PERSEUS1 / "sophocles-antigone-perseus-grc2.xml",
        ref_cls=Verse,
        is_verse=True,
        lang="ag",
        slug="antigone",
        title="Antigone",
        original_title="Ἀντιγόνη",
        author="Sophocles",
        genre="Tragedy",
    ),
    "women-of-trachis": PerseusTB(
        PERSEUS1 / "sophocles-trachiniae-perseus-grc2.xml",
        ref_cls=Verse,
        is_verse=True,
        lang="ag",
        slug="women-of-trachis",
        title="Women of Trachis",
        original_title="Τραχίνιαι",
        author="Sophocles",
        genre="Tragedy",
    ),
    "oedipus-rex": PerseusTB(
        PERSEUS1 / "sophocles-oedipus-tyrannus-perseus-grc1.xml",
        ref_cls=Verse,
        is_verse=True,
        lang="ag",
        slug="oedipus-rex",
        title="Œdipus Rex",
        original_title="Οἰδίπους τύραννος",
        author="Sophocles",
        genre="Tragedy",
    ),
    "electra": PerseusTB(
        PERSEUS1 / "sophocles-electra-perseus-grc2.xml",
        ref_cls=Verse,
        is_verse=True,
        lang="ag",
        slug="electra",
        title="Electra",
        original_title="Ἠλέκτρα",
        author="Sophocles",
        genre="Tragedy",
    ),
    "histories": PerseusTB(
        PERSEUS2 / "herodotus.xml",
        ref_cls=BCV,
        is_verse=False,
        lang="ag",
        slug="histories",
        title="Histories",
        original_title="Ἱστορίαι",
        author="Herodotus",
        span="Book 1",
        genre="History",
    ),
    "eutyphro": PerseusTB(
        PERSEUS2 / "eutyphro.xml",
        ref_cls=None,
        is_verse=False,
        lang="ag",
        slug="eutyphro",
        title="Eutyphro",
        original_title="Εὐθύφρων",
        author="Plato",
        genre="Philosophy",
    ),
}


def _get_chunks(slug: str) -> list[int]:
    dir = CHUNKS / slug
    return sorted(int(f.name.rstrip(".xml")) for f in dir.iterdir())


corpus_index = {
    slug: Box(
        tb.meta
        | {
            "chunks": _get_chunks(slug) if tb.meta.get("chunker") else None,
            # "is_verse": tb.is_verse,
            # "ref_cls": tb.ref_cls,
        }
    )
    for slug, tb in corpus.items()
}
