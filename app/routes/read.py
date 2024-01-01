from importlib import import_module
from box import Box
from flask import Blueprint, render_template
from werkzeug.exceptions import NotFound

from core.constants import CHUNKS
from core.ref import Ref
from core.render import HtmlPartialRenderer
from core.treebank.perseus import PerseusTB
from core.treebank.treebank import Treebank
from core.corpus import corpus
from .index import corpus_index

bp = Blueprint("read", __name__, url_prefix="/read")


def render_reader(tb: PerseusTB, slug: str, chunk_title: str | None = None):
    body = HtmlPartialRenderer(tb).render()
    meta = Box(corpus_index[slug])
    return render_template("reader.html", body=body, chunk_title=chunk_title, **meta)


@bp.get("/<slug>")
def get_treebank(slug: str):
    try:
        tb = corpus[slug]
    except KeyError:
        raise NotFound(f"Unknown document {slug}")
    return render_reader(tb, slug)


@bp.get("/<slug>/<chunk>")
def get_chunk(slug: str, chunk: str):
    f = CHUNKS / slug / f"{chunk}.xml"
    if not f.exists():
        raise NotFound(f"Unknown document {slug}/{chunk}")
    tb = PerseusTB(f, None, None)  # type: ignore
    chunker = getattr(
        import_module("core.treebank.chunker"), corpus_index[slug].chunker
    )
    chunk_title = chunker.label(chunk)
    return render_reader(tb, slug, chunk_title)
