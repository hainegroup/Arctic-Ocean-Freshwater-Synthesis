import pytest
from arctic_ocean_freshwater_synthesis.dummy import dummy_foo


def test_dummy():
    assert dummy_foo(4) == (4 + 4)
