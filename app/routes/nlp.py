from sanic import Blueprint, Request

from app.jinja import template
from core.render import HtmlPartialRenderer
from core.treebank.nlp import NLPTreebank

bp = Blueprint("nlp", url_prefix="/nlp")

render_reader = template("reader")
render_create = template("create_nlp")

text = """τί μάλιστα σοὶ πρὸς βουλευτήριον; ἢ δῆλα δὴ ὅτι παιδεύσεως καὶ φιλοσοφίας ἐπὶ τέλει ἡγῇ εἶναι, καὶ ὡς ἱκανῶς ἤδη ἔχων ἐπὶ τὰ μείζω ἐπινοεῖς τρέπεσθαι, καὶ ἄρχειν ἡμῶν, ὦ θαυμάσιε, ἐπιχειρεῖς τῶν πρεσβυτέρων τηλικοῦτος ὤν, ἵνα μὴ ἐκλίπῃ ὑμῶν ἡ οἰκία ἀεί τινα ἡμῶν ἐπιμελητὴν παρεχομένη;"""


@bp.get("/")
async def create_nlp(req: Request):
    return await render_create()


@bp.get("/<slug>")
async def show_nlp(req: Request, slug: str):
    tb = NLPTreebank(text)
    body = HtmlPartialRenderer(tb).render()
    return await render_reader(body=body, **tb.meta)
