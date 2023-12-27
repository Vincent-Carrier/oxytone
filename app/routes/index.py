from json import JSONDecoder
from typing import NamedTuple

from box import Box
from flask import Blueprint, render_template
from slugify import slugify
from core.constants import CHUNKS
from core.ref import Ref

bp = Blueprint("index", __name__, "/")

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
aeschylus = author_corpus("Aeschylus")
authors = [homer, aeschylus]


@bp.route("/")
def get_index():
    return render_template("index.html", authors=authors)
