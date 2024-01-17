from typing import NamedTuple

from box import Box
from sanic import Blueprint, Request
from slugify import slugify
from app.jinja import template
from core.corpus import corpus_index

bp = Blueprint("index", "/")


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

render = template("index")


@bp.get("/")
async def get_index(req: Request):
    return await render(authors=authors)
