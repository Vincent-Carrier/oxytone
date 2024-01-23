from importlib import import_module

from box import Box
from sanic import Blueprint, NotFound, Request, Sanic

from app.jinja import template
from core.constants import CHUNKS
from core.corpus import corpus, corpus_index
from core.render import HtmlPartialRenderer
from core.treebank.nlp import NLPTreebank
from core.treebank.perseus import PerseusTB

bp = Blueprint("nlp", url_prefix="/nlp")

render = template("reader")

text = """τί μάλιστα σοὶ πρὸς βουλευτήριον; ἢ δῆλα δὴ ὅτι παιδεύσεως καὶ φιλοσοφίας ἐπὶ τέλει ἡγῇ εἶναι, καὶ ὡς ἱκανῶς ἤδη ἔχων ἐπὶ τὰ μείζω ἐπινοεῖς τρέπεσθαι, καὶ ἄρχειν ἡμῶν, ὦ θαυμάσιε, ἐπιχειρεῖς τῶν πρεσβυτέρων τηλικοῦτος ὤν, ἵνα μὴ ἐκλίπῃ ὑμῶν ἡ οἰκία ἀεί τινα ἡμῶν ἐπιμελητὴν παρεχομένη;"""


@bp.get("/<slug>")
async def get_nlp(req: Request, slug: str):
    tb = NLPTreebank(text)
    body = HtmlPartialRenderer(tb).render()
    return await render(body=body, **tb.meta)
