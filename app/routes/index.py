from typing import NamedTuple

from box import Box
from sanic import Blueprint, Request, Sanic
from slugify import slugify
from core.corpus import corpus_index

bp = Blueprint("index", "/")
app = Sanic.get_app("oxytone")


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
@app.ext.template("index.html")
async def get_index(req: Request):
    return dict(authors=authors)
