import os
import shelve
from pathlib import Path

from box import Box

ENV = Box(os.environ)
ROOT = Path(__file__).parent.parent
DATA = ROOT / "data"
TMP = ROOT / "tmp"
NODE_MODULES = ROOT / "node_modules"
LSJ = DATA / "ag/lsj.db"
PUNCTUATION = [".", ",", ";", ":", "·", "]", ")"]
