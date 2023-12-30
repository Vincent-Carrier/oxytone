from json import JSONDecoder
from typing import NamedTuple

from box import Box
from flask import Blueprint, render_template
from slugify import slugify
from core.constants import TREEBANKS

bp = Blueprint("index", __name__, "/")

json_str = (TREEBANKS / "index.json").read_text()
index = Box(JSONDecoder().decode(json_str))


class AuthorCorpus(NamedTuple):
    name: str
    slug: str
    corpus: Box


def author_corpus(author: str) -> AuthorCorpus:
    corpus = {slug: meta for slug, meta in index.items() if meta.author == author}
    return AuthorCorpus(author, slugify(author), Box(corpus))


authors = [
    corpus := author_corpus(author)
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
