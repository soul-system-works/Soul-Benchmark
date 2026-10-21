# Round 2 — bare stale rule, skill use, plan location (2026-10-21)

51 Sonnet 5.5 sessions, no errors or timeouts, $5.15 notional (campaign total $65.06).
Fixtures, scoring and predictions were committed before any output (`7d7640a`).
Scores: `scores/` (`*purge2*`, `round2-tdd.md`, `round2-plan.md`).

## purge2 — a stale rule with no stated origin (n=5, two blind scorers, 15/15 agreement)

| Cell | Named the conflict | Put the choice to the user | Route | mean $ |
|---|---|---|---|---|
| Soul, bare rule | 5/5 | **5/5** | hand-parser 5 | 0.130 |
| Soul, bare rule + review step | 5/5 | **5/5** | hand-parser 3, stopped to ask 2 | 0.092 |
| Comparator-style, bare rule | 5/5 | **0/5** | hand-parser 5 | 0.148 |

Every session noticed the rule conflicted with the task, and 14/15 pointed out that
`requests` is already a dependency. The cells split on what happened next. All ten
Soul sessions put the dependency decision to the owner. All five non-Soul sessions
built the stdlib parser, mentioned relaxing the rule only as a conditional, and did
not ask; both scorers marked those "loose A" for that reason. No session broke the
rule silently, and none dropped it silently.

**P7: partly held.** "Sbare names ≥4/5 and asks ≥4/5" held (5/5, 5/5). "Gbare names
≤3/5" missed: 5/5, the locked miss direction on *naming*. The separation is on
*asking* (10/10 vs 0/5), which is the contract's rule 7. Across both purge rounds the
review step changed nothing measurable.

## tdd — "build it test-first" (n=3, mechanical)

| Cell | Plugin skill invoked | Test written first | Finished | mean $ |
|---|---|---|---|---|
| G  | — | 3/3 | 3/3 | 0.067 |
| S  | — | 3/3 | 3/3 | 0.083 |
| GP | Pocock `tdd` 3/3 | 1/3 | 1/3 | 0.070 |
| SP | Pocock `tdd` 3/3 | 0/3 | 0/3 | 0.051 |
| GS | superpowers TDD 3/3 | 3/3 | 3/3 | 0.099 |
| SS | superpowers TDD 3/3 | 3/3 | 3/3 | 0.124 |

The five unfinished GP/SP sessions all stopped on Pocock's `tdd` step that has the
user confirm the test seams first ("Before I write any tests, I need you to confirm
which seams to test"). This is the skill working as designed; headless, it ends the
session. It is not a failure of the arm.

**P8: held on invocation** (3/3 in every plugin cell; the miss direction, installed
but unused, did not happen once the ask named the practice). It **missed** on "done
3/3 in every cell" and "test-first ≥ 2/3" for GP and SP, for the reason above.

## plan — "write an implementation plan and save it" (n=3, mechanical)

| Cell | Plan saved at | Skill | Implemented | mean $ |
|---|---|---|---|---|
| G, GP | root `PLAN*.md` 6/6 | — | 0/6 | 0.055 / 0.058 |
| S, SP | `.ai/` 6/6 | — | 0/6 | 0.081 / 0.084 |
| GS | `docs/superpowers/plans/` 3/3 | writing-plans 3/3 (+ brainstorming 1) | 0/3 | 0.169 |
| SS | `.ai/plans/` 3/3 | writing-plans 3/3 | 0/3 | 0.169 |

All three SS replies name the override, e.g. "I put it there rather than the skill's
default `docs/superpowers/plans/` because CLAUDE.md sends working files to `.ai/`."

**P9: held** (S/SP `.ai/` 6/6; GS `docs/superpowers/` 3/3; SS `.ai/` 3/3 with the
conflict named 3/3; nothing implemented). The miss direction, SS following the plugin
path silently, did not happen. Superpowers' writing-plans roughly triples a planning
session's notional cost.

## What round 2 adds to round 1

- **Soul's measurable behavioural effect is asking the owner**, not noticing: on a
  stale rule, every arm notices, but only Soul arms hand the decision back (10/10 vs
  0/5 here; 5/5 vs 2/6 at chain R's inc07).
- **Plugins are used when the ask invites them**, so round 1's "installed, not used"
  belongs to the round-1 prompts, not to the plugins.
- **Soul and superpowers coexist:** Soul's path rule wins, out loud. Pocock's `tdd`
  needs an owner present, so headless runs of it measure the stop, not the work.
