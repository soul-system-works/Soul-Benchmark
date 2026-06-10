# RESULT — sequential stream (Phase 3 of the v1 evaluation study)

**Date:** 2026-06-09/10. **Runs:** 8 canonical + 16 measured (Sonnet 4.6 pinned;
t8 pair re-run after the session-limit storm). Quality = harness build+test with
real Go (post STUDY-005 fix). Parent pre-registration honored; adaptations declared
in PREDICTION.md.

## Cost series (output tokens, soul-on vs soul-off per position)

| t | off | on | on/off |
|---|---|---|---|
| 1 | 2,235 | 6,007 | 2.69 |
| 2 | 10,308 | 13,077 | 1.27 |
| 3 | 9,014 | 10,506 | 1.17 |
| 4 | 6,013 | 8,991 | 1.50 |
| 5 | 9,159 | 11,112 | 1.21 |
| 6 | 12,584 | 19,886 | 1.58 |
| 7 | 14,131 | 13,002 | **0.92** |
| 8 | 46,787 | 35,573 | **0.76** |

Total cost: off $4.13, on $4.96 (**on/off = 1.20**). Quality: off **8/8 PASS**,
on **7/8** (on-t2 shipped a timezone test that fails under execution — written
blind, go-less sessions). Soul-on overhead is real at every early position; the
ratio crosses below 1.0 exactly at the pre-registered compounding tasks (t7
refactor-revisit, t8 cross-cutting).

## The conformance check changes the interpretation

**Record accumulation was NULL.** Across 8 soul-on sessions, `record-acc/`
harvested only `.soul/events.jsonl` (gate telemetry). No witness.md, no findings,
no decision docs — despite the seed + the explicit "record what a later session
cannot re-derive" instruction. Therefore:

- The t7/t8 crossover **cannot be attributed to accumulated records** — there were
  none to reuse. Whatever produced it (seed discipline shaping a tighter approach
  at high-complexity tasks; n=1 variance — t8-off was unusually verbose at 46.8k)
  is not the parent design's hypothesized mechanism.
- The honest headline is the **mechanism null**, not the slope.

**Why the mechanism nulled — a harness-design finding, corroborated in vivo:**
Phase 4 showed the Soul arm's natural record medium is **force-comments at the
code site** (worker.go's "NOT NEGOTIABLE" block) plus a handoff document — not
standalone witness files. This harness discarded measured-run code between tasks
(required by the held-fixed clause), structurally excluding the dominant carrier.
The seed's record obligation, without `/soul-capture` plumbing and without a
witness scaffold already present, does not self-start FILE-level record-keeping
in `-p` sessions: 0/8 here. (Same in vivo: arm A wrote no witness.md either —
its record lived in code and HANDOFF.md.)

## GATE DECISION (pre-registered, parent Step-3 rule)

Soul-bench is built only on "a slope difference or repeated quality separation"
attributable to the mechanism. Verdict: **DO NOT BUILD.**
- The slope signal exists but is mechanism-unattributable and n=1.
- Quality separation is absent (slightly negative for soul-on).
- The parent's null clause applies: at this scale, on this stream, "the
  methodology is overhead" (+20% cost, −1 quality cell) **for sequential
  cost-economics purposes**. The question closes with evidence; the standalone
  benchmark stays unbuilt. (Decision-carriage value — Phases 2 and 4 — is a
  different, measured, positive axis; cost-per-task economics was always the
  weakest claim and now has its honest bound.)

## Open rungs (ledger)

- Re-run with a record-carrier-faithful harness: persist measured-run code
  comments/docs (or seed a witness.md scaffold) so the mechanism can exist; then
  the t6-t8 cells become interpretable.
- Replicate t7/t8 at n≥3 to separate crossover from variance.
- on-t2's blind-written failing test: one more instance of the go-less bound;
  any future stream harness should give sessions an executor.
