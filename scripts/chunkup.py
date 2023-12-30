from core.constants import CHUNKS
from core.corpus import corpus
from lxml.builder import E
from lxml import etree

from core.ref import Ref


for slug, tb in corpus.items():
    if not tb.meta.get("chunker"):
        continue
    assert tb.chunker
    outdir = CHUNKS / slug
    chunk_labels = []
    for chunk in tb.chunks():
        start = tb.parse_ref(chunk[0].attrib["subdoc"]).start
        end = tb.parse_ref(chunk[-1].attrib["subdoc"]).end
        span = Ref(start, end)
        label = tb.chunker.short_label(span)
        chunk_labels.append(label)
        root: etree._Element = E.treebank(
            E.body(*chunk),
            refcls=tb.ref_cls.__name__,
            isverse=str(tb.is_verse),
            span=str(span),
        )
        outdir.mkdir(exist_ok=True)
        outpath = outdir / f"{label}.xml"
        print(f"{outpath}")
        with outpath.open("w") as f:
            f.write(etree.tostring(root, encoding="unicode", pretty_print=True))  # type: ignore
