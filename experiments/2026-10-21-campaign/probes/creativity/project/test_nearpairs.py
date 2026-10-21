from nearpairs import close_pairs


def test_finds_close_pair():
    assert close_pairs([(0, 0), (0.5, 0), (10, 10)], 1.0) == [(0, 1)]


def test_none_close():
    assert close_pairs([(0, 0), (5, 5)], 1.0) == []
