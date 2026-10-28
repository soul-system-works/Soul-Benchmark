#!/usr/bin/env python3
"""Run `node check.mjs` in a game folder the way the Soul System runs a workflow's
check: under bubblewrap, via its tools/confine.py (confine_argv + clean_env) — the
filesystem read-only except the game folder, no network, secret folders hidden.

    python3 confined-check.py <game-folder> [--soul /path/to/Soul-System]

It runs the game folder's own check.mjs (copy it in first for a control). Exit code is
check.mjs's; 3 when confine_argv returns None (no bwrap, or not Linux). Proves that the
check works where /soul-workflow build-verify's workers and recorder will run it.
"""

import argparse
import importlib.util
import os
import subprocess
import sys

sys.dont_write_bytecode = True  # leave no __pycache__ in the Soul System checkout


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("game")
    ap.add_argument("--soul", default="/mnt/d/Projects/soul/Soul-System")
    a = ap.parse_args()
    spec = importlib.util.spec_from_file_location(
        "soul_confine", os.path.join(a.soul, "tools", "confine.py"))
    confine = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(confine)
    game = os.path.realpath(a.game)
    argv = confine.confine_argv(["node", "check.mjs"], game)
    if argv is None:
        print("confine_argv returned None: cannot confine here", file=sys.stderr)
        return 3
    print("confined: " + " ".join(argv[: argv.index("node")]), file=sys.stderr)
    return subprocess.run(argv, cwd=game, env=confine.clean_env()).returncode


if __name__ == "__main__":
    sys.exit(main())
