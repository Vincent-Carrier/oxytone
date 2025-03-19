import tempfile
from fastapi import FastAPI
from fastapi.responses import FileResponse
from pydantic import BaseModel
import sys
from genanki import BASIC_MODEL, Deck, Note
from httpx import AsyncClient

basex = AsyncClient(base_url="http://localhost:8080")
app = FastAPI()


class Flashcard(BaseModel):
    lemma: str
    definition: str | None = None


@app.post("/flashcards")
async def create_flashcards(flashcards: list[Flashcard]):
    deck = Deck(hash("wordlist"), name="Oxytone")
    for fc in flashcards:
        res = await basex.get(f"/define/lsj/{fc.lemma}")
        definition = res.text
        deck.add_note(
            Note(
                BASIC_MODEL,
                fields=[fc.lemma, definition],
            )
        )
    with tempfile.TemporaryFile() as f:
        deck.write_to_file(f)
        return FileResponse(
            f.name, filename="oxytone.apkg", media_type="application/zip"
        )
