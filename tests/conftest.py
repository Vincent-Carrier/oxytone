from flask import Flask
from pytest import fixture

from app.main import create_app


@fixture(scope="module")
def app():
    app = create_app()
    app.testing = True
    yield app


@fixture(scope="module")
def client(app: Flask):
    return app.test_client()
