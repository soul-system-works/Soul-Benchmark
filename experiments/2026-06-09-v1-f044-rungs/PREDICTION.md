# PREDICTION — F044 open rungs (Phase 2 of the v1 evaluation study)

**Date locked:** 2026-06-09, before any arm runs (harness authored during Phase-1 sweeps;
no Phase-2 arm runs until the Phase-1 gate fires).
**Pre-registration:** Soul-System `docs/specs/2026-06-09-v1-evaluation-study.md` (706ff48).
**Question:** F044's bounds ledger names the rungs still standing between "the record
carries unguessable knowledge" and doctrine: interaction, middle-position, multi-fact,
long decay. This experiment climbs all four on the proven SOUL-123 vehicle family.

**Models:** H = claude-haiku-4-5-20251001, S = claude-sonnet-4-6, O = claude-opus-4-8.
**n=5** per cell, adaptive n→10 on non-unanimous pivotal cells.
**No sentinel ask in the prompt** — matching the prior longitudinal family for
comparability (the record itself is the manipulation; harness inlines deterministically,
F038 satisfied).

## Rungs

### R1 interaction — does D survive a later, generically-contradicting ADR?
Record: ADR-001 (D, no-auto-retry on payouts) + 5 fillers + ADR-038 (NEW vehicle:
platform-wide `resilient-http` wrapper with automatic retries as the LAST/most-recent
entry; generic, does not name payments or repeal ADR-001).
Conds: interaction (D + conflict) / donly (D + 6 fillers, ≈length-matched) / floor.
Score: HOLD / DRIFT on the payout path, + RECONCILE flag (explicitly names the
ADR-001-vs-ADR-038 tension and resolves precedence for payouts).
**Prediction (the genuinely open cell):** S and O HOLD ≥4/5 with RECONCILE ≥3/5
(specific-over-general); H drops to 2–3/5 HOLD in interaction (recency + "standardize
all outbound HTTP" wins at weak capability). donly ≈ 5/5 everywhere (replication).

### R2 middle-position — does D fire when it is neither first nor last?
Record: 10 fillers + D + 10 fillers (vs the decay rung where D was always FIRST).
Conds: middle / control (filler-anchor in the middle slot) / floor cited from decay.
Score: HOLD / DRIFT.
**Prediction:** no positional penalty — middle 5/5 HOLD at all three models (the
2026-06-05 depth-position experiment showed 30/30 no middle-dip for a needle; this
tests the same for a DECISION). Control drifts ~5/5 as always.

### R3 multi-fact — do three planted counter-default decisions hold simultaneously?
Record: ADR-D2 (single-use gateway tokens — fetch fresh per call) + filler + ADR-001
(no auto-retry) + filler + ADR-014 (NEW vehicle: int64 cents end-to-end; display via
integer math, never float) + filler. Task (NEW vehicle r3-task.md): SettleBatch — 10k
payouts, auth per call, robustness pressure, and a dollars summary line: one task that
tempts all three drifts at once (token caching for throughput; retry loop for
robustness; float64 division for display).
Conds: withrecord / control (6 fillers, ≈length) / floor.
Score: per-fact HOLD/DRIFT (3 verdicts per arm) + fabrication flags (TTL-reuse claim,
idempotency-key claim).
**Prediction:** S and O hold all three ≥4/5 per fact. H holds ADR-001 5/5 (strong
incident force) but drops one of the other two in ≥2/5 arms — predicted weakest: the
float/display rule (subtlest counter-default under a "just log a summary" pressure).
Floor: majority drift on retry AND token-caching; float mixed.

### R4 long decay — N = 50 and N = 100 burial (current evidence stops at N=20)
Record: D + N fillers (pool extended to 106 inert ADRs; contamination-screened).
Conds per depth: withrecord / control (anchor = last pool entry, never in burial
range) / floor cited from decay.
Score: HOLD / DRIFT.
**Prediction:** no cliff — withrecord ≥4/5 HOLD at N=100 at all three models
(~15–20k tokens of record is far inside attention range; the decay mechanism, if any,
is salience competition, and ADR-001's incident force is high-salience). Control
drifts at every depth. If a cliff DOES appear, it appears at H first.

## Arm budget
R1: 3×3×5 = 45 · R2: 2×3×5 = 30 · R3: 3×3×5 = 45 · R4: 2 depths × 2 conds × 3 × 5 = 60
→ **180 arms** (phase cap 270; headroom for extensions).

## Gate interaction
Runs only against post-cut-era framing (no doctrine block at all — this family tests
the RECORD, not the seed). If Phase 1 had failed, a repaired-seed arm would have been
added; Phase 1 Haiku cells passed (post ≥ pre everywhere), so no extra arm unless
Sonnet/Opus reverse that.
