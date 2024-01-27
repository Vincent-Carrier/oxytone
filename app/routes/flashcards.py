from time import time
from typing import cast

from box import Box
from genanki import BASIC_MODEL, Deck, Note
from sanic import Blueprint, HTTPResponse, Request, file

from app.jinja import jinja_env
from core.constants import TMP

bp = Blueprint("flashcards", url_prefix="/flashcards")


class Word(Box):
    lemma: str
    definition: str
    phrase: str
    ref: str


flashcard_tmpl = jinja_env.get_template("flashcard_back.html")


@bp.post("/")
async def flashcards(req: Request):
    r = Box(req.json, default_box=True)
    deck = Deck(hash(r.title), name=r.title)
    words = cast(list[Word], r.words)
    for word in words:
        back = await flashcard_tmpl.render_async(**word)
        note = Note(
            BASIC_MODEL,
            fields=[word.lemma, back],
        )
        deck.add_note(note)
    f = f"{r.slug}-{time()}.apkg"
    deck.write_to_file(TMP / f)
    return HTTPResponse(status=201, headers={"Location": f"/flashcards/{f}"})


@bp.get("/<f>")
async def download_deck(req: Request, f: str):
    return await file(TMP / f, filename=f, mime_type="application/apkg")
