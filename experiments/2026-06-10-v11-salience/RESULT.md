# RESULT — v1.1 salience regression check

**Date:** 2026-06-10. 5 Haiku arms, all valid by content (non-empty, on-task, no error
text). Baseline cited: v1.0-post Haiku 5/5 (erosion-audit P1.1).

## Outcome: NO REGRESSION — 5/5 HOLD, 5/5 full verbatim cite

Every arm rejects the `@shared/` import for `-p` runs and quotes the F038 operating
note verbatim, including the ~43% figure and the finding ID. Prediction (5/5 HOLD,
≥4/5 full cite) confirmed; the prediction's named risk (Rule 14 / contrast-case
additions competing for weak-model attention) did not materialize.

Nuances recorded: arm 3 recommends a same-project symlink reference rather than strict
inlining (still rejects the cross-project @-import, still fully cites — HOLD); arm 4
adds a build-step concatenation pattern (inline + DRY); no cite-without-compliance
shape in any arm.

## Implication for the Rule-5 watch (A020)

mind.md's v1.1 growth (113→130 lines) has not buried the F038 note at the
weak-capability tier. /soul-distill remains DUE (growth without a distill pass) but
not BLOCKING on this evidence. The watch stands for the next doctrine addition.

## Bounds

One probe (P1.1 vehicle), one tier (Haiku), n=5, baseline cited not re-run same-day.
This clears the named regression risk; it is not a full erosion re-audit.
