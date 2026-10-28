#!/usr/bin/env python3
"""Usage and time per arm of the workflow-value experiment, read after the runs.

    python3 measure.py <arm-folder>... [--projects ~/.claude/projects] [--json [FILE]]

For each arm folder:

  Claude tokens  Every Claude Code transcript under --projects (`*/*.jsonl`) and
                 every subagent transcript (`.../subagents/*.jsonl`). A record counts
                 for an arm when its RECORDED `cwd` is the arm folder or inside it —
                 never by the project-folder name, which flattens `/` and `-` alike
                 (`a-b` and `a/b` share a name; mind item 7 of the Soul System, where
                 a hyphenated name put a project in the wrong arm). Workers' worktrees
                 under `<arm>/.ai/` are inside the arm, so they count for it.
                 Each assistant message is counted ONCE, by message id: one turn
                 writes several records that carry the same id and usage.
                 Buckets: main (the session(s) the owner drives), subagent (a
                 subagents/ file, or a sidechain record), worker (a session whose
                 first recorded cwd is under `<arm>/.ai/` — /soul-workflow's workers).
  Wall time      first human prompt to last assistant record of the main session(s);
                 human prompts after the first are a proxy for owner interventions.
  Codex          `turn.completed` usage summed over `<arm>/.ai/workflow-runs/**/*codex*.log`
                 and the try logs of rows whose harness is codex (local Ollama rows
                 excluded: those are reported as wall minutes instead).
  Ollama         wall minutes of each Ollama-backed row in result.json / review.json.
  Cross-check    dispatch's own token totals from result.json / review.json, per
                 harness and model — shown, never added: the worker transcripts above
                 already hold the Claude workers' tokens.

Prints a table; --json prints JSON instead (or writes it to FILE).
"""

import argparse
import glob
import json
import os
import sys
from collections import defaultdict
from datetime import datetime

TOKEN_KEYS = ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens",
              "output_tokens")
NOT_HUMAN = ("<local-command", "<command-stdout", "<command-stderr", "Stop hook feedback",
             "[Request interrupted", "Caveat:", "<system-reminder>")


def load(path):
    """The JSON records of a .jsonl file; unreadable lines skipped."""
    out = []
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            for ln in fh:
                ln = ln.strip()
                if not ln:
                    continue
                try:
                    rec = json.loads(ln)
                except ValueError:
                    continue
                if isinstance(rec, dict):
                    out.append(rec)
    except OSError:
        pass
    return out


def transcripts(root):
    """(path, is_subagent_file) for every transcript under `root`."""
    for p in sorted(glob.glob(os.path.join(root, "*", "*.jsonl"))):
        yield p, False
    for p in sorted(set(glob.glob(os.path.join(root, "*", "**", "subagents", "**", "*.jsonl"),
                                  recursive=True))):
        yield p, True


def inside(cwd, arm):
    if not isinstance(cwd, str) or not cwd:
        return False
    cwd = os.path.normpath(cwd)
    return cwd == arm or cwd.startswith(arm + os.sep)


def ts(rec):
    t = rec.get("timestamp")
    if not isinstance(t, str):
        return None
    try:
        return datetime.fromisoformat(t.replace("Z", "+00:00"))
    except ValueError:
        return None


def is_human(rec):
    """A prompt the owner typed (or a slash command they ran) in a main session."""
    if rec.get("type") != "user" or rec.get("isSidechain") or rec.get("isMeta"):
        return False
    if "origin" in rec:  # recent Claude Code marks typed prompts origin.kind == "human"
        o = rec.get("origin")
        return isinstance(o, dict) and o.get("kind") == "human"
    content = (rec.get("message") or {}).get("content")
    if isinstance(content, list):
        if any(isinstance(b, dict) and b.get("type") == "tool_result" for b in content):
            return False
        content = "".join(b.get("text", "") for b in content
                          if isinstance(b, dict) and b.get("type") == "text")
    return isinstance(content, str) and bool(content.strip()) \
        and not content.lstrip().startswith(NOT_HUMAN)


def claude_usage(arm, root):
    """Token sums per bucket and model, and the main sessions' timing, for one arm."""
    msgs = {}            # message id -> (bucket, model, usage)
    main_sessions = defaultdict(lambda: {"first_prompt": None, "last_assistant": None,
                                         "prompts": 0})
    needle = arm  # cheap prefilter: a record for this arm names its path
    for path, sub_file in transcripts(root):
        try:
            with open(path, encoding="utf-8", errors="replace") as fh:
                if needle not in fh.read():
                    continue
        except OSError:
            continue
        recs = load(path)
        first_cwd = next((r["cwd"] for r in recs if isinstance(r.get("cwd"), str)), None)
        worker_file = inside(first_cwd, os.path.join(arm, ".ai"))
        for i, rec in enumerate(recs):
            if not inside(rec.get("cwd"), arm):
                continue
            side = sub_file or bool(rec.get("isSidechain"))
            bucket = "subagent" if side else "worker" if worker_file else "main"
            if bucket == "main":
                s = main_sessions[rec.get("sessionId") or path]
                t = ts(rec)
                if is_human(rec):
                    s["prompts"] += 1
                    if t and (s["first_prompt"] is None or t < s["first_prompt"]):
                        s["first_prompt"] = t
                if rec.get("type") == "assistant" and t and \
                        (s["last_assistant"] is None or t > s["last_assistant"]):
                    s["last_assistant"] = t
            if rec.get("type") != "assistant":
                continue
            msg = rec.get("message") or {}
            usage = msg.get("usage")
            model = msg.get("model") or "?"
            if not isinstance(usage, dict) or model == "<synthetic>":
                continue
            mid = msg.get("id") or rec.get("uuid") or "{}#{}".format(path, i)
            prev = msgs.get(mid)
            # Same id = same message: keep one copy, the one with the most output
            # (records written mid-stream can carry a partial count).
            if prev is None or (usage.get("output_tokens") or 0) >= \
                    (prev[2].get("output_tokens") or 0):
                msgs[mid] = (prev[0] if prev else bucket, model, usage)
    sums = defaultdict(lambda: defaultdict(int))  # (bucket, model) -> key -> n
    for bucket, model, usage in msgs.values():
        row = sums[(bucket, model)]
        for k in TOKEN_KEYS:
            row[k] += usage.get(k) or 0
        row["messages"] += 1
    rows = [dict(bucket=b, model=m, **v) for (b, m), v in sorted(sums.items())]
    starts = [s["first_prompt"] for s in main_sessions.values() if s["first_prompt"]]
    ends = [s["last_assistant"] for s in main_sessions.values() if s["last_assistant"]]
    prompts = sum(s["prompts"] for s in main_sessions.values())
    timing = {
        "main_sessions": len(main_sessions),
        "first_prompt": min(starts).isoformat() if starts else None,
        "last_assistant": max(ends).isoformat() if ends else None,
        "wall_min": round((max(ends) - min(starts)).total_seconds() / 60, 1)
        if starts and ends else None,
        "human_prompts": prompts,
        "prompts_after_first": max(prompts - 1, 0),
    }
    return rows, timing


def workflow_usage(arm):
    """Codex turn.completed sums, Ollama wall minutes, and dispatch's own totals."""
    runs = os.path.join(arm, ".ai", "workflow-runs")
    rows = []  # one per try / reviewer, from result.json and review.json
    for path in sorted(glob.glob(os.path.join(runs, "**", "result.json"), recursive=True)
                       + glob.glob(os.path.join(runs, "**", "review.json"), recursive=True)):
        try:
            with open(path, encoding="utf-8") as fh:
                doc = json.load(fh)
        except (OSError, ValueError):
            continue
        run_dir = os.path.dirname(path)
        if os.path.basename(path) == "result.json":
            entries = [dict(t, harness=doc.get("harness"), model=doc.get("model"))
                       for t in doc.get("tries") or [] if isinstance(t, dict)]
        else:
            entries = [r for r in doc.get("reviewers") or [] if isinstance(r, dict)]
        for e in entries:
            log = e.get("log")
            rows.append({"run": os.path.relpath(run_dir, runs), "file": os.path.basename(path),
                         "harness": e.get("harness") or "?", "model": e.get("model") or "?",
                         "wall_s": e.get("wall_s") or 0, "tokens_in": e.get("tokens_in"),
                         "tokens_out": e.get("tokens_out"),
                         "log": os.path.join(run_dir, os.path.basename(log)) if log else None})
    local = lambda h: "ollama" in (h or "")
    codex_logs = {p for p in glob.glob(os.path.join(runs, "**", "*codex*.log"), recursive=True)
                  if "ollama" not in os.path.basename(p)}
    codex_logs |= {r["log"] for r in rows if r["log"] and (r["harness"] or "").startswith("codex")
                   and not local(r["harness"]) and os.path.exists(r["log"])}
    codex = defaultdict(int)
    for p in sorted(codex_logs):
        for ev in load(p):
            u = ev.get("usage")
            if ev.get("type") == "turn.completed" and isinstance(u, dict):
                codex["turns"] += 1
                for k, v in u.items():
                    if isinstance(v, int) and not isinstance(v, bool):
                        codex[k] += v
    codex["logs"] = len(codex_logs)
    ollama = defaultdict(float)
    for r in rows:
        if local(r["harness"]):
            ollama[(r["harness"], r["model"])] += r["wall_s"] / 60
    cross = defaultdict(lambda: {"rows": 0, "tokens_in": 0, "tokens_out": 0,
                                 "unreported": 0, "wall_s": 0.0})
    for r in rows:
        c = cross[(r["harness"], r["model"])]
        c["rows"] += 1
        c["wall_s"] += r["wall_s"]
        if r["tokens_in"] is None and r["tokens_out"] is None:
            c["unreported"] += 1
        c["tokens_in"] += r["tokens_in"] or 0
        c["tokens_out"] += r["tokens_out"] or 0
    return {
        "codex": dict(codex),
        "ollama": [{"harness": h, "model": m, "wall_min": round(v, 1)}
                   for (h, m), v in sorted(ollama.items())],
        "dispatch_crosscheck": [dict(v, harness=h, model=m, wall_s=round(v["wall_s"], 1))
                                for (h, m), v in sorted(cross.items())],
    }


def measure(arm, root):
    arm = os.path.realpath(arm)
    rows, timing = claude_usage(arm, root)
    totals = defaultdict(lambda: defaultdict(int))
    for r in rows:
        for k in TOKEN_KEYS + ("messages",):
            totals[r["model"]][k] += r[k]
    groups = {"main": defaultdict(int), "subagent+worker": defaultdict(int)}
    for r in rows:
        g = groups["main" if r["bucket"] == "main" else "subagent+worker"]
        for k in TOKEN_KEYS + ("messages",):
            g[k] += r[k]
    return {"arm": arm, "claude": rows,
            "claude_per_model": {m: dict(v) for m, v in sorted(totals.items())},
            "claude_main_vs_rest": {k: dict(v) for k, v in groups.items()},
            "time": timing, **workflow_usage(arm)}


def table(res):
    out = ["== {}".format(res["arm"])]
    hdr = "{:<16} {:<28} {:>10} {:>12} {:>13} {:>10} {:>6}"
    out.append(hdr.format("bucket", "model", "input", "cache-create", "cache-read", "output", "msgs"))
    line = lambda b, m, r: hdr.format(b, m, r.get("input_tokens", 0),
                                      r.get("cache_creation_input_tokens", 0),
                                      r.get("cache_read_input_tokens", 0),
                                      r.get("output_tokens", 0), r.get("messages", 0))
    for r in res["claude"]:
        out.append(line(r["bucket"], r["model"], r))
    for m, r in res["claude_per_model"].items():
        out.append(line("TOTAL", m, r))
    for g, r in res["claude_main_vs_rest"].items():
        out.append(line(g, "(all models)", r))
    t = res["time"]
    out.append("wall: {} min (first prompt {} -> last assistant {}); main sessions {}; human "
               "prompts {} ({} after the first)".format(
                   t["wall_min"], t["first_prompt"], t["last_assistant"], t["main_sessions"],
                   t["human_prompts"], t["prompts_after_first"]))
    c = res["codex"]
    out.append("codex: {} log(s), {} turn(s): {}".format(
        c.get("logs", 0), c.get("turns", 0),
        ", ".join("{} {}".format(k, v) for k, v in c.items() if k not in ("logs", "turns"))
        or "no usage"))
    for o in res["ollama"]:
        out.append("ollama: {} {} — {} wall min".format(o["harness"], o["model"], o["wall_min"]))
    for x in res["dispatch_crosscheck"]:
        out.append("dispatch cross-check (not added): {} {} rows {} in {} out {} "
                   "(unreported {}) wall {} s".format(x["harness"], x["model"], x["rows"],
                                                    x["tokens_in"], x["tokens_out"],
                                                    x["unreported"], x["wall_s"]))
    return "\n".join(out)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("arms", nargs="+")
    ap.add_argument("--projects", default=os.path.expanduser("~/.claude/projects"))
    ap.add_argument("--json", nargs="?", const="-", default=None,
                    help="print JSON instead of the table, or write it to FILE")
    a = ap.parse_args(argv)
    for arm in a.arms:
        if not os.path.isdir(arm):
            ap.error("not a folder: {}".format(arm))
    results = [measure(arm, a.projects) for arm in a.arms]
    if a.json is None:
        print("\n\n".join(table(r) for r in results))
    elif a.json == "-":
        print(json.dumps(results, indent=2))
    else:
        with open(a.json, "w", encoding="utf-8") as fh:
            json.dump(results, fh, indent=2)
            fh.write("\n")
        print("\n\n".join(table(r) for r in results))
    return 0


if __name__ == "__main__":
    sys.exit(main())
