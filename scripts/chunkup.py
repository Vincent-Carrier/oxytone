from json import JSONEncoder
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
        is_verse=True,
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

index = {}
for slug, doc in docs.items():
    index[slug] = doc.meta
    outdir = DATA / f"out/{slug}"
    for c in doc.chunks():
        start = doc.parse_ref(c[0].attrib["subdoc"]).start
        end = doc.parse_ref(c[-1].attrib["subdoc"]).end
        span = f"{start}-{end}"
        body: etree._Element = E.body(
            *c,
            **doc.meta,
            refcls=doc.ref_cls.__name__,
            isverse=str(doc.is_verse),
            span=span,
        )
        outdir.mkdir(exist_ok=True)
        outpath = outdir / f"{span}.xml"
        print(f"writing to {outpath}")
        with outpath.open("w") as f:
            f.write(etree.tostring(body, encoding="unicode", pretty_print=True))  # type: ignore

with (DATA / "out/index.json").open("w") as f:
    f.write(JSONEncoder().encode(index))
