from core.constants import DATA
from core.ref import CV, Line
from core.treebank.perseus import PerseusTB, chapter_chunks, whole_chunk


docs = {
    "iliad": PerseusTB(
        DATA / "ag/perseus/2.1/iliad.xml",
        CV,
        chapter_chunks,
        is_verse=True,
        lang="ag",
        slug="iliad",
        title="The Iliad",
        original_title="Ἰλιάς",
        author="Homer",
    ),
    "odyssey": PerseusTB(
        DATA / "ag/perseus/2.1/odyssey.xml",
        CV,
        chapter_chunks,
        is_verse=True,
        lang="ag",
        slug="odyssey",
        title="The Odyssey",
        original_title="Ὀδύσσεια",
        author="Homer",
    ),
    "agamemnon": PerseusTB(
        DATA / "ag/perseus/2.1/agamemnon.xml",
        Line,
        whole_chunk,
        is_verse=True,
        lang="ag",
        slug="agamemnon",
        title="Agamemnon",
        original_title="Ἀγαμέμνων",
        author="Aeschylus",
    ),
    "libationbearers": PerseusTB(
        DATA / "ag/perseus/2.1/libationbearers.xml",
        Line,
        whole_chunk,
        is_verse=True,
        lang="ag",
        slug="libationbearers",
        title="Libation Bearers",
        original_title="Χοηφόροι",
        author="Aeschylus",
    ),
    "eumenides": PerseusTB(
        DATA / "ag/perseus/2.1/eumenides.xml",
        Line,
        whole_chunk,
        is_verse=True,
        lang="ag",
        slug="eumenides",
        title="The Eumenides",
        original_title="Εὐμενίδες",
        author="Aeschylus",
    ),
}
