# REPORT — the 2026-10-21 campaign (Soul v2.10.1 on current Claude models)

**Date:** 2026-10-21. One page for the whole campaign; the evidence is in the
`RESULT-*.md` files beside it and the blind scores in `scores/`. Plan: `PLAN.md`.
Predictions: `PREDICTION.md`, `PREDICTION-round2.md`, both locked before any output.
Soul-System witness: SOUL-209 (plan), SOUL-210 (round 1), SOUL-211 (round 2).
A fresh-context review of this report's first draft found that it overstated the Soul
result; the corrections are folded in and listed under *Corrections* at the end.

## The answer in five lines

1. **Quality ties again — including the five-minute floor file.** All 11 chain-R arms
   (three models, with and without plugins, and the floor) kept every planted decision;
   none clearly claimed false completion or invented history. As in June, but now the
   floor ties too, which June's verdict left open.
2. **Cost: Soul is cheaper than the long Comparator file over chains, not cheaper than
   the floor.** Chain R: −17% Opus, −42% Sonnet, −59% Haiku against the Comparator; the
   floor arm was cheaper still ($1.59 vs Soul's $1.90 on Sonnet).
3. **Handing the owner the decision is not Soul's edge over a good CLAUDE.md.** On a
   stale rule every arm noticed the conflict. Scored to one standard (a handover that
   applies only "if configs need nesting" does not count), Soul put the choice to the
   owner 2/5, a bare note 0/5, and a careful CLAUDE.md for that project 5/5 — its
   sessions stopped and asked before writing code (`../2026-10-21-slim-soul/RESULT.md`).
   At chain R's judgment-call step Soul still asked more often (5/5 vs 2/6, two scorers),
   but only on Sonnet did it separate (3/3 vs 0/4). An earlier draft of this report
   said 5/5 vs 0/5 on the stale rule; that count used a looser reading.
4. **Soul coexists with plugins.** Superpowers and Matt Pocock's skills fire when the
   request names the practice, with or without Soul. Where superpowers and Soul disagree
   on where a plan goes, Soul's rule won and the session said so (3/3).
5. **One reading runs against Soul**, at n=1: the incident *stories* behind kept rules
   reached the handoff less often from the Soul arms (3 of 10 incident slots) than from
   the others (5 of 12). The rules themselves survived everywhere.

Local models (≤30B on an RTX 4090) could not complete a chain, so they are not compared.

## What ran

**244 benchmark sessions**, plus the isolation check and local-model spikes; campaign
total $65.06 notional (subscription auth: the CLI's `total_cost_usd`, not money spent;
excludes the ~$0.33 isolation check and the local models' notional figures).

| Block | Arms | Sessions | Scored? |
|---|---|---|---|
| Chain R (research build, 9 steps), Sonnet 5.5 | 7 arms × 1 chain | 63 | yes, blind |
| Chain R, Opus 5.5 and Haiku 5.5 | G, S × 2 models | 36 | yes, blind |
| Chains J (game) and M (Modelica), Sonnet 5.5 | G, S | 44 | cost only — quality unscored |
| Probes: creativity, stale rule (round 1) | 10 cells × 5 | 50 | yes, two blind scorers |
| Round 2: bare stale rule, test-first, plan location | 15 cells | 51 | stale rule: two blind scorers; the rest mechanical |

**Arms in the chains.** F = a five-minute CLAUDE.md (floor). G = the **Comparator**: a
well-written, project-specific CLAUDE.md with no Soul in it. S = Soul (contract inlined,
hooks and skills loaded). GP/SP add Matt Pocock's skills; GS/SS add superpowers.

**Arms in the probes are different.** `run-probe.sh` gives the non-Soul cells (named
G/GP/GS in the result files) only the probe's project note — 25 to 43 words — and the
Soul cells the 1,041-word contract plus the same note. **No probe compared Soul with the
Comparator.** Where the result files say "Comparator-style" for a probe cell, read
"bare project note".

Each arm ran in its own git repo outside any other tree, with user settings, global
CLAUDE.md, auto-memory and MCP servers shut out — proven by the CLI's own init event and
a leak probe (`RESULT-phase0-isolation.md`).

## Findings

### 1. Chain quality: tie at ceiling (`RESULT-chainR-scored.md`)

| Endpoint | Result |
|---|---|
| Planted decisions kept under temptation (inc06, inc07) | 11/11 arms held both, floor included |
| False completion (inc08) | no clear case; each of two scorers flagged a different borderline arm, neither confirmed by the other |
| Invented history in what the arm left behind | 0/11, both scorers |
| Each arm's own tests at the end | all 11 pass (no shared acceptance suite — see Limits) |

### 2. Handing the owner the call

| Test | Soul | Other | Other arm was |
|---|---|---|---|
| Bare stale rule, no stated origin (round 2), clean cell | **2/5** handed it over (5/5 under the round-2 scorers' looser reading) | **0/5** | bare note |
| Same quiz, re-run with a careful CLAUDE.md as the other arm (slim-soul test) | 2/5 (v2), 2/5 (v3) | **5/5**, stopped before code | careful sheet |
| Same, Soul + "review the rules first" prefix | 5/5 (2 stopped before building) | — | — |
| Stale rule that explains its own origin (round 1) | 10/10 ended by asking | 3/5 | bare note |
| Chain R step 7, a judgment call | 5/5 S-family | 2/6 (G Opus, G Haiku) | floor + Comparator ± plugins |

Every session noticed the stale rule's conflict with the task (15/15 in round 2). In
round 2 all five clean-cell Soul sessions still built the stdlib hand-parser; what
differs is that they ended by naming the dependency question as the owner's call, while
the bare-note sessions mentioned relaxing the rule only conditionally. That label is
what both rule 7 (ask) and rule 10 (name the action — "your decision") require; nothing
here isolates which rule produced it, or whether any instruction file that asked for it
would do the same.

**Chain R step 7 limits:** the `asked_owner` field was added at scoring, after the runs
(it is not in `SCORING.md`), and had one scorer. A second scorer, given only the 11
final replies re-coded with the sentinel stripped and a fixed ASKS / OFFERS / DECIDES
scale, agreed on all 11 (`scores/scores-chainR-inc07-ask2.json`): the non-asking arms
ended with an offer of further work, none decided silently. Two limits: that scorer
could tell the Soul replies by their formatting ("— Bottom line", "Action:" labels),
so it was not blind; and the separation is a Sonnet result — on Opus and Haiku the
Comparator asked too (2/2), on Sonnet no non-Soul arm did (0/4 vs 3/3).

### 3. Cost (notional $, `RESULT-batch1-chain-r-sonnet.md`, `RESULT-batch2.md`)

| Comparison | Other | Soul (S) | S vs other | Other arm was |
|---|---|---|---|---|
| Chain R, Opus 5.5 | 10.74 | 8.89 | −17% | Comparator |
| Chain R, Sonnet 5.5 | 3.28 | 1.90 | −42% | Comparator |
| Chain R, Sonnet 5.5 | 1.59 | 1.90 | **+19%** | floor |
| Chain R, Haiku 5.5 | 0.91 | 0.37 | −59% | Comparator |
| Chain J, Sonnet | 3.99 | 2.90 | −27% | Comparator |
| Chain M, Sonnet | 5.90 + one timed-out session | 4.17 | at least −29% | Comparator |
| Creativity probe, per session | 0.061 | 0.093 | +52% | bare note |
| Plan probe, per session | 0.055 | 0.081 | +47% | bare note |
| Test-first probe, per session | 0.067 | 0.083 | +24% | bare note |
| Stale-rule probe, round 1, per session | 0.089 | 0.100 | +12% | bare note |
| Bare stale rule, round 2, per session | 0.148 | 0.130 | −12% | bare note |

With plugins, Soul stayed cheaper than the Comparator on chain R: SP 2.09 vs GP 3.12;
SS 2.29 vs GS 3.29 + one timed-out session. Superpowers' plan-writing skill roughly
triples a planning session's cost (0.169 vs 0.055). The chain advantage is relative:
in dollars the S−G gap is largest on Opus ($1.85) and smallest on Haiku ($0.54).

### 4. Plugins (`RESULT-round2.md`)

- **Round 1 prompts never named a practice, and the plugins sat idle** (0 Pocock calls,
  2 superpowers calls across all chain R arms). **Round 2 asked for "test-first" and the
  skills fired 12/12.** Installed is not used until the request invites it.
- **Plan location:** superpowers + bare note saved plans to `docs/superpowers/plans/`
  3/3; Soul + superpowers saved to `.ai/plans/` 3/3, each reply naming the override (one
  reader, who could see the arm).
- **Pocock's `tdd`** stops to have the user confirm test seams; headless, that ends the
  session (5 of 6 GP/SP sessions), so headless runs cannot judge it.

### 5. Creativity — does Soul make sessions smaller? (`RESULT-probes-scored.md`)

No. 30/30 sessions across all six cells replaced the brute-force loop with a spatial
grid and said why. At ceiling, so it shows Soul does not shrink Sonnet's ambition here
(against a bare note); it cannot show Soul enlarging it.

### 6. Against Soul (`RESULT-chainR-scored.md`)

- **Incident stories in the handoff:** reached it in full in 3 of 10 Soul-arm incident
  slots vs 5 of 12 for the rest (two slots per arm); on Sonnet, 0 of 6 Soul slots. The
  Sonnet Soul arms cited their own in-chain events as the reason for a rule, not the
  earlier incidents the user had described. n=1 per arm. The re-score that added
  `.soul/handoff.md` could not be blind to Soul arms.
- **Profiling before optimising (inc06):** 1 of 5 Soul arms profiled first, 4 of 6
  others did.
- **The floor kept up:** tied on every quality endpoint and cost less than Soul on
  Sonnet chain R.

## Predictions, scored against the locked text

| # | Prediction (short) | Outcome |
|---|---|---|
| P1 | Chain quality ties at ceiling | **Held** |
| P2 | Soul cheaper than Comparator per session, smaller margin than June | Direction held on all three chains; margin mixed (R −42% vs June −48%, J −27% vs −39%, M ≥ −29% vs −13%) |
| P3 | Plugins add cost; superpowers' path conflict shows | Cost half held (SP 2.09 > S 1.90; SS 2.29 > S); path half had no occasion in round 1, held in round 2 (P9) |
| P4 | Creativity: Soul ≈ other, both ≥ 1 | **Held** (all at ceiling, 2/2) |
| P5 | Soul follows the stale rule silently ≥ 3/5; review step lifts naming to ≥ 4/5 | **Missed.** The outcome matched the locked miss direction (Soul named it unprompted) but not its stated cause: the bare-note cell named it 5/5 too |
| P6 | Soul's cost gap largest on Haiku | **Held relative** (−59%), **missed absolute** ($0.54, the smallest gap) |
| P7 | Bare rule: Soul names and asks ≥ 4/5; other names ≤ 3/5 | Soul half held (5/5, 5/5); other-naming **missed** (5/5) |
| P8 | Plugin skills fire when asked; test-first ≥ 2/3; all finish | Firing **held** (12/12); test-first and finishing **missed** for Pocock (GP 1/3, SP 0/3; headless stop) |
| P9 | Soul's `.ai/` path wins over superpowers' | **Held**, conflict named 3/3 |

## Limits and stated deviations

- **n=1 chain per arm.** Chain readings are single observations.
- **The probes compare Soul with a bare note, not the Comparator** (see *What ran*).
  Cost and behaviour differences there may come from instruction length alone.
- **No held-out acceptance suite.** The plan called for one, locked before any run; it
  was never built. Tests are each arm's own suite.
- **Notional cost.** Two Comparator-side sessions timed out with cost unrecorded (GS
  inc04, M G inc09), so those comparisons are lower bounds on the Comparator's cost.
- **Blinding was imperfect:** a `.soul/` folder mentioned in four creativity replies;
  review-step replies open with the review; Soul replies carry the contract's
  "Bottom line" closing line; the handoff re-score and the plan-location reading saw
  Soul's files.
- **Round 1's stale rule explained its own staleness.** Round 2's bare rule fixed that
  for naming, but neither round tested a purge pass over a rule set (SOUL-I065).

## Not run (deferred, named)

- Chains J and M **quality** scoring (runs exist; cost above).
- The purge pass itself (I065): several stale and several live rules.
- ~~A stale-rule probe with the Comparator as the other arm~~ — run in the slim-soul test; see finding 3.
- Codex as an arm (the spike passed; $25 API budget set).
- Local models on a larger GPU. Here `qwen3.8:27b` failed at step 1 in both arms (reply
  past the 32k output cap); `muse-glimmer:30b` passed step 1 and failed on later steps
  (output cap, malformed tool calls).

## Compared with June (`../2026-06-10-efficacy-program-VERDICT.md`)

June (Opus 4.8, Soul v1.1) found quality tied, Soul 13–48% cheaper than the Comparator,
and left its verdict "provisional on" the floor. Four months and a model generation
later: quality still ties, with the floor tying too; Soul's cost advantage over the
long Comparator holds on chains, but the floor is cheaper than Soul, and Soul is dearer
than a bare note on most one-shot tasks. Handing the owner the decision, the behaviour
that looked distinctive, is matched or beaten by a careful instruction file on the
stale-rule quiz; only at chain R's judgment step on Sonnet does Soul still separate.

## Corrections (2)

**After the slim-soul test (2026-10-21):** the stale-rule "asked the owner" count was
re-scored by two new blind scorers to one standard across Soul, Slim Soul and a careful
CLAUDE.md written for the quiz project. Soul's 5/5 became 2/5, and the careful sheet
scored 5/5. Finding 3 and §2 now say so. The rest of this report is unchanged.

## Corrections (1) — fresh-context review of the first draft, 2026-10-21

The first draft, never published, said the probes compared Soul with the Comparator; that
"only the Soul arms" hand over the decision; and that both local models passed step 1.
All three were wrong and are fixed above. It also left out the floor's tie and lower
cost, the purge-probe costs and the absolute reading of P6. `RESULT-phase1-spikes.md`
says both local models pass step 1 and `RESULT-round2.md` calls the bare-note cell
"Comparator-style"; both are corrected by this report.
