#!/usr/bin/env python3
"""Descriptive run tally for the 2026-10-21 campaign (no quality scoring).

Usage: tally.py <glob under ~/soul-bench-arms/runs/>   e.g. tally.py 'r-*-claude-opus'
One row per run dir: sessions, errors, timeouts, notional $, wall, turns, denials,
sentinel (chains only; probe prompts ask for none), short replies (<200 chars, June's validity scan), Soul gate events.
"""
import glob, json, os, sys

ROOT = os.path.expanduser("~/soul-bench-arms/runs")


def sessions(d):
    log = os.path.join(d, "log")
    if os.path.exists(os.path.join(log, "out.json")) or os.path.exists(os.path.join(log, "wall")):
        return [("out", os.path.join(log, "out.json"), os.path.join(log, "wall"))]
    walls = sorted(glob.glob(os.path.join(log, "inc*.wall")))
    return [(os.path.basename(w)[:-5], w[:-5] + ".json", w) for w in walls]


def gate_events(d):
    # where the Soul hook logs; one gate fire writes two lines (flagged + verdict)
    p = os.path.join(d, "repo", ".soul", "events.jsonl")
    return sum(1 for _ in open(p)) if os.path.exists(p) else 0


print("| run | sessions | errors | timeouts | notional $ | wall (min) | turns | denials | sentinel | short | gate |")
print("|---|---|---|---|---|---|---|---|---|---|---|")
for d in sorted(glob.glob(os.path.join(ROOT, sys.argv[1]))):
    ss = sessions(d)
    err = to = turns = den = sent = short = 0
    cost = wall = 0.0
    for name, js, w in ss:
        try:
            wall += float(open(w).read().strip())
        except Exception:
            pass
        try:
            j = json.load(open(js))
        except Exception:
            to += 1  # no JSON: the 1500/1200 s timeout fired (rc 124)
            continue
        r = j.get("result") or ""
        err += bool(j.get("is_error"))
        cost += j.get("total_cost_usd") or 0
        turns += j.get("num_turns") or 0
        den += len(j.get("permission_denials") or [])
        sent += "Governing doctrine" in r
        short += len(r) < 200
    print(f"| {os.path.basename(d)} | {len(ss)} | {err} | {to} | {cost:.2f} | {wall/60:.1f} | "
          f"{turns} | {den} | {sent if name != "out" else "–"}{"/" + str(len(ss)) if name != "out" else ""} | {short} | {gate_events(d)} |")
