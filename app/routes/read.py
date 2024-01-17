from importlib import import_module
from box import Box
from sanic import Blueprint, NotFound, Request, Sanic

from core.constants import CHUNKS
from core.render import HtmlPartialRenderer
from core.treebank.perseus import PerseusTB
from core.corpus import corpus_index, corpus
from app.jinja import template

bp = Blueprint("read", url_prefix="/read")


def treebank(tb: PerseusTB, slug: str, chunk_title: str | None = None):
    body = HtmlPartialRenderer(tb).render()
    meta = Box(corpus_index[slug])
    return dict(body=body, chunk_title=chunk_title, **meta)


render = template("reader")


@bp.get("/<slug>")
async def get_treebank(req: Request, slug: str):
    try:
        tb = corpus[slug]
    except KeyError:
        raise NotFound(f"Unknown document {slug}")
    return await render(**treebank(tb, slug))


@bp.get("/<slug>/<chunk>")
async def get_chunk(req: Request, slug: str, chunk: str):
    f = CHUNKS / slug / f"{chunk}.xml"
    if not f.exists():
        raise NotFound(f"Unknown document {slug}/{chunk}")
    meta = corpus_index[slug]
    tb = PerseusTB(f, **meta)
    chunker = getattr(
        import_module("core.treebank.chunker"), corpus_index[slug].chunker
    )
    chunk_title = chunker.label(chunk)
    return await render(**treebank(tb, slug, chunk_title))
