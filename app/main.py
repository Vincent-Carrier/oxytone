from sanic import Sanic

from core.constants import STATIC


def create_app() -> Sanic:
    app = Sanic("oxytone")
    import app.routes as r

    app.blueprint(r.index)
    app.blueprint(r.read)
    app.blueprint(r.flashcards)
    # app.blueprint(r.nlp)
    app.static("/", STATIC, name="assets")
    return app


app = create_app()
