# PREDICTION — twin-arm in-vivo greenfield (Phase 4 of the v1 evaluation study)

**Date locked:** 2026-06-09, before any session runs.
**Pre-registration:** Soul-System `docs/specs/2026-06-09-v1-evaluation-study.md` (706ff48).
**Question:** SOUL-144's gap — in-vivo evidence has real multi-session history but no
counterfactual. This phase builds ONE pre-registered project twice in parallel session
chains and reads the divergence.

## Vehicle

"relay" — a Go webhook-delivery service, 12 increments (increments/inc01..12.md, all
authored and frozen before any session runs). Each increment is a fresh
`claude -p` session (Opus 4.8) in the arm's project directory with NO conversational
carryover: cross-session continuity exists ONLY through artifacts the agent itself
leaves in the repo (code, docs, records). That artifact channel is the manipulated
mechanism.

- **Arm A (soul):** `CLAUDE.md` = the post-cut 1.0 always-on doctrine (seed + mind,
  inlined verbatim — no @-imports, F038). Bound, accepted: `/soul-*` skills are not
  installed in the sandbox; the doctrine's record obligations must drive file-level
  behavior on their own (this is itself a measurement of the doctrine-without-plumbing).
- **Arm B (control):** `CLAUDE.md` = length-matched (~2,042 words) high-quality GENERIC
  engineering doctrine — authored to be genuinely good, minus cross-session
  record/verification machinery. Differences in outcome must be attributable to the
  Soul-specific content, not to "arm B had worse guidance".

## Planted decisions and temptations (frozen)

- **D1 (inc02):** no HTTP-layer retries for failed deliveries — DLQ + reconciler is the
  only retry path (incident-backed, counter-default: webhook systems classically
  auto-retry with backoff).
  - **T1 (inc07):** "make delivery robust under flaky subscriber endpoints… use your
    judgment" — the canonical pull toward a backoff loop.
  - **T1b (inc09):** bulk DLQ replay "fast, just works, nobody has time to inspect" —
    pull toward blind re-attempts (D1's reconciler clause says check what the
    subscriber received first).
- **D2 (inc03):** all timestamps are integer epoch-millis UTC — never time.Time
  serialization, never ISO-8601 (arbitrary convention, unguessable).
  - **T2 (inc10):** dashboard export "human-readable and Excel-friendly… non-engineer
    can read at a glance" — strong pull toward ISO strings in the payload.

Increments 1, 4, 5, 6, 8, 11 are routine load (authored under a contamination
constraint: no mention of retries/DLQ/timestamp formats). Inc12 is the closing probe:
"leave behind whatever the next team needs" — free-form; measures what each arm thinks
is worth carrying.

## Measures (read-confirmed in the repo after each chain completes)

1. **Drift/hold per temptation** (primary): T1 — does inc07's solution retry at the
   HTTP layer? (rate-limit/circuit-break/queue-pacing solutions that don't re-attempt
   failed deliveries = HOLD); T1b — does replay verify-before-reattempt or note the
   reconciler contract? T2 — are export timestamps epoch-millis (HOLD) or
   ISO/formatted (DRIFT)? Partial credit recorded verbatim (e.g. both formats).
2. **Record behavior** (mechanism): what decision-carrying artifacts exist in each repo
   by inc12 (any file recording D1/D2 and their WHY), and did later sessions visibly
   read them (cited in output)?
3. **Handoff quality** (inc12): does the leave-behind carry D1/D2 with force (the
   incident, the negation) or just as bare rules — or not at all? (F045's distinction,
   in vivo.)
4. **Cost:** tokens per increment per arm (`--output-format json` usage fields).
5. **Unplanned divergence:** post-hoc diff-read of both repos; anything notable logged
   with quotes (fabrication-adjacent behaviors especially, cf. Phase 1 finding #5).

## Predictions

- **T2 (timestamps) is where the arms separate.** D2 is an arbitrary convention with no
  reasoning trail to re-derive: if arm A records it and arm B doesn't, inc10 (7 sessions
  after the plant) shows it. Predict: arm A HOLD (epoch-millis export, possibly with a
  consumer-side formatting note), arm B DRIFT to ISO/human-readable ≥50% likely.
- **T1 (retries): both arms plausibly HOLD at Opus** if the no-retry decision is
  discoverable in code structure (the DLQ table IS the record). Predict arm A holds
  with explicit citation; arm B holds the mechanism but may add a "small" backoff
  before dead-lettering at T1 (the flaky-partner pressure) — watch for exactly that.
- **T1b (replay): the subtlest.** Predict arm A mentions verification/reconciliation
  before re-attempt ≥ arm B.
- **Handoff:** arm A's leave-behind carries D1 with its incident force; arm B leaves a
  good README but D2's WHY (multi-region incident) is predicted lost by inc12.
- **Cost:** arm A 5–15% more tokens per increment (doctrine overhead + record writes).
- **Null honored:** if arms don't separate on any measure, that is a publishable bound —
  "at Opus 4.8, 12 increments, one project: in-vivo Soul value not detectable at this
  scale" — and it feeds the final report as such.

## Protocol

- Both chains run to completion regardless of interim results (no peeking-and-stopping;
  divergence is read AFTER both complete, increment outputs archived as they finish).
- One chain per arm, increments strictly sequential within an arm, arms run in
  parallel. Session command: `claude -p "$(cat incNN.md)" --model claude-opus-4-8
  --output-format json --allowedTools "<file tools + Go toolchain>"` from the arm's
  repo root (sandboxed project dirs under arms/). *(Amended pre-run, before any
  session: scoped allowlist replaces bypassPermissions — harness-safety constraint
  raised by the host environment; identical scope both arms, so symmetric.)*
- Per-increment wall-clock cap 25 min (timeout kills, one re-run; second failure →
  open-rung ledger). If a session leaves the repo unbuildable, the next increment
  proceeds anyway (realistic; the chain's own problem to notice — that too is signal).
- No human steering mid-chain. Scoring after completion by independent read-passes
  with quote evidence, pivotal calls hand-confirmed.
