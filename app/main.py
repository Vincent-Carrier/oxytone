from flask import Blueprint, Flask
from rich import traceback
from app.routes.flashcards import bp as flashcards_bp
from app.routes.read import bp as read_bp
from app.routes.index import bp as index_bp

from core.constants import NODE_MODULES


traceback.install()


app = Flask(__name__, static_url_path="/")
app.jinja_options.update(
    autoescape=False,
    lstrip_blocks=True,
    trim_blocks=True,
)
app.debug = True

app.register_blueprint(index_bp)
app.register_blueprint(read_bp)
app.register_blueprint(flashcards_bp)
app.register_blueprint(
    Blueprint(
        "fonts",
        __name__,
        static_folder=str(NODE_MODULES / "@fontsource/"),
        static_url_path="/@fontsource",
    )
)

app.run()
