from core.constants import TREEBANKS
from core.ref import CV, Line
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
        Line,
        is_verse=True,
        lang="ag",
        slug="agamemnon",
        title="Agamemnon",
        original_title="Ἀγαμέμνων",
        author="Aeschylus",
    ),
    "libationbearers": PerseusTB(
        PERSEUS2 / "libationbearers.xml",
        Line,
        is_verse=True,
        lang="ag",
        slug="libationbearers",
        title="Libation Bearers",
        original_title="Χοηφόροι",
        author="Aeschylus",
    ),
    "eumenides": PerseusTB(
        PERSEUS2 / "eumenides.xml",
        Line,
        is_verse=True,
        lang="ag",
        slug="eumenides",
        title="The Eumenides",
        original_title="Εὐμενίδες",
        author="Aeschylus",
    ),
}
