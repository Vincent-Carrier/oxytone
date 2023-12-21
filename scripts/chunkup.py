from core.constants import DATA
from core.ref import CV
from core.treebank.perseus import PerseusTB, chapter_chunks
from lxml.builder import E
from lxml import etree


docs = {
    "iliad": PerseusTB(
        DATA / "ag/perseus/2.1/iliad.xml",
        CV,
        chapter_chunks,
        lang="ag",
        title="Iliad",
        author="Homer",
    ),
    "odyssey": PerseusTB(
        DATA / "ag/perseus/2.1/iliad.xml",
        CV,
        chapter_chunks,
        lang="ag",
        title="Iliad",
        author="Homer",
    ),
}

for slug, doc in docs.items():
    folder = DATA / f"out/{slug}"
    for c in doc.chunks():
        start = doc.parse_ref(c[0].attrib["subdoc"]).start
        end = doc.parse_ref(c[-1].attrib["subdoc"]).end
        range = f"{start}-{end}"
        body: etree._Element = E.body(*c)
        folder.mkdir(exist_ok=True)
        outpath = folder / f"{range}.xml"
        print(f"writing to {outpath}")
        with outpath.open("w") as f:
            f.write(etree.tostring(body, encoding="unicode", pretty_print=True))  # type: ignore
