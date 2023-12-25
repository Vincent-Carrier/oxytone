from json import JSONEncoder
from core.constants import DATA
from core.corpus import docs
from lxml.builder import E
from lxml import etree

from core.ref import Ref


index = {}
for slug, doc in docs.items():
    index[slug] = doc.meta
    outdir = DATA / f"out/{slug}"
    for c in doc.chunks():
        start = doc.parse_ref(c[0].attrib["subdoc"]).start
        end = doc.parse_ref(c[-1].attrib["subdoc"]).end
        span = f"{start}-{end}"
        try:
            ref = Ref.parse(span)
        except:
            print(c[-1].attrib["subdoc"])
            print(dir(end))
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
