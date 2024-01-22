from textwrap import dedent
from time import time
from typing import Any, cast
from box import Box
from sanic import Blueprint, HTTPResponse, Request, file
from genanki import Note, Deck, BASIC_MODEL

from core.constants import TMP

bp = Blueprint("flashcards", url_prefix="/flashcards")


@bp.post("/")
async def flashcards(req: Request):
    r = Box(req.json)
    deck = Deck(hash(r.title), name=r.title)
    words = cast(list[Any], r.words)
    for word in words:
        back = dedent(
            f"""
            {word.definition}<br/>
            {word.phrase}<br/>
            <a href="https://lsj.gr/index.php?search={word.lemma}">lsj.gr</a>
            """
        )
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
