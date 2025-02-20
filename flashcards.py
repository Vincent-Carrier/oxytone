#!/usr/bin/env -S uv run
# /// script
# dependencies = ["requests", "genanki"]
# ///

import sys
import requests
from time import time
from unicodedata import is_normalized, normalize, name
from genanki import BASIC_MODEL, Deck, Note

deck = Deck(hash("wordlist"), name="Greek Vocab")
for line in sys.stdin:
    lemma = line.rstrip()
    res = requests.get(f"http://localhost:8080/define/lsj/{lemma}")
    definition = res.text
    print(f"{lemma!r} {is_normalized('NFC', lemma)}:\n\t{definition}")
    back = definition
    note = Note(
        BASIC_MODEL,
        fields=[lemma, back],
    )
    deck.add_note(note)

f = f"wordlist.apkg"
deck.write_to_file(f)
