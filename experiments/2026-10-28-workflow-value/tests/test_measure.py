#!/usr/bin/env python3
"""Tests for measure.py on synthetic transcripts: python3 tests/test_measure.py"""

import io
import json
import os
import shutil
import sys
import tempfile
import unittest
from contextlib import redirect_stdout

sys.dont_write_bytecode = True
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import measure  # noqa: E402


def write_jsonl(path, recs):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        for r in recs:
            fh.write(json.dumps(r) + "\n")


_uuid = iter(range(10**6))


def asst(cwd, mid, model="claude-opus-5-5", out=10, inp=1, cc=100, cr=1000, t="2026-10-28T10:00:00Z",
         session="s1", side=False):
    # Every record has its own uuid, as in real transcripts; only message.id is shared.
    return {"type": "assistant", "cwd": cwd, "sessionId": session, "timestamp": t,
            "isSidechain": side, "uuid": "u{}".format(next(_uuid)),
            "message": {"id": mid, "model": model,
                        "usage": {"input_tokens": inp, "cache_creation_input_tokens": cc,
                                  "cache_read_input_tokens": cr, "output_tokens": out}}}


def human(cwd, text, t, session="s1"):
    return {"type": "user", "cwd": cwd, "sessionId": session, "timestamp": t,
            "isSidechain": False, "origin": {"kind": "human"},
            "message": {"role": "user", "content": text}}


def tool_result(cwd, t, session="s1"):
    return {"type": "user", "cwd": cwd, "sessionId": session, "timestamp": t,
            "isSidechain": False,
            "message": {"role": "user", "content": [{"type": "tool_result", "content": "ok"}]}}


class MeasureTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp(prefix="wfv-measure-")
        self.root = os.path.join(self.tmp, "projects")
        # The arm folder, and a different folder whose flattened project name is the
        # same: <tmp>/arms/C-x and <tmp>/arms/C/x both flatten to ...-arms-C-x.
        self.arm = os.path.join(self.tmp, "arms", "C-x")
        self.other = os.path.join(self.tmp, "arms", "C", "x")
        os.makedirs(self.arm)
        os.makedirs(self.other)
        self.flat = self.arm.replace("/", "-")

    def tearDown(self):
        shutil.rmtree(self.tmp)

    def run_measure(self):
        return measure.measure(self.arm, self.root)

    def test_dedupe_by_message_id(self):
        # One turn: three records with one message id (text, tool_use, tool_use).
        write_jsonl(os.path.join(self.root, self.flat, "s1.jsonl"), [
            human(self.arm, "Build the game", "2026-10-28T10:00:00Z"),
            asst(self.arm, "msg_1", out=5, t="2026-10-28T10:00:05Z"),
            asst(self.arm, "msg_1", out=50, t="2026-10-28T10:00:06Z"),
            asst(self.arm, "msg_1", out=50, t="2026-10-28T10:00:07Z"),
            asst(self.arm, "msg_2", out=7, t="2026-10-28T10:01:00Z"),
        ])
        res = self.run_measure()
        tot = res["claude_per_model"]["claude-opus-5-5"]
        self.assertEqual(tot["messages"], 2)
        self.assertEqual(tot["output_tokens"], 57)   # 50 (max of msg_1) + 7
        self.assertEqual(tot["cache_read_input_tokens"], 2000)
        self.assertEqual(tot["input_tokens"], 2)

    def test_subagent_files_counted_as_subagent(self):
        write_jsonl(os.path.join(self.root, self.flat, "s1.jsonl"), [
            human(self.arm, "go", "2026-10-28T10:00:00Z"),
            asst(self.arm, "m_main", out=10, t="2026-10-28T10:00:01Z"),
        ])
        write_jsonl(os.path.join(self.root, self.flat, "s1", "subagents", "agent-a1.jsonl"), [
            asst(self.arm, "m_sub1", model="claude-sonnet-5-5", out=20, side=True),
            asst(self.arm, "m_sub1", model="claude-sonnet-5-5", out=20, side=True),
            # No sidechain flag: the subagents/ location alone makes it a subagent's.
            asst(self.arm, "m_sub2", model="claude-sonnet-5-5", out=30, side=False),
        ])
        res = self.run_measure()
        rows = {(r["bucket"], r["model"]): r for r in res["claude"]}
        self.assertEqual(rows[("subagent", "claude-sonnet-5-5")]["output_tokens"], 50)
        self.assertEqual(rows[("subagent", "claude-sonnet-5-5")]["messages"], 2)
        self.assertEqual(res["claude_main_vs_rest"]["main"]["output_tokens"], 10)
        self.assertEqual(res["claude_main_vs_rest"]["subagent+worker"]["output_tokens"], 50)
        # A subagent's records never set the main session's clock.
        self.assertEqual(res["time"]["main_sessions"], 1)

    def test_cwd_classification_not_folder_name(self):
        # Lives in a project folder named exactly like the arm, but recorded in the
        # other folder: must NOT count.
        write_jsonl(os.path.join(self.root, self.flat, "s9.jsonl"), [
            human(self.other, "elsewhere", "2026-10-28T09:00:00Z", session="s9"),
            asst(self.other, "m_other", out=999, session="s9"),
        ])
        # A sibling whose path starts with the arm's path: must NOT count either.
        sib = self.arm + "-old"
        write_jsonl(os.path.join(self.root, sib.replace("/", "-"), "s8.jsonl"), [
            human(sib, "sibling", "2026-10-28T08:00:00Z", session="s8"),
            asst(sib, "m_sib", out=555, session="s8"),
        ])
        # Lives in an oddly named project folder, but recorded in the arm: counts.
        write_jsonl(os.path.join(self.root, "-renamed-folder", "s1.jsonl"), [
            human(self.arm, "go", "2026-10-28T10:00:00Z"),
            asst(self.arm, "m_arm", out=11, t="2026-10-28T10:00:30Z"),
        ])
        res = self.run_measure()
        self.assertEqual(res["claude_per_model"]["claude-opus-5-5"]["output_tokens"], 11)
        self.assertEqual(res["time"]["human_prompts"], 1)

    def test_worktree_cwd_counts_as_worker_for_its_arm(self):
        wt = os.path.join(self.arm, ".ai", "worktrees", "run1-1")
        write_jsonl(os.path.join(self.root, wt.replace("/", "-").replace(".", "-"), "w1.jsonl"), [
            {"type": "user", "cwd": wt, "sessionId": "w1", "timestamp": "2026-10-28T10:05:00Z",
             "message": {"role": "user", "content": "worker brief"}, "origin": {"kind": "human"}},
            asst(wt, "m_w1", model="claude-sonnet-5-5", out=40, session="w1",
                 t="2026-10-28T10:20:00Z"),
        ])
        write_jsonl(os.path.join(self.root, self.flat, "s1.jsonl"), [
            human(self.arm, "/soul-workflow build-verify Build the game", "2026-10-28T10:00:00Z"),
            asst(self.arm, "m_main", out=10, t="2026-10-28T10:10:00Z"),
        ])
        res = self.run_measure()
        rows = {(r["bucket"], r["model"]): r for r in res["claude"]}
        self.assertEqual(rows[("worker", "claude-sonnet-5-5")]["output_tokens"], 40)
        # The worker's prompt is not an owner intervention and its clock is not the arm's.
        self.assertEqual(res["time"]["human_prompts"], 1)
        self.assertEqual(res["time"]["wall_min"], 10.0)

    def test_wall_time_and_prompts(self):
        write_jsonl(os.path.join(self.root, self.flat, "s1.jsonl"), [
            human(self.arm, "Build the game", "2026-10-28T10:00:00Z"),
            asst(self.arm, "m1", t="2026-10-28T10:00:10Z"),
            tool_result(self.arm, "2026-10-28T10:00:20Z"),
            asst(self.arm, "m2", t="2026-10-28T10:30:00Z"),
            human(self.arm, "keep going", "2026-10-28T10:31:00Z"),
            asst(self.arm, "m3", t="2026-10-28T10:45:30Z"),
        ])
        t = self.run_measure()["time"]
        self.assertEqual(t["wall_min"], 45.5)
        self.assertEqual(t["human_prompts"], 2)
        self.assertEqual(t["prompts_after_first"], 1)

    def test_codex_log_sums_and_ollama_rows(self):
        run = os.path.join(self.arm, ".ai", "workflow-runs", "r1")
        os.makedirs(run)
        turn = lambda i, c, o: {"type": "turn.completed",
                                "usage": {"input_tokens": i, "cached_input_tokens": c,
                                          "output_tokens": o}}
        write_jsonl(os.path.join(run, "review-2-codex.log"),
                    [{"type": "thread.started"}, turn(100, 40, 5), turn(200, 150, 7)])
        write_jsonl(os.path.join(run, "try-1.log"), [turn(1000, 0, 50)])   # a codex try
        write_jsonl(os.path.join(run, "review-3-codex-ollama.log"), [turn(9999, 0, 9999)])
        with open(os.path.join(run, "result.json"), "w") as fh:
            json.dump({"harness": "codex", "model": "default", "tries": [
                {"try": 1, "wall_s": 60, "tokens_in": 1000, "tokens_out": 50,
                 "log": "/elsewhere/r1/try-1.log"}]}, fh)
        with open(os.path.join(run, "review.json"), "w") as fh:
            json.dump({"reviewers": [
                {"harness": "claude", "model": "opus", "wall_s": 30, "tokens_in": 500,
                 "tokens_out": 20, "log": "review-1-claude.log"},
                {"harness": "codex", "model": "default", "wall_s": 20, "tokens_in": 300,
                 "tokens_out": 12, "log": "review-2-codex.log"},
                {"harness": "codex-ollama", "model": "qwen", "wall_s": 180, "tokens_in": None,
                 "tokens_out": None, "log": "review-3-codex-ollama.log"}]}, fh)
        res = self.run_measure()
        c = res["codex"]
        self.assertEqual(c["logs"], 2)
        self.assertEqual(c["turns"], 3)
        self.assertEqual(c["input_tokens"], 1300)
        self.assertEqual(c["cached_input_tokens"], 190)
        self.assertEqual(c["output_tokens"], 62)
        self.assertEqual(res["ollama"], [{"harness": "codex-ollama", "model": "qwen", "wall_min": 3.0}])
        x = {(r["harness"], r["model"]): r for r in res["dispatch_crosscheck"]}
        self.assertEqual(x[("codex", "default")]["tokens_in"], 1300)
        self.assertEqual(x[("codex-ollama", "qwen")]["unreported"], 1)
        # Cross-check numbers never reach the Claude totals.
        self.assertEqual(res["claude"], [])

    def test_cli_table_and_json(self):
        write_jsonl(os.path.join(self.root, self.flat, "s1.jsonl"), [
            human(self.arm, "go", "2026-10-28T10:00:00Z"),
            asst(self.arm, "m1", out=3, t="2026-10-28T10:02:00Z"),
        ])
        buf = io.StringIO()
        with redirect_stdout(buf):
            measure.main([self.arm, "--projects", self.root])
        self.assertIn("TOTAL", buf.getvalue())
        self.assertIn("wall: 2.0 min", buf.getvalue())
        buf = io.StringIO()
        with redirect_stdout(buf):
            measure.main([self.arm, "--projects", self.root, "--json"])
        self.assertEqual(json.loads(buf.getvalue())[0]["claude_per_model"]["claude-opus-5-5"]["output_tokens"], 3)


if __name__ == "__main__":
    unittest.main(verbosity=2)
