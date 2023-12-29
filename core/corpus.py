from core.constants import TREEBANKS
from core.ref import BCV, CV, Verse
from core.treebank.chunker import ChapterChunker
from core.treebank.perseus import PerseusTB

PERSEUS2 = TREEBANKS / "perseus/2.1"

corpus: dict[str, PerseusTB] = {
    "iliad": PerseusTB(
        PERSEUS2 / "iliad.xml",
        CV,
        is_verse=True,
        chunker=ChapterChunker,
        lang="ag",
        slug="iliad",
        title="The Iliad",
        original_title="Ἰλιάς",
        author="Homer",
    ),
    "odyssey": PerseusTB(
        PERSEUS2 / "odyssey.xml",
        CV,
        is_verse=True,
        chunker=ChapterChunker,
        lang="ag",
        slug="odyssey",
        title="The Odyssey",
        original_title="Ὀδύσσεια",
        author="Homer",
    ),
    "agamemnon": PerseusTB(
        PERSEUS2 / "agamemnon.xml",
        Verse,
        is_verse=True,
        lang="ag",
        slug="agamemnon",
        title="Agamemnon",
        original_title="Ἀγαμέμνων",
        author="Aeschylus",
    ),
    "libationbearers": PerseusTB(
        PERSEUS2 / "libationbearers.xml",
        Verse,
        is_verse=True,
        lang="ag",
        slug="libationbearers",
        title="Libation Bearers",
        original_title="Χοηφόροι",
        author="Aeschylus",
    ),
    "eumenides": PerseusTB(
        PERSEUS2 / "eumenides.xml",
        Verse,
        is_verse=True,
        lang="ag",
        slug="eumenides",
        title="The Eumenides",
        original_title="Εὐμενίδες",
        author="Aeschylus",
    ),
    "histories": PerseusTB(
        PERSEUS2 / "herodotus.xml",
        BCV,
        is_verse=False,
        lang="ag",
        slug="histories",
        title="The Histories",
        original_title="Ἱστορίαι",
        author="Herodotus",
    ),
}
