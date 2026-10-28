# Workflow value — prediction (written 2026-10-28, before any arm ran)

Written by the host session that built `/soul-workflow`, so it leans toward its own tool;
the miss-direction guesses below are there to make that lean visible. Locked by the
commit that adds this file; edits after the runs go in RESULT.md, never here.

## Quality
- All three arms pass `check.mjs` (it is a minimum).
- On the 12 must-haves, A, B and C land within 1 item of each other. Reason: a small,
  fully specified build sits near the ceiling for this model (the Soul System's mind
  item 8: chain quality has tied at ceiling in every measurement so far).
- Playability (1–5, two blind scorers): within 1 point across arms. If one arm leads,
  C, because two reviewers read the code before it is accepted — a weak lean.

## Speed
- A is fastest. B is about as fast as A or slower (subagents, the completion gate).
- C is slowest: workers start as separate processes, the host re-runs the check, two
  reviewers run, and any repair round repeats all of it. Guess: C takes 1.5–2.5× A's
  wall time.

## Usage
- **Opus tokens:** C < A ≤ B. C hands the implementing to Sonnet; B's global rule sends
  implementation to an Opus `implementer` subagent, so B may spend the most Opus.
- **Total tokens, all models:** C is highest (Sonnet worker + Opus and Codex reviews on
  top of the host).
- **Interventions:** A and B 0–1; C 1–3 (the roles line, the ladder, any question the
  workflow sends back).
- C's host follows v3.7.2 and dispatches the implementing; it does not hand it to its
  own `implementer` subagent.

## Miss-direction guesses (where this prediction is most likely wrong, and which way)
1. **C saves less Opus than predicted** — the host still spends Opus writing the brief,
   reading the patch, re-running checks and weighing reviews. Most likely miss: C's Opus
   tokens land close to A's, not clearly below.
2. **B is cheaper than predicted** — the host may not hand this small build to a subagent
   at all; B then looks like A plus overhead.
3. **Quality is not a tie** — a 12-item spec with gameplay may leave one arm visibly
   unfinished; if so, the time cap (90 min), not the method, is the likely cause.
4. **C's host ignores the precedence rule** under the owner's global CLAUDE.md and uses
   its own subagent — v3.7.2's wording is unrun against a contrary rule.
