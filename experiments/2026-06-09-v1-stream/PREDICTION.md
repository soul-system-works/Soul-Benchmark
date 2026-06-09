# PREDICTION — sequential stream (Phase 3 of the v1 evaluation study)

**Date locked:** 2026-06-09, before any arm runs.
**Parent pre-registration:** Soul-System
`docs/archive/specs/2026-05-21-token-economics-stream-experiment.md` (design locked
2026-05-21; archived in the 1.0 cleanup, resurrected here unmodified in hypothesis,
conditions, metric, and task list). Study registration:
`docs/specs/2026-06-09-v1-evaluation-study.md` (706ff48).

**Hypothesis (verbatim from parent):** Soul-on cost-per-task grows sub-linearly vs
Soul-off because recorded structure lets later tasks reuse earlier reasoning. **Null:**
no slope difference, or Soul-on simply costs more — methodology is overhead. Both
publishable.

## Adaptations from the parent design (mechanical only, declared pre-run)

1. **Runner:** `claude -p` sessions with scoped tool allowlist (file tools + Go
   toolchain) instead of Agent-tool subagents; tokens from `--output-format json`
   usage fields instead of the Agent tool's total_tokens.
2. **Model pinned:** claude-sonnet-4-6 for ALL sessions (canonical + both conditions).
3. **"Same code-so-far" mechanics:** a CANONICAL chain (no doctrine CLAUDE.md) first
   builds states S1..S8 sequentially from the 8 pre-registered tasks. Then each
   measured run of task N starts from a pristine copy of canonical S(N-1):
   - **soul-off:** S(N-1) + task N. Nothing else.
   - **soul-on:** S(N-1) + task N + the 1.0 seed/mind as CLAUDE.md + `record/` carried
     forward from soul-on's own earlier runs (whatever record-like artifacts those
     sessions chose to write: witness/findings/ideas/decision files). Code changes from
     measured runs are DISCARDED; only soul-on's record artifacts persist between its
     runs. This keeps code-so-far identical across conditions at every position (the
     parent's "held fixed" clause) while letting the record accumulate (the manipulated
     mechanism).
4. soul-on sessions get one extra fixed instruction line ("operate under CLAUDE.md;
   record what a later session cannot re-derive") — the posture the parent design
   assumed from the seed; counted in its token cost (overhead is part of the claim).

## Metrics (verbatim intent from parent)

- Primary: output+input tokens per task per condition, plotted vs position 1..8;
  compare slopes. (Cache-read tokens reported separately.)
- Counter-metric: completion quality per task — does the code build and do its tests
  pass (`go build ./... && go test ./...` run by the harness after each measured
  session, in the sandbox); plus a read-pass on whether the task was actually done.
- Conformance (soul-on): did the session read/cite the record? (quote evidence)

## Predictions

- Positions 1–5: soul-on costs MORE per task (doctrine + record-writing overhead),
  ~10–25%.
- Positions 6–8 (the compounding tasks): if the record mechanism pays, soul-on's
  relative cost drops or its quality counter-metric beats soul-off's (fewer re-derived
  decisions, e.g. t6 currency change conflicting with t1 representation, t7 respecting
  t2's format commitments). Honest prior: **the null is live** — 0.x found reasoning-
  lift claims dissolve at capable models; Sonnet may re-derive everything from code.
- Sharpest single cell: t6 (multi-currency vs the t1 amount-representation decision).
  If soul-on's record of WHY the representation was chosen changes t6's approach or
  cost vs soul-off, that's the signal cell.
- **Gate consequence (parent Step-3 rule):** soul-bench gets built ONLY if a slope
  difference or a repeated quality separation appears. Predicted: marginal/null →
  soul-bench stays unbuilt and the question closes with evidence.

## Budget

8 canonical + 16 measured = 24 Sonnet sessions, sequential within chains
(soul-off runs parallelizable; soul-on strictly sequential). Wall-clock dominated by
the canonical chain. Per-session timeout 20 min, one retry, then open-rung ledger.
