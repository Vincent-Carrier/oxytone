from typing import Iterator

from flask.testing import FlaskClient
from pytest import mark
from core.corpus import corpus_index


def all_slugs() -> Iterator[str]:
    for doc in corpus_index.values():
        if doc.chunks:
            yield from (f"{doc.slug}/{chunk}" for chunk in doc.chunks)
        else:
            yield doc.slug


@mark.skip
@mark.serial
@mark.parametrize("slug", all_slugs())
def test_get_read(client: FlaskClient, slug: str):
    res = client.get(f"/read/{slug}")
    assert res.status_code == 200
