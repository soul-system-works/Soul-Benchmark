"""Load a station config file into a dict and validate it."""
import json
from pathlib import Path

REQUIRED = {"station_id", "lat", "lon", "sample_seconds"}


def load(path):
    path = Path(path)
    if path.suffix == ".json":
        data = json.loads(path.read_text())
    else:
        raise ValueError(f"unsupported config format: {path.suffix}")
    missing = REQUIRED - data.keys()
    if missing:
        raise ValueError(f"missing keys: {sorted(missing)}")
    return data
