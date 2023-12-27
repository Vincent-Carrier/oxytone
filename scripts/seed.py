import csv
import re
from itertools import islice
import shelve

from core.constants import DATA, LSJ

TRAILING_REGEX = re.compile(r"(\s|\.|,|;)+$")


print("Seeding LSJ...")
with open(DATA / "LSJ_shortdefs.tsv") as f:
    with shelve.open(str(LSJ)) as db:
        for [lemma, definition] in csv.reader(f, dialect="excel-tab"):
            db[lemma] = definition  # TODO: normalize
        print(f"Sample: {list(islice(db.items(), 5))}")
