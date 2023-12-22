from json import JSONDecoder
from os import listdir
from typing import NamedTuple
from flask import Blueprint, render_template, request
from werkzeug.exceptions import NotFound

from core.constants import DATA
from core.render import HtmlPartialRenderer
from core.treebank.perseus import PerseusTB
from core.treebank.treebank import Metadata

bp = Blueprint("corpus", __name__, url_prefix="/")


class Doc(NamedTuple):
    slug: str
    subdocs: list[str]


index: dict = JSONDecoder().decode((DATA / "out/index.json").read_text())


@bp.route("/")
def get_index():
    for slug in index.keys():
        index[slug]["spans"] = [
            f.rsplit(".", 1)[0] for f in listdir(DATA / "out" / slug)
        ]
    return render_template("index.html", index=index)


@bp.route("/<slug>/<span>")
def get_treebank(slug: str, span: str):
    f = DATA / "out" / slug / f"{span}.xml"
    if not f.exists():
        raise NotFound(f"Unknown treebank {slug}/{span}")
    tb = PerseusTB(f, None, None, None)  # type: ignore
    body = HtmlPartialRenderer(tb).render()
    meta = index[slug]
    return render_template("treebank.html", body=body, **meta)
