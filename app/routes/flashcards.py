from datetime import datetime
from time import sleep
from typing import cast
from box import Box
from flask import Blueprint, Response, request, send_file
from genanki import Note, Deck, BASIC_MODEL

from core.constants import TMP
from core.word import Word

bp = Blueprint("flashcards", __name__, url_prefix="/flashcards")


@bp.post("/")
def flashcards():
    req = Box(request.json)
    deck = Deck(hash(req.title), name=req.title)
    words = cast(list[Word], req.words)
    for word in words:
        note = Note(
            BASIC_MODEL,
            fields=[word.lemma, word.definition],
            tags=[word.pos],
        )
        deck.add_note(note)
    f = f"{datetime.now().microsecond}.apkg"
    deck.write_to_file(TMP / f)
    return {"filename": f}


@bp.get("/<f>")
def download_deck(f: str):
    return send_file(TMP / f, as_attachment=True, download_name=f)
