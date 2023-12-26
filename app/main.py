from flask import Flask, render_template
from rich import traceback

from . import routes

traceback.install()


app = Flask(__name__, static_url_path="/")
app.jinja_options.update(
    autoescape=False,
    lstrip_blocks=True,
    trim_blocks=True,
)
app.debug = True


app.register_blueprint(routes.corpus)
app.register_blueprint(routes.flashcards)
app.register_blueprint(routes.fonts)
app.register_blueprint(routes.shoelace)

app.run()
