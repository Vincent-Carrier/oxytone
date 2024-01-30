import uuid

from sanic import BadRequest, Blueprint, Request, Sanic, redirect

from app.jinja import template
from core.render import HtmlPartialRenderer
from core.treebank.nlp import NLPTreebank

bp = Blueprint("nlp", url_prefix="/nlp")
app = Sanic.get_app("oxytone")
app.ctx.nlp = {}

render_reader = template("reader")
render_create = template("create_nlp")


@bp.get("/")
async def create_nlp(req: Request):
    return await render_create()


@bp.post("/")
async def post_nlp(req: Request):
    assert req.form
    body = req.form.get("body")
    if not body:
        return BadRequest("No body in form")
    slug = uuid.uuid4()
    app.ctx.nlp[str(slug)] = body
    return redirect(f"/nlp/{slug}")  # TODO: 201 doesn't work for some reason


@bp.get("/<slug>")
async def show_nlp(req: Request, slug: str):
    form_body = app.ctx.nlp[slug]  # TODO: LRU cache
    tb = NLPTreebank(form_body)
    body = HtmlPartialRenderer(tb).render()
    return await render_reader(body=body, **tb.meta)
