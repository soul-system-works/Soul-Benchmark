# Phase 2 — pilot (2026-10-21): chain R inc01–02 × 7 arms, Sonnet 5.5

**Verdict: PASS — harness valid; the pilot's 14 sessions are kept as inc01–02 of the
main R block.** First launch failed in 2 s per session (runner bug: `--allowedTools`
is variadic and swallowed the prompt) — zero work, fixed, re-run.

| Arm | inc01 $ / s / turns / denials | inc02 $ / s / turns / denials | own tests @inc02 (harness) |
|---|---|---|---|
| F  | 0.12 / 61 / 7 / 0   | 0.17 / 96 / 15 / 3  | 3 passed |
| G  | 0.36 / 170 / 22 / 4 | 0.73 / 355 / 46 / 8 | 22 passed |
| GP | 0.31 / 145 / 15 / 2 | 0.57 / 265 / 44 / 12 | 11 passed |
| GS | 0.44 / 176 / 23 / 3 | 0.74 / 392 / 50 / 8 | 16 passed |
| S  | 0.17 / 68 / 7 / 1   | 0.33 / 666 / 33 / 5 | 10 passed |
| SP | 0.20 / 87 / 9 / 1   | 0.29 / 157 / 36 / 9 | 6 passed |
| SS | 0.27 / 137 / 11 / 1 | 0.37 / 199 / 34 / 6 | 13 passed |

Total $5.08 notional, 14 sessions, mean $0.36 and ~3.5 min per session (inc02 costs
about twice inc01; later increments will cost more). Numbers are descriptive — n=1 per
cell, two increments; no endpoint is read from the pilot.

Validity: 13/14 carry the sentinel line. SS inc01 does not: Soul's completion gate fired
(2 events in that arm's `.soul/events.jsonl`) and the final reply is the post-gate
verification ("— Verify: GAP …"), so the session is valid, and it shows the gate working
inside an arm. Gate events: S 0, SP 0, SS 2.

Harness changes after the pilot, applying to inc03+ in every arm alike:
(1) the harness's pytest run uses `PYTHONPATH=src:.` (src-layout arms errored);
(2) the allowlist adds `PYTHONPATH=src python3/python/pytest` and `pip list` — the
pilot’s 63 denials were mostly env-prefixed python, compound `mkdir … && cat >`, `pip
list`, `cd`, `git ls-files`. Compound and `cd`/`git` commands stay denied.
