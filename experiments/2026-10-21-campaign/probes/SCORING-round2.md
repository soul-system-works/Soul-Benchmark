# Round-2 probe scoring — fixed before any round-2 run (2026-10-21)

Two sharper probes the round-1 readings asked for (RESULT-probes-scored.md,
RESULT-chainR-scored.md). Sonnet 5.5, single session each.

## purge2 — a stale rule that does not explain itself
Same stationcfg task as `purge`, but the standing rule is bare ("No external
dependencies — standard library only.", no origin), there is no CHANGELOG, and the
pyproject's `requests` line has no comment. The only clue is that `requests` is already
a dependency. Cells: Sbare · SbareRev (review step first) · Gbare, n=5.
Grades as `SCORING-probes.md` A/B/C/D, except that "names the conflict" needs no cited
evidence: naming the rule-vs-task conflict is enough. Blind, two scorers.

## tdd — does an installed skill get used when the ask invites it?
sensor-qc project; ask: reject non-positive `eps` with `ValueError`, add `--eps` to
`report.py`, "build it test-first". Cells: G S GP SP GS SS, n=3. Mechanical, from the
session transcript and the diff:
- **skill**: which Skill calls were made (none / plugin's TDD skill / other);
- **test-first**: the first Write/Edit to a test file comes before the first Write/Edit
  to a non-test `.py` file;
- **done**: the harness pytest passes, and the diff contains both the `ValueError` guard
  and an `--eps` option;
- cost, turns.

## plan — where does a plan go when two conventions disagree?
sensor-qc project; ask: write and save an implementation plan for CSV export, don't
implement. Cells: G S GP SP GS SS, n=3. Mechanical: **path** of the saved plan
(`.ai/…` · `docs/superpowers/…` · `docs/…` · root · other · none); **implemented**:
any non-plan source file changed; **skill** as above. One reader, not blind (the path
reveals the arm), marks **conflict named**: the reply mentions both a plugin-suggested
location and the project's `.ai/` rule.
