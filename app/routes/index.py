from typing import NamedTuple

from box import Box
from flask import Blueprint, render_template
from slugify import slugify
from core.corpus import corpus_index
from more_itertools import unique_everseen

bp = Blueprint("index", __name__, "/")


class AuthorCorpus(NamedTuple):
    name: str
    slug: str
    corpus: dict[str, Box]


def _author_corpus(author: str) -> AuthorCorpus:
    corpus = {
        slug: meta for slug, meta in corpus_index.items() if meta.author == author
    }
    return AuthorCorpus(author, slugify(author), corpus)


authors = [
    corpus := _author_corpus(author)
    for author in list(dict.fromkeys(meta.author for meta in corpus_index.values()))
]


@bp.get("/")
def get_index():
    return render_template("index.html", authors=authors)
