import re
from core.augment_xml import TreebankAugmenter
from core.constants import CANONICAL, TREEBANKS
from lxml import etree
from core.ref import Verse
from core.treebank.perseus import PerseusTB


corpus = {
    # Aeschylus
    "persians": PerseusTB(
        TREEBANKS / "perseus/2.1/persians.xml",
        slug="persians",
        ref_cls=Verse,
        is_verse=True,
    ),
    "seven-against-thebes": PerseusTB(
        TREEBANKS / "perseus/2.1/seven-against-thebes.xml",
        slug="seven-against-thebes",
        ref_cls=Verse,
        is_verse=True,
    ),
    "suppliants": PerseusTB(
        TREEBANKS / "perseus/2.1/suppliants.xml",
        slug="suppliants",
        ref_cls=Verse,
        is_verse=True,
    ),
    "agamemnon": PerseusTB(
        TREEBANKS / "perseus/2.1/agamemnon.xml",
        slug="agamemnon",
        ref_cls=Verse,
        is_verse=True,
    ),
    "libation-bearers": PerseusTB(
        TREEBANKS / "perseus/2.1/libation-bearers.xml",
        slug="libation-bearers",
        ref_cls=Verse,
        is_verse=True,
    ),
    "eumenides": PerseusTB(
        TREEBANKS / "perseus/2.1/eumenides.xml",
        slug="eumenides",
        ref_cls=Verse,
        is_verse=False,
    ),
    "prometheus-bound": PerseusTB(
        TREEBANKS / "perseus/2.1/prometheus-bound.xml",
        slug="prometheus-bound",
        ref_cls=Verse,
        is_verse=True,
    ),
    # Sophocles
    "ajax": PerseusTB(
        TREEBANKS / "perseus/1.6/sophocles-ajax-perseus-grc1.xml",
        slug="ajax",
        ref_cls=Verse,
        is_verse=True,
    ),
    "antigone": PerseusTB(
        TREEBANKS / "perseus/1.6/sophocles-antigone-perseus-grc2.xml",
        slug="antigone",
        ref_cls=Verse,
        is_verse=True,
    ),
    "women-of-trachis": PerseusTB(
        TREEBANKS / "perseus/1.6/sophocles-trachiniae-perseus-grc2.xml",
        slug="women-of-trachis",
        ref_cls=Verse,
        is_verse=True,
    ),
    "oedipus-rex": PerseusTB(
        TREEBANKS / "perseus/1.6/sophocles-oedipus-tyrannus-perseus-grc1.xml",
        slug="oedipus-rex",
        ref_cls=Verse,
        is_verse=True,
    ),
    "electra": PerseusTB(
        TREEBANKS / "perseus/1.6/sophocles-electra-perseus-grc2.xml",
        slug="electra",
        ref_cls=Verse,
        is_verse=True,
    ),
}


for tb in corpus.values():
    slug, urn = tb.meta.slug, tb.meta.get("urn")
    print(f"{slug}:")
    if urn is None:
        print("\tno URN, aborting")
        continue
    match = re.search(r"(tlg\d{4})\.(tlg\d{3})\.([\w-]+)", urn)
    if match is None:
        print("\tno URN match, aborting", urn)
        continue
    full, author, work, edition = match.group(), *match.groups()
    canonical_dir = CANONICAL / author / work
    if not canonical_dir.exists():
        print(f"\tfile does not exist in {canonical_dir.relative_to(CANONICAL)}")
    f = next(f for f in canonical_dir.iterdir() if "grc" in f.name)
    print("\tprocessing", f.relative_to(CANONICAL))
    canonical = etree.parse(f).getroot()
    outstr = TreebankAugmenter(tb, canonical).render()
    outf = TREEBANKS / f"augmented/{slug}.xml"
    with outf.open("w") as f:
        f.write(outstr)
