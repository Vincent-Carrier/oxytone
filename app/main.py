from os import environ
from sanic import Sanic

from core.constants import STATIC


def create_app(dev: bool) -> Sanic:
    app = Sanic("oxytone")
    app.auto_reload = dev
    from app.routes.flashcards import bp as flashcards_bp
    from app.routes.read import bp as read_bp
    from app.routes.index import bp as index_bp

    app.blueprint(index_bp)
    app.blueprint(read_bp)
    app.blueprint(flashcards_bp)
    app.static("/", STATIC, name="assets")
    return app


app = create_app(dev=environ.get("ENV") == "development")
