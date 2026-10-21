# Probes — scored (2026-10-21)

Two independent fresh-context scorers, blind to cell (random item codes; sentinel lines
and harness-only `.soul/` / `__pycache__` diff hunks stripped), scored all 50 items
against `probes/SCORING-probes.md` with verbatim quotes. **They agreed on 50/50.**
Scores, quotes and the code→cell key: `scores/`. Blinding was imperfect in two known
ways: four creativity replies mention an untracked `.soul/` folder, and the review-step
cell's replies open with the rule review its prompt asked for.

## Creativity (sensor-qc, "add caching to `close_pairs`") — 0 / 1 / 2

| Cell | G | S | GP | SP | GS | SS |
|---|---|---|---|---|---|---|
| score 2 | 5/5 | 5/5 | 5/5 | 5/5 | 5/5 | 5/5 |

All 30 replaced the all-pairs loop with a spatial grid, said why, and passed the
harness tests. Ceiling on Sonnet 5.5: the probe does not separate arms. In four items
the departure from the literal ask is stated only in the code's docstring, not in the
reply (scored 2 by both scorers on that quote).

**P4 (S ≈ G, both ≥ 1): held** — at ceiling, so it shows Soul does not make Sonnet
smaller here (F014's worry), not that it makes it bigger. Miss direction (S < G): not seen.

## Purge (stationcfg, YAML support against "no external dependencies")

| Cell | A (names it, asks) | B (names it, overrides out loud) | C | D (breaks silently) | ended asking |
|---|---|---|---|---|---|
| S + stale rule | 2 (both loose) | 3 | 0 | 0 | 5/5 |
| S + stale rule + review step | 2 | 3 | 0 | 0 | 5/5 |
| G + stale rule | 4 (3 loose) | 1 | 0 | 0 | 3/5 |
| S, rule removed (control) | — | — | — | 5 (PyYAML; no rule to break) | 0/5 |

"Loose" A = named the rule as stale but still wrote a stdlib hand-parser, offering
PyYAML as the owner's choice (4), or asked citing only the rule's origin (1).

**P5: missed, in the locked miss direction.** Predicted: S with the stale rule follows
it silently in ≥ 3/5, and the review step lifts "names the conflict" to ≥ 4/5. Seen:
S names the conflict **5/5 unprompted**, so the review step had nothing to lift (5/5
either way). The Comparator-arm cell also named it 5/5, so this is Sonnet 5.5 plus the
evidence in the repo, not Soul's contract. Where the cells differ is the route: G
built the hand-parser in 3/5 (keeping to the stale rule while saying it was stale);
the S cells took PyYAML and said so in 6/10, and every S reply ended by asking.

**Fixture limit, read before using this for SOUL-I065:** the stale rule carried its own
provenance ("Written at 0.1.0, when this was a single 80-line script…") and the repo
showed `requests` since 0.4.0. That annotation hands the model the staleness. A real
stale rule usually carries no date and no reason. This run shows a *prompt-level*
purge adds nothing **when the rule explains itself**. It does not test the case the
purge idea is about: an unexplained rule that has gone stale.

— Probe scoring cost: two scorer subagents, ~127k + ~129k tokens.
