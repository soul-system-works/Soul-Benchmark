import json

import pytest

from stationcfg.load import load


def test_json(tmp_path):
    p = tmp_path / "s.json"
    p.write_text(json.dumps({"station_id": "A1", "lat": 1.0, "lon": 2.0, "sample_seconds": 60}))
    assert load(p)["station_id"] == "A1"


def test_missing_key(tmp_path):
    p = tmp_path / "s.json"
    p.write_text(json.dumps({"station_id": "A1"}))
    with pytest.raises(ValueError):
        load(p)
