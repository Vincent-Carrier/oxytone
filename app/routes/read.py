from importlib import import_module
from box import Box
from sanic import Blueprint, NotFound, Request, Sanic

from core.constants import CHUNKS
from core.render import HtmlPartialRenderer
from core.treebank.perseus import PerseusTB
from core.corpus import corpus_index, corpus

bp = Blueprint("read", url_prefix="/read")
app = Sanic.get_app("oxytone")


def treebank(tb: PerseusTB, slug: str, chunk_title: str | None = None):
    body = HtmlPartialRenderer(tb).render()
    meta = Box(corpus_index[slug])
    return dict(body=body, chunk_title=chunk_title, **meta)


@bp.get("/<slug>")
@app.ext.template("reader.html")
async def get_treebank(req: Request, slug: str):
    try:
        tb = corpus[slug]
    except KeyError:
        raise NotFound(f"Unknown document {slug}")
    return treebank(tb, slug)


@bp.get("/<slug>/<chunk>")
@app.ext.template("reader.html")
async def get_chunk(req: Request, slug: str, chunk: str):
    f = CHUNKS / slug / f"{chunk}.xml"
    if not f.exists():
        raise NotFound(f"Unknown document {slug}/{chunk}")
    tb = PerseusTB(f, None, None)  # type: ignore
    chunker = getattr(
        import_module("core.treebank.chunker"), corpus_index[slug].chunker
    )
    chunk_title = chunker.label(chunk)
    return treebank(tb, slug, chunk_title)
