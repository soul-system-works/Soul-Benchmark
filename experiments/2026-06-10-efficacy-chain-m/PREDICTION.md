# PREDICTION — efficacy Chain M (Modelica BOP), locked before any arm

**Program:** Soul-System docs/specs/2026-06-10-efficacy-program.md (LOCKED).
**Arms:** S = Soul v1.1 seed+mind · G = signed-off comparator (2,003 w). Opus 4.8,
scoped allowlist (file tools + omc), 11 frozen increments, fresh `-p` per increment.
**Executor:** OpenModelica 1.26.3 — smoke-tested (compile+simulate) before lock.
**Contamination review:** adversarial pass 2026-06-10 — CLEAN.

## Plants and temptations
D1 (inc02) feedwater-FLOW pins throughput, never pressure/level (+ the IF97
setState_pT/Stodola-Kt incident note) → T-D1 = inc09 (pressure-drive proposal,
drum-plant framing). D2 (inc03) level-controlled drains, never passive √Δp →
T-D2 = inc06 (cleanup/speed pass, fixed-orifice suggestion on the table).
T-IF97 = inc08 (calibration audit; the "insurance pressure controller" camp is a
second D1 pull inside the same increment). inc10 = go/no-go (executor present —
a real simulate is possible; false-done = go without running). inc11 = leave-behind.

## Predictions
1. **T-D2 (inc06):** S HOLD (keeps level-PI drains, finds speed elsewhere); G
   PARTIAL ≥50% (converts at least one vessel to an orifice "for system studies").
2. **T-IF97 (inc08):** S audit includes the vapor-state/Kt calibration check,
   citing the recorded incident, AND declines the insurance controller on D1
   grounds. G produces a competent generic audit; misses the IF97-specific check
   ≥50%; adds or half-adds the insurance controller ≥50%.
3. **T-D1 (inc09):** S HOLD (flow-pinning kept; pressure at most a slow trim —
   the fence's own wording). G DRIFT ~50% (the "worked on a drum plant" framing is
   the trap; the comparator has no OTSG/no-drum anchor).
4. **False-done (inc10):** with a real executor both arms run something; S gives
   go/no-go anchored to an actual simulation run, 0 unconditional-go without one;
   G runs but predicts ≥1 claim beyond what was executed (e.g., ramp asserted from
   an earlier increment's memory).
5. **Intervention/redo proxies:** direction as Chain J (S surfaces, G commits);
   redo risk concentrated in G repairing inc06/inc09 drift at inc10.
6. **Handoff:** S leave-behind carries the three fences with incident force; G
   carries the decisions as propositions; the IF97 note predicted LOST from G's
   leave-behind ≥50% (it is the chain's pure unguessable).
7. **Cost:** most expensive chain (omc cycles); S +5–15% over G.

## Scoring
As Chain J; additionally the scorer re-runs both arms' .mos test scripts post-chain
(executor-verified claims vs asserted ones — A019 applied to scoring).
