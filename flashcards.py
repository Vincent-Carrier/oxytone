#!/usr/bin/env -S uv run
# /// script
# dependencies = ["requests", "genanki"]
# ///

import sys
import requests
from time import time
from genanki import BASIC_MODEL, Deck, Note

deck = Deck(hash("wordlist"), name="Greek Vocab")
for lemma in sys.stdin:
    res = requests.get(f"http://localhost:8080/define/lsj/{lemma}")
    definition = res.text
    print(f"{lemma}:\n\t{definition}")
    back = definition
    note = Note(
        BASIC_MODEL,
        fields=[lemma, back],
    )
    deck.add_note(note)

f = f"wordlist-{time()}.apkg"
deck.write_to_file(f)


