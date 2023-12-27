from json import JSONDecoder
from operator import itemgetter
from os import listdir
from typing import NamedTuple
from box import Box
from flask import Blueprint, render_template, request
from slugify import slugify
from werkzeug.exceptions import NotFound

from core.constants import CHUNKS, DATA
from core.ref import Ref
from core.render import HtmlPartialRenderer
from core.treebank.perseus import PerseusTB
from core.treebank.treebank import Metadata, Treebank
from core.corpus import corpus

bp = Blueprint("read", __name__, url_prefix="/")


json_str = (CHUNKS / "index.json").read_text()
index = Box(JSONDecoder().decode(json_str))


class AuthorCorpus(NamedTuple):
    name: str
    slug: str
    corpus: Box


def author_corpus(author: str) -> AuthorCorpus:
    corpus = {slug: meta for slug, meta in index.items() if meta.author == author}
    return AuthorCorpus(author, slugify(author), Box(corpus))


homer = author_corpus("Homer")
for doc in homer.corpus.values():
    doc.get_book = lambda span: Ref.parse(span).start.chapter
    doc.get_chunk_title = lambda span: f"Book {doc.get_book(span)}"

aeschylus = author_corpus("Aeschylus")

authors = [homer, aeschylus]


@bp.route("/")
def get_index():
    return render_template("index.html", authors=authors)


def render_reader(tb: Treebank, slug: str, span: str | None = None):
    body = HtmlPartialRenderer(tb).render()
    meta = Box(index[slug])
    chunk_title = meta.get_chunk_title(span) if span else None  # type: ignore
    return render_template("reader.html", body=body, chunk_title=chunk_title, **meta)


@bp.route("/read/<slug>")
def get_treebank(slug: str):
    try:
        tb = corpus[slug]
    except KeyError:
        raise NotFound(f"Unknown document {slug}")
    return render_reader(tb, slug)


@bp.route("/read/<slug>/<span>")
def get_chunk(slug: str, span: str):
    f = CHUNKS / slug / f"{span}.xml"
    if not f.exists():
        raise NotFound(f"Unknown document {slug}/{span}")
    tb = PerseusTB(f, None, None)  # type: ignore
    return render_reader(tb, slug, span)
