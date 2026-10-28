# Workflow value — plan (approved by the owner, 2026-10-28)

**Question.** Is `/soul-workflow build-verify` worth using, judged on the three things the
owner cares about: **quality, speed and usage**? Source: SOUL-I080 / SOUL-I083 in the
Soul System's `ideas.md`; the tool is Soul System v3.7.2.

**Task.** One small build outside any existing project: the game in `SPEC.md`, given
word for word to every arm.

## Arms (one run each in round 1; the owner drives every arm, screen-recorded)

| Arm | Setup | Started how |
|---|---|---|
| A · plain | Claude Code with none of the owner's setup: no global CLAUDE.md, no plugins, no Soul, no auto-memory | the launch line on `RUN-SHEET.md` (the isolation recipe proven in 2026-10-21-campaign, RESULT-phase0-isolation) |
| B · normal | the owner's everyday setup: global CLAUDE.md, plugins, Soul, subagents | plain `claude` in the arm folder |
| C · workflow | B plus `/soul-workflow build-verify`, default roles (Sonnet implementer → Opus; Opus + Codex reviewers) | plain `claude`, then the command |

All arms: host model Opus 5.5; the same spec; each arm in its own folder (a fresh git
repo holding `SPEC.md` and `check.mjs`), so Claude Code keeps each arm's usage in its own
log. **Follow-up arm D** (C with an Opus implementer) only if C differs from B: C differs
from B in two ways (the workflow and the implementer model), and D separates them.

## Measures

- **Quality**
  - the 12 must-haves, each pass / partial / fail, scored by two blind scorers;
  - a hidden scripted playtest (`playtest.mjs`, never in the arm folders): every
    must-have that a script can drive, through the test hooks and key presses;
  - a 1–5 playability score from each blind scorer, with one sentence of why;
  - the scorers see the games as `game-1/2/3`, assigned by the owner's coin, not the arms.
- **Speed:** wall time from the first prompt to "done" as the arm reports it; the number
  of times the owner had to step in (answer, correct, nudge).
- **Usage:** tokens per model per arm (input incl. cache, output), read afterwards from
  Claude Code's session logs — subagents and workers included — plus Codex tokens and
  workflow-worker usage from `.ai/workflow-runs/`. Method: the Soul System's
  `tools/gate-cost-measure.py` approach and mind item 7's traps (count per turn; classify
  by recorded `cwd`). Claude exposes no "% of my limit", so usage is tokens by model.

## Order

1. ~~Owner approves SPEC, PLAN and the Playwright install.~~ Done 2026-10-28; arm D as a follow-up only if C differs.
2. Build `check.mjs`, `playtest.mjs`, `measure.py`, `RUN-SHEET.md`; prove `check.mjs`
   and `playtest.mjs` on a known-bad and a known-good game first (controls).
3. Lock `PREDICTION.md` (with a miss-direction guess) before any arm runs.
4. Owner runs A, B, C (any order; one sitting if possible), recording each.
5. Measure; blind-score; `RESULT.md`; then the GIF and the blog draft.

**Round 2 (planned):** a purely local arm, set up the best way the owner can (the strongest local model that fits, best-of-n). **Not in round 1:** that local arm; repeats (n = 1 per arm — a demo with honest
numbers, not a benchmark); other tasks (a real project of the owner's is round 2's candidate).
