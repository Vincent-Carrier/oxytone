from json import JSONDecoder
from operator import itemgetter
from os import listdir
from typing import NamedTuple
from box import Box
from flask import Blueprint, render_template, request
from werkzeug.exceptions import NotFound

from core.constants import CHUNKS, DATA
from core.ref import Ref
from core.render import HtmlPartialRenderer
from core.treebank.perseus import PerseusTB
from core.treebank.treebank import Metadata, Treebank
from core.corpus import corpus

bp = Blueprint("read", __name__, url_prefix="/")


class Doc(NamedTuple):
    slug: str
    subdocs: list[str]


json_str = (CHUNKS / "index.json").read_text()
index = Box(JSONDecoder().decode(json_str))

homer = itemgetter("iliad", "odyssey")(index)
for doc in homer:
    doc.get_book = lambda span: Ref.parse(span).start.chapter

aeschylus = itemgetter("agamemnon", "libationbearers", "eumenides")(index)


@bp.route("/")
def get_index():
    return render_template("index.html", homer=homer, aeschylus=aeschylus)


def render_reader(tb: Treebank, slug: str, span: str | None = None):
    body = HtmlPartialRenderer(tb).render()
    meta = Box(index[slug])
    subdoc = None
    if span:
        ref = Ref.parse(span)
        subdoc = f"Book {ref.chapter}"  # type: ignore TODO
    return render_template("reader.html", body=body, subdoc=subdoc, **meta)


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
    return render_reader(tb, slug)
