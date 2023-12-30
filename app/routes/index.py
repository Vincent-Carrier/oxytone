from typing import NamedTuple

from box import Box
from flask import Blueprint, render_template
from slugify import slugify
from core.constants import CHUNKS
from core.corpus import corpus

bp = Blueprint("index", __name__, "/")


def _get_chunks(slug: str) -> list[int]:
    dir = CHUNKS / slug
    return sorted(int(f.name.rstrip(".xml")) for f in dir.iterdir())


index = {
    slug: Box(
        tb.meta | {"chunks": _get_chunks(slug) if tb.meta.get("chunker") else None}
    )
    for slug, tb in corpus.items()
}


class AuthorCorpus(NamedTuple):
    name: str
    slug: str
    corpus: Box


def _author_corpus(author: str) -> AuthorCorpus:
    corpus = {slug: meta for slug, meta in index.items() if meta.author == author}
    return AuthorCorpus(author, slugify(author), Box(corpus))


authors = [
    corpus := _author_corpus(author)
    for author in [
        "Homer",
        # "Hesiod",
        # "Homeric Hymns",
        "Aeschylus",
        # "Sophocles",
        # "Euripides",
        "Herodotus",
        # "Thucydides",
        "Plato",
        # "Xenophon",
    ]
]


@bp.route("/")
def get_index():
    return render_template("index.html", authors=authors)
