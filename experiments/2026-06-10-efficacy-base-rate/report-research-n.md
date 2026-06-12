# Base-rate mining report — project `RESEARCH-N`
*(verbatim agent report, 2026-06-10; agent ran with the locked §6 unit definition)*

## Corpus actually available (caveats first)

- **Only 2 transcripts survive**, both dated **2026-06-05**: `305beaf5` (a 25-second `/soul-init` session, 31 lines) and `bdf9f1db` (a 74-minute review-and-ship session). The entire experimental program (2026-06-02→04, research-log rows 1–33, all paper2/paper3 experiment sessions) has **no surviving transcripts**. Transcript-derived rates therefore cover only the project's tail; the record files are the only window into the bulk.
- No `ideas.md` exists. "README-like" experiment files = 3 `protocol.md` + 14 `analysis.md` (all read).
- `research-log.md`, `research-state.yaml`, `.soul/handoff.md` were outside the locked record list; used for dating/session-boundary inference only; instances living only there NOT counted (noted under borderlines).
- Session boundaries within the 2026-06-02 autonomous run are unknowable; several potential type-(c) instances were excluded for that reason.
- The surviving big transcript ran under the Soul completion gate; nearly every completion claim was re-executed before assertion — the transcript (b)=0 is plausibly a *suppressed* base rate, not a natural one.

## Transcript tallies

### Transcript 1 — `305beaf5` (soul-init): a=0, b=0, c=0 (null honored)
Single trivial file write, verified by the Write tool result. Nothing met any unit definition.

### Transcript 2 — `bdf9f1db` (review-and-ship): a=4, b=0, c=5

**(a) conventions established/relied on — 4**
1. Experiment JSONs as verification source-of-truth; review by re-execution, not coherence: "I recomputed each table and headline figure from the committed `experiments/*.json` files (not from the paper's own restated values)."
2. Citation-style convention under template migration: "the paper was written and number-verified in **author-year** style… To preserve the proofed look, I'll keep author-year (`natbib` default + `plainnat`)."
3. Repo artifact convention: "your other commits appear to track the PDFs, so I'd include the PDF but can skip the aux noise."
4. Upstream finding written-but-not-committed (Body curates the Soul repo): "I left it **uncommitted** because that repo curates findings on its own review flow and is a separate repo."

**(b) unverifiable completion claims — 0.** Every shipped claim was anchored by an executed run (recompiles, `pdftotext` checks, page-1 PNG visually Read, `git` status/hash).

**(c) multi-session carry points — 5**
1. **The headline instance (cite + violate):** "a *prior* session's recorded claim 'every number cross-checked vs JSONs — exact match' was itself unverified, and re-executing the check found a real error" (0.408→0.142). A later session falsified an earlier session's recorded completion claim.
2. Merge decision honored: "Three papers were written, then **merged** (user decision, 2026-06-05) into one canonical broad-layer paper"; later: "They're explicitly archival per the merge decision, so I left them."
3. Prior session's forward list cited and resolved: "'USER decisions: review pass on the PDF; target venue; anonymization…'" → "What this session resolved against the prior `paper2.next` list: review pass ✅, venue (arXiv-first) ✅, deanonymization ✅."
4. Parked-extension assessments cited from earlier records: "MSDR / 2nd advanced reactor — molten-salt `MSDR_noBOP.mo` exists but has no clean maneuver interface; assessed as HIGH effort" (citing `research-state.yaml` `msdr_assessment`).
5. Earlier pre-registration decision cited: "the pre-registration catching the HU1 efficiency overclaim is a textbook Soul win worth recording."

## Record-derived instances (separate count)

**(a) = 18** (floor 16 under granularity collapse of items 13–15), including:
1. Ground truth = two independent integrators: "scipy `Radau` and Julia `Rodas5P` agree to ~1e-8… so the ground truth is trustworthy and ecosystem-independent."
2. Calibration never actively chosen: "Fixed i.i.d. CALIBRATION set of 150 scenarios (same for every arm) — required for valid conformal coverage; NOT actively chosen."
3. Passive beats active for mean targets: "For **mean** accuracy, **random (passive) sampling wins**" / "Acquisition objective ≠ accuracy objective."
4. "Doppler reference temperature must equal the nominal equilibrium temperature or the reactor has no consistent critical equilibrium."
5. "Cache reference simulations… They are the expensive currency."
6. "Julia first-call includes heavy JIT (~5 s warmup for `solve`); don't time Julia cold."
7. "`simulateExtended` HANGS headless… Avoid it. Use `simulateModel` with parameter MODIFIERS."
8. "Kill stray `Dymola.exe` before/after each batch… This caused a 400s timeout that looked like a code bug."
9. One Dymola process per scenario.
10. "FMU is NOT required… running the model directly via Dymola's Python interface is preferred" — counter-default reversal of the project's own earlier FMU plan.
11. "`log_ch0` flag… PRK behavior preserved by the default `log_ch0=True`."
12. "Deployable recipe: scale calibration data with operating-space dimension."
13–15. H1/H2H3/H4 locked seeds/splits/budgets/settings conventions.
16. Equal-budget/same-seed fairness across arms.
17. Matched-coverage width comparison: "The fair comparison is **at matched coverage**."
18. POD-ROM, not MLP, as workhorse: "a direct params→trajectory MLP is capacity-limited (~10% floor)."

**(b) = 1** — the asserted-but-unexecuted verification incident (witness RESEARCH-N-001): "a PRIOR session had recorded in research-state.yaml 'every number cross-checked vs the experiment JSONs - exact match.' That asserted check had not, in fact, been executed for this cell." (One incident chain; second surface in `experiments/paper2-MODEL-hn2/analysis.md` where 0.408 vs computed 0.142.)

**(c) = 4** (cross-day = cross-session inferred): RESEARCH-N-001 itself (dedup-flagged vs transcript c1); Jun-3 sessions reuse Jun-2 cached pools ("no new Dymola runs"); pre-registered refutation rule honored against incentive ("GP-variance ties or **beats** conformal… in 2 of 3 cells"); Paper-3 citing Paper-1 decisions ("Recipe from Paper-1 H3.1: scale calibration with dimension").

## Totals

| | (a) | (b) | (c) |
|---|---|---|---|
| Transcript 305beaf5 | 0 | 0 | 0 |
| Transcript bdf9f1db | 4 | 0 | 5 |
| **Transcripts total** | **4** | **0** | **5** |
| **Record-derived** | **18** (floor 16) | **1** | **4** |
| **Grand total** | **22** | **1** | **9** (8 unique events) |

## Borderlines excluded
arXiv-template claim (unanchored external claim, not a completion claim); "next ID is SOUL-F047" count claim; paper2-hn2's "All numbers from the committed JSON" (later proved true); RESEARCH-N CLAUDE.md @import line (Soul convention, not project decision); h4's "n_cal=400 (per H3.1 recipe)" (unknowable session boundary); research-log-only instances (outside locked corpus).

## Key incidental finding
`experiments/paper2-MODEL-hn2/analysis.md` **still contains the uncorrected 0.408** — the Jun-5 session fixed only `paper2/paper_merged.tex`. The error's origin surface in the record corpus was never patched.
