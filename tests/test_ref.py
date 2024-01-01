from pytest import mark

from core.ref import BCV, CV, RefPoint


lt_tests = [
    (BCV(1, 1, 1), BCV(1, 1, 1), False),
    (BCV(1, 1, 1), BCV(1, 2, 1), True),
    (BCV(1, 1, 1), BCV(2, 1, 1), True),
    (BCV(1, 1, 1), BCV(1, 1, 2), True),
]


@mark.parametrize("a, b, expected", lt_tests)
def test_lt_ref(a: RefPoint, b: RefPoint, expected: bool):
    assert (a < b) == expected


def test_parse():
    assert BCV.parse("1.1.1") == BCV(1, 1, 1)
    assert CV.parse("1.1") == CV(1, 1)
