from core.constants import DATA
from core.ref import CV
from core.treebank.perseus import PerseusTB, chapter_chunks


docs = {
    "iliad": PerseusTB(
        DATA / "ag/perseus/2.1/iliad.xml",
        CV,
        chapter_chunks,
        is_verse=True,
        lang="ag",
        title="Iliad",
        author="Homer",
    ),
    "odyssey": PerseusTB(
        DATA / "ag/perseus/2.1/odyssey.xml",
        CV,
        chapter_chunks,
        is_verse=True,
        lang="ag",
        title="Odyssey",
        author="Homer",
    ),
}
