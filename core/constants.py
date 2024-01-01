import os
from pathlib import Path

from box import Box

ENV = Box(os.environ)
ROOT = Path(__file__).parent.parent
DATA = ROOT / "data"
TREEBANKS = DATA / "treebanks"
CANONICAL = ROOT.parent / "canonical-greekLit/data"
TMP = ROOT / "tmp"
CHUNKS = TREEBANKS / "chunks"
NODE_MODULES = ROOT / "node_modules"
LSJ = DATA / "lsj.db"
RIGHT_PUNCT = (".", ",", ";", ":", "·", "]", ")")
LEFT_PUNCT = ("[", "(")
