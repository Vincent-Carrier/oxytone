from json import JSONEncoder
from core.constants import CHUNKS
from core.corpus import corpus
from lxml.builder import E
from lxml import etree

from core.ref import Ref, RefPoint


index = {}
for slug, doc in corpus.items():
    index[slug] = doc.meta
    if not doc.chunker:
        continue
    outdir = CHUNKS / slug
    spans = []
    for chunk in doc.chunks():
        start = doc.parse_ref(chunk[0].attrib["subdoc"]).start
        end = doc.parse_ref(chunk[-1].attrib["subdoc"]).end
        span = Ref(start, end)
        spans.append(span)
        root: etree._Element = E.treebank(
            E.body(
                *chunk,
            ),
            refcls=doc.ref_cls.__name__,
            isverse=str(doc.is_verse),
            span=str(span),
        )
        outdir.mkdir(exist_ok=True)
        outpath = outdir / f"{span}.xml"
        print(f"writing to {outpath}")
        with outpath.open("w") as f:
            f.write(etree.tostring(root, encoding="unicode", pretty_print=True))  # type: ignore
    index[slug]["spans"] = [str(span) for span in sorted(spans)]

with (CHUNKS / "index.json").open("w") as f:
    f.write(JSONEncoder().encode(index))
