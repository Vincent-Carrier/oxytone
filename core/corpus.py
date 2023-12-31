from core.constants import TREEBANKS
from core.ref import BCV, CV, Verse
from core.treebank.perseus import PerseusTB

PERSEUS2 = TREEBANKS / "perseus/2.1"

corpus: dict[str, PerseusTB] = {
    "iliad": PerseusTB(
        PERSEUS2 / "iliad.xml",
        ref_cls=CV,
        is_verse=True,
        chunker="ChapterChunker",
        lang="ag",
        slug="iliad",
        title="The Iliad",
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
        title="The Odyssey",
        original_title="Ὀδύσσεια",
        author="Homer",
        genre="Epic",
    ),
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
        title="The Eumenides",
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
    "histories": PerseusTB(
        PERSEUS2 / "herodotus.xml",
        ref_cls=BCV,
        is_verse=False,
        lang="ag",
        slug="histories",
        title="The Histories",
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
