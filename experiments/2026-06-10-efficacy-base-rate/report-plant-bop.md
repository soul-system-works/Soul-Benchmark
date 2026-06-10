# Base-rate mining report — project `PLANT-BOP`
*(verbatim agent report, 2026-06-10; locked §6 unit definition; session = one transcript file)*

## Per-transcript tally (chronological)

| # | Transcript (8) | Span | a | b | c |
|---|---|---|---|---|---|
| 1 | caad1c21 | May 1–22 (init → v81) | 14 | 2 | 0* |
| 2 | 24528eca | May 28 (soul-init, 7 min) | 0 | 0 | 0 |
| 3 | cffe3040 | May 28 (distill + coordinated build) | 1 | 0 | 4 |
| 4 | 956a5b30 | May 28 (Phase B / steam-line / alpha0) | 1 | 1 | 4 |
| 5 | 213c2693 | May 28 (slides, parallel session) | 0 | 0 | 3 |
| 6 | 64e18c09 | May 28–29 (transients / ScenarioDriver) | 2 | 0 | 5 |
| 7 | bea176b0 | May 29 (rollout / ICS rename / suite) | 4 | 0 | 4 |
| 8 | 9234d06c | Jun 9 (data request / Phase D) | 1 | 0 | 6 |
| | **Total across 8 transcripts** | | **23** | **3** | **26** |

**Grand total: 52 counted instances.** *caad1c21 (c)=0 by the file=session rule despite internal multi-day handoffs.

## Type (a) highlights — 23 total
ADR-0001 throughput pin (the FW-flow runaway why); ADR-0002 drains/deaerator divergence flag; enthalpy-based init ("linspace by enthalpy… instead of temperature (degenerate at Tsat)"); CRLF convention; Esdirk/Sdirk-over-Dassl solver rule (reverses an older note); six FWH-cascade wiring rules; the Kt `Tsat(p_mid) − 5 → + 5` calibration fix with regression comment; FW clamp; #72 calibration bundle (Body-directed); MultiPort (Body-seeded); trip-as-coastdown; lumping map; v81 FWH-preheat bundle; Documentation-HTML description convention (Body decided); record-location convention (auto-memory not witness files); steam-line ΔP + alpha0 9000→6800 re-tune; dryout=0.982 default; signal-vs-parametric fault split; load_demand stays on SO `.y` path; Dialog(group="Inputs") annotation rule (Body); ICS rename anchored on a safety-analysis document section; `ps -C dymola` seat-check; anti-anchoring data-request design.

## Type (b) — 3
1. "`ICS.N_FWPump_design` 1165→5172 + RPM limits — *correct but untested* (no re-run made)" — shipped in a wrap-up.
2. Cleanup committed with "HTML rendering visually unverified (Dymola GUI only)."
3. Phase B shipped with "Invariant 3… **unverified** — only OMC static checks ran… needs your Dymola license"; Body corrected: "dymola is available. you should verify" — the verifier-unavailability claim was itself wrong.

## Type (c) highlights — 26 total
/soul-distill mass-carry into mind.md (counted as ONE; would add ~20 if per-decision); Mind Rule 1/13 applications; Invariant-3 same-SS checks across sessions; alpha0 re-opened against #72's setting; handoff-outstanding item resolved ("transient models… never re-run — now resolved"); fence REMOVED correctly with the original reason verified moot ("the original reason for 1.5×… is now moot — the steam-line fix killed that spike"); ScenarioDriver spec implemented from prior session; recorded experiment annotations relied on; ADR-0001/0002 cited as benchmark/risk drivers in the Jun-9 session; stale dstf path convention found and repointed; deferred-by-Body decision honored; "RunbackSupervisor… never been checked against a real event" gap carried.

## Record-derived (separate)
ADRs 0001/0002/0003 (0003 carries calibration constants + ruled-out approaches); mind.md (13 rules/3 tensions/5 invariants/3 contrast cases + an explicit Incompressible-residual section naming the calibration magic numbers); CONTEXT.md deliberate-divergence flags + ANO-1↔ANO-2 non-transfer + driving table; CLAUDE.md solver/setup/line-endings notes; .soul/handoff.md point-of-temptation force ("check the seat with `ps -C dymola --no-headers | wc -l`… NOT pgrep -f"); **.soul/events.jsonl: 38 completion-gate fires across 6 of 8 transcripts**; auto-memory (28 files) encoding ~12 of the counted conventions.

## Borderlines excluded
~10 "Verify: GAP — sim in flight, will report" stops (claims withheld while the verifier ran — not (b) under conservative reading); mid-flight gate fires; doc-only OMC-parse-sufficient argument; slide placeholders (discipline held); caad1c21 internal carries (file=session rule; ~3–5 (c) under a sitting-based rule); establishments carried only by CLAUDE.md/mind.md without clean in-transcript quotes.

## Corpus caveats
1. caad1c21 dominates and deflates (c) — one file spanning May 1–22 with internal handoffs; a sitting-level split would move several (a) reliances into (c).
2. The completion gate is active only from May 22; the May 1–21 stretch has no Verify instrument — (b) likely undercounted in exactly the pre-instrument period.
3. May 22–28 gap appears genuinely idle (inferred from mtimes, not anchored).
4. 213c2693 ran in parallel with 956a5b30 — sessions not strictly serial.
5. Quotes from user/assistant text only; line refs reproducible from the .jsonl files.
6. Largest single sensitivity: the distill counted as 1 (c) — per-decision counting would raise (c) by ~20.
