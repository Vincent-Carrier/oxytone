import os
from pathlib import Path

from box import Box

env = Box(os.environ, default_box=True)
PROD = env.ENV != "development"
ROOT = Path(__file__).parent.parent
STATIC = ROOT / "static"
DATA = ROOT / "data"
TREEBANKS = DATA / "treebanks"
CANONICAL = ROOT.parent / "canonical-greekLit/data"
TMP = ROOT / "tmp"
CHUNKS = TREEBANKS / "chunks"
NODE_MODULES = ROOT / "node_modules"
LSJ = DATA / "lsj.db"
RIGHT_PUNCT = (".", ",", ";", ":", "·", "]", ")")
LEFT_PUNCT = ("[", "(")
