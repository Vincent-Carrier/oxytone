from flask import Blueprint, Response, request


bp = Blueprint("flashcards", __name__, url_prefix="/flashcards")


@bp.post("/")
def flashcards():
    r = request.json
    print(r)
    return Response(status=200)
