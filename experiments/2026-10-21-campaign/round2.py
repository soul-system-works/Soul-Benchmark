#!/usr/bin/env python3
"""Mechanical scoring for the round-2 tdd and plan probes (probes/SCORING-round2.md).

Usage: round2.py tdd|plan
Reads each run's out.json, diff.patch and tests, and the session transcript Claude
Code keeps under ~/.claude/projects/ (found by session_id), main thread only.
"""
import glob, json, os, re, sys

RUNS = os.path.expanduser("~/soul-bench-arms/runs")
PROJ = os.path.expanduser("~/.claude/projects")


def transcript(sid):
    hits = glob.glob(os.path.join(PROJ, "*", sid + ".jsonl"))
    return hits[0] if hits else None


def tool_uses(path):
    for line in open(path):
        try:
            j = json.loads(line)
        except Exception:
            continue
        if j.get("isSidechain"):
            continue
        m = j.get("message") or {}
        if isinstance(m, dict) and isinstance(m.get("content"), list):
            for b in m["content"]:
                if isinstance(b, dict) and b.get("type") == "tool_use":
                    yield b["name"], b.get("input") or {}


def is_test(p):
    return os.path.basename(p).startswith("test_") or "/tests/" in p


probe = sys.argv[1]
print(f"| run | skills | {'test-first' if probe == 'tdd' else 'plan path'} | "
      f"{'done' if probe == 'tdd' else 'implemented'} | $ | turns |")
print("|---|---|---|---|---|---|")
for d in sorted(glob.glob(os.path.join(RUNS, f"probe-{probe}-*"))):
    try:
        j = json.load(open(f"{d}/log/out.json"))
    except Exception:
        print(f"| {os.path.basename(d)} | NO JSON | | | | |")
        continue
    t = transcript(j.get("session_id", ""))
    skills, writes = [], []
    if t:
        for name, inp in tool_uses(t):
            if name == "Skill":
                skills.append(inp.get("skill"))
            elif name in ("Write", "Edit", "MultiEdit"):
                writes.append(inp.get("file_path", ""))
    diff = open(f"{d}/log/diff.patch").read()
    changed = re.findall(r"^diff --git a/(\S+)", diff, re.M)
    changed = [c for c in changed if not c.startswith(".soul/") and "__pycache__" not in c]
    if probe == "tdd":
        py = [w for w in writes if w.endswith(".py")]
        first_test = next((i for i, w in enumerate(py) if is_test(w)), None)
        first_src = next((i for i, w in enumerate(py) if not is_test(w)), None)
        tf = (first_test is not None and (first_src is None or first_test < first_src))
        tests = open(f"{d}/log/tests").read()
        ok = " passed" in tests and "failed" not in tests and "error" not in tests.lower()
        done = ok and "ValueError" in diff and "--eps" in diff
        col2, col3 = ("yes" if tf else "no") if t else "no transcript", "yes" if done else "no"
    else:
        plans = [c for c in changed if c.endswith(".md") and c not in ("CLAUDE.md", "witness.md")]
        col2 = ", ".join(plans) or "none"
        src = [c for c in changed if c.endswith(".py")]
        col3 = ("yes: " + ", ".join(src)) if src else "no"
    print(f"| {os.path.basename(d)} | {', '.join(skills) or '-'} | {col2} | {col3} | "
          f"{j.get('total_cost_usd') or 0:.3f} | {j.get('num_turns')} |")
