# Workflow value, round 2 — prediction (written 2026-10-30, before any counted run)

Locked by the commit that adds this file; edits after the runs go in RESULT.md, never
here. Written by the host session that designed the review arms, so it leans toward
review helping (the Soul System's mind item 1: lean toward the claimed benefit, and name
the likely miss).

## What runs

Four SWE-bench Pro tasks that split the pilot (`ansible-3`, `ansible-4`, `ansible-5`,
`flipt-3`), 3 runs each, two paired arms:

- **T** — Sonnet implements; graded (that grade is the **S** row: Sonnet alone); Opus
  reviews read-only; Sonnet resumes its session and fixes; graded again (the **T** row).
- **R** — the same with the local Qwen model (`qwen3.8:27b-q8_0`) as implementer; its
  first grade is the **Q** row.

Caps: Sonnet 90 min, Qwen 150 min, review 30 min, fix 60 min.

Pilot, one run each on these four tasks: Opus 4/4, Sonnet 1/4, Qwen 1/4. These tasks
were picked *because* Sonnet or Qwen missed them, so fresh plain runs should resolve
more than the pilot did (selection, not improvement).

## Quality (resolved runs out of 12)

| Row | Predicted | Range |
|---|---|---|
| S (Sonnet alone) | 4 | 2–6 |
| T (Sonnet + Opus review) | 9 | 7–11 |
| Q (Qwen alone) | 3 | 1–5 |
| R (Qwen + Opus review) | 7 | 5–9 |

- Review never turns a resolved run into an unresolved one more than once per arm.
- On ansible-3 and ansible-4 (where Sonnet and Qwen failed the same hidden tests in the
  pilot), the Opus review names the missing behaviour in at least 2 of 3 runs per arm.

## Cost and time

- The Opus review costs at most $0.60 per run (median).
- A T run's total Claude cost (Sonnet + review) stays below Opus-alone's pilot cost on
  the same task in most runs (Opus pilot on these four averaged $0.60).
- An R run spends Claude money only on the review.
- Qwen's runs take 10–20× Sonnet's wall time; about 20–25 h of GPU time in all.

## Miss-direction guesses (where this is most likely wrong, and which way)

1. **Review lifts less than predicted.** Sonnet and Qwen failed the *same* hidden tests,
   which hints at a requirement the spec leaves implicit. A reviewer reading the same
   spec may not see it either. Most likely miss: T near 6/12 and R near 4/12.
2. **Qwen does not act on a correct review.** The fix stage resumes a long local session;
   Qwen may run out of context or time before it applies the findings. R then lands
   closer to Q than to T.
3. **Plain runs do better than predicted** (regression from the pilot), which shrinks
   the gap that review can show.
4. **The review costs more than predicted.** Opus may run the tests and read widely on an
   ansible tree, pushing the median above $0.60.

## Known limit

These are public repositories. Every model recalls some of the upstream fixes from
training (the pilot's leak hits are recall, not lookups: no run fetched anything). This
affects every row alike.
