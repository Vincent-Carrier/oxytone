import re
from time import time
from core.augment_xml import TreebankAugmenter
from core.constants import CANONICAL, TREEBANKS
from core.corpus import corpus
from lxml import etree

for tb in corpus.values():
    slug, genre, urn = tb.meta["slug"], tb.meta.get("genre"), tb.meta.get("urn")
    if genre != "Tragedy":
        continue
    if urn is None:
        print("no urn, aborting", slug)
        continue
    match = re.search(r"(tlg\d{4})\.(tlg\d{3})\.([\w-]+)", urn)
    if match is None:
        print("no match, aborting", slug, urn)
        continue
    full, author, work, edition = match.group(), *match.groups()
    canonical_dir = CANONICAL / author / work
    if not canonical_dir.exists():
        print(canonical_dir, "file does not exist for", slug, sep="\t")
    f = next(f for f in canonical_dir.iterdir() if "grc" in f.name)
    print("processing", slug, f)
    canonical = etree.parse(f).getroot()
    outstr = TreebankAugmenter(tb, canonical).render()
    outf = TREEBANKS / f"augmented/{slug}-{time()}.xml"
    with outf.open("w") as f:
        f.write(outstr)
