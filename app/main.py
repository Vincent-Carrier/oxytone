import tempfile
from fastapi import FastAPI, Query
from fastapi.responses import FileResponse
from genanki import BASIC_MODEL, Deck, Note
from httpx import AsyncClient
from typing import Annotated

basex = AsyncClient(base_url="http://localhost:8080")
app = FastAPI()


@app.get("/flashcards")
async def create_flashcards(
    author: Annotated[str, Query()],
    work: Annotated[str, Query()],
    w: Annotated[list[str], Query()],
):
    deck = Deck(hash("wordlist"), name="Greek Vocabulary")
    for lemma in w:
        res = await basex.get(f"/define/lsj/{lemma}")
        definition = res.text
        deck.add_note(
            Note(
                BASIC_MODEL,
                fields=[lemma, definition],
                tags=[f"author-{author}", f"work-{work}"],
            )
        )
    with tempfile.NamedTemporaryFile(delete=False) as f:
        deck.write_to_file(f.name)
        response = FileResponse(
            f.name,
            filename="greek-flashcards.apkg",
            media_type="application/octet-stream",
        )
        return response
