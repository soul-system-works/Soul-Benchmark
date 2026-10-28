# Workflow value — round 1 result (2026-10-28)

**Verdict.** On a small, fully specified build (the one-page game in `SPEC.md`), the
three arms tied on quality, and `/soul-workflow build-verify` (arm C) cost **3.3× the
Claude usage** of plain Claude Code (arm A) and took about twice as long, with
**more Opus, not less**. For a job this size the workflow's overhead has nothing to pay
for. Round 1 cannot say whether it pays on harder work — the task never strained a
single session. n = 1 per arm: a demo with honest numbers, not a benchmark.

## Setup (as run)

Arms per `PLAN.md`: A plain (no CLAUDE.md, plugins, Soul or memory — launch line
leak-tested against a control), B the owner's normal setup, C B plus
`/soul-workflow build-verify` with the default roles (Soul System v3.7.2). Host model
Opus 5.5 in all three; the same prompt; run in series by the owner, order A, B, C,
with no step-ins in any arm (no permission prompts noted). `sha256sum -c MANIFEST.txt`:
no arm edited its `check.mjs` or `SPEC.md`.

## Quality

| | A (game-2) | B (game-1) | C (game-3) |
|---|---|---|---|
| `check.mjs` (the kit's own copy) | 10/10 | 10/10 | 10/10 |
| 12 must-haves — AI scorer (blind) | 12/12 pass | 12/12 pass | 12/12 pass |
| Playability — AI scorer (blind) | 4 | 4 | 3 |
| Owner (scorer 2) | "all fairly similar" | | |

- The AI scorer drove each game with key presses and test instrumentation in headless
  Chromium; its sheet is `scores/scores-ai.md`. Its reasons for C's 3: no death
  explosion or pause, an odd edge wraparound, fuel that refills by itself (not in the
  spec), and test hooks the page can overwrite (the spec says read-only) — noted, not
  failed.
- Per the Soul System's mind item 8 (a grade that ranks the arms needs a second blind
  scorer), the owner's "fairly similar" does not confirm the AI's ranking: **quality is
  reported as a tie.**
- **Blinding caveat:** the owner read arm A's closing summary during the run, which
  named features only A has, before scoring.
- **Instrument flaw:** `playtest.mjs` failed arm B on must-haves 2 and 10. Reading B's
  code: B ignores Enter for 0.6 s after game over ("a held Enter must not skip straight
  past the result") and shows "Press Enter to play again" only after it; the script
  pressed sooner. B's two fails are false; the playtest must wait for the prompt before
  pressing Enter (fix before round 2). With that, the playtest separated nothing: every
  other item was pass or "unverified (needs a human)" for all three.

## Speed

| | A | B | C |
|---|---|---|---|
| Owner's clock, first prompt → "done" | 5 min | 6 min | 9 min |
| Logs, first prompt → last assistant reply (`measure.py`) | 3.9 min | 5.3 min | 10.8 min |
| Host API time (Claude Code `/usage`) | 2m 52s | 4m 03s | 3m 58s |
| Times the owner stepped in | 0 | 0 | 0 |

C ran one repair round: two implementer dispatches and two review rounds.

## Usage

Claude Code's own cost figures — `/usage` for each host session (owner's paste in
`RUN-SHEET.md`), plus, for C, each `claude -p` worker's `total_cost_usd` from
`.ai/workflow-runs/*/` (workers are separate sessions, so the host's `/usage` omits
them). Codex ran on the owner's ChatGPT plan and is not in these dollars.

| | A | B | C host | C workers | C total |
|---|---|---|---|---|---|
| Opus 5.5 | $0.74 | $1.11 | $1.42 | $0.62 (reviewer, 2 rounds) | $2.04 |
| Sonnet 5.5 | — | — | — | $0.38 (implementer, 2 runs) | $0.38 |
| **Claude total** | **$0.74** | **$1.11** | | | **$2.42** |
| × A | 1.0 | 1.5 | | | 3.3 |
| Codex (ChatGPT plan) | — | — | — | 189k in / 1k out | |

Tokens (`out/measure.json`) agree with `/usage` for every host, to `/usage`'s rounding (0.1k). Why C cost
more: its host took **32 turns** (A 8, B 11) — writing the brief, reading patches,
re-running checks, weighing two reviews, one repair round — and each turn re-reads the
growing conversation (2.5M cache-read tokens against A's 0.36M). Handing the
implementation to Sonnet saved less than that overhead cost. B did not use a subagent.

## Against the locked prediction (`PREDICTION.md`, pushed before any arm ran)

| Prediction | Outcome |
|---|---|
| Quality within 1 item and 1 playability point | ✓ (12/12 all; 4/4/3; owner: similar) |
| If one arm leads, C | ✗ — C scored lowest with the AI scorer |
| A fastest; C slowest at 1.5–2.5× A | ✓ / ✗ just over — C 1.8× (owner's clock) to 2.8× (logs) |
| Opus: C < A ≤ B | ✗ — C used the most Opus ($2.04 vs $0.74 / $1.11) |
| Total tokens: C highest | ✓ |
| Interventions: A, B 0–1; C 1–3 | ✓ / ✗ — C 0 |
| C's host dispatches, not its own subagent (v3.7.2) | ✓ |
| Miss guess 1: C saves less Opus than predicted | ✓ and stronger — C spent more |
| Miss guess 2: B does not hand the build to a subagent | ✓ |

## What it means

- **Small, well-specified jobs: don't use build-verify.** One Opus session does them in
  minutes; review has nothing to catch; the host's coordination overhead dominates.
- **The cost case for the workflow rests on the implementing being a large share of
  the work** — long, multi-file changes — or on it costing nothing (a local
  implementer). Round 1 tested neither.
- **The quality case rests on tasks where a single session misses things.** Round 1's
  task was too easy for that.

## Round 2 (proposal; the owner decides)

A harder task with hidden acceptance tests on a real project of the owner's; 3 runs per
arm; the playtest's Enter-timing flaw fixed; and the planned purely local arm, set up
the best way. Arm D (C with an Opus implementer) is not needed: C did not beat B.

## Files

`out/measure.json`, `out/check-{A,B,C}.txt`, `out/playtest-{A,B,C}.json`,
`scores/scores-ai.md`; the owner's timings and `/usage` paste in `RUN-SHEET.md`.

## Lean re-run — arm C2 (Soul System v3.8.0)

After round 1, `build-verify` became one tool call per round plus `accept` (v3.8.0):
the tool runs the implementer, records the boxed-in check and runs both reviewers,
and hands the host one bundle. C2 is arm C again, once, on the same spec, prompt,
host model and default roles. No prediction was locked for it.

| | A | B | C (v3.7.2) | C2 (v3.8.0) |
|---|---|---|---|---|
| Host requests (`/usage`) | 8 | 11 | 32 | 16 |
| Host cost | $0.74 | $1.11 | $1.42 | $0.91 |
| Workers (Claude) | — | — | $1.00 | $0.92 (Sonnet $0.37, Opus reviewer $0.55) |
| **Claude total** | **$0.74** | **$1.11** | **$2.42** | **$1.83** |
| × A | 1.0 | 1.5 | 3.3 | 2.5 |
| Owner's clock | 5 min | 6 min | 9 min | 6 min |
| Logs, first prompt → last reply | 3.9 min | 5.3 min | 10.8 min | 6.4 min |
| `check.mjs` (kit copy) | 10/10 | 10/10 | 10/10 | 10/10 |

Codex (ChatGPT plan, not in the dollars): 264k tokens in / 1.7k out over two reviews.
Worker dollars are each `claude -p` worker's `total_cost_usd`. C2's host tokens from
the logs (`out/measure-C2.json`: 1.08M cache read) are below `/usage`'s 1.3m, unlike
round 1, where the two agreed; the dollar figures above are `/usage`'s.

What happened in C2: one implementation (Sonnet, first try passed), reviewers raised 4
findings (Opus 1, Codex 3), the host accepted all 4, one repair round fixed them,
the second review found nothing, and `accept` applied the change and re-ran the
check (passed). `sha256sum -c MANIFEST-C2.txt`: check and spec unedited.
One accepted finding was a spec miss: debris stopped increasing after level 6, and
the spec says "more and faster debris each level".

**Reading it.** The lean loop halved the host's requests (32 → 16) and cut the host's
cost by a third ($1.42 → $0.91); the whole run fell from 3.3× to 2.5× plain Claude
Code and matched arm B's clock. The workflow still costs more than a single session
on a task this easy. Where C2's host turns went: writing the brief (twice), launching
two rounds and `accept`, and reading each bundle in pieces — the round-1 bundle was
~510 lines, most of it the inline patch, which the host must read. n = 1; C2's game
was not blind-scored, so it says nothing about quality beyond the check.
