import os
import shelve
from pathlib import Path

from box import Box

ENV = Box(os.environ)
ROOT = Path(__file__).parent.parent
DATA = ROOT / "data"
TREEBANKS = DATA / "treebanks"
TMP = ROOT / "tmp"
CHUNKS = ROOT / "chunks"
NODE_MODULES = ROOT / "node_modules"
LSJ = DATA / "lsj.db"
PUNCTUATION = [".", ",", ";", ":", "·", "]", ")"]
