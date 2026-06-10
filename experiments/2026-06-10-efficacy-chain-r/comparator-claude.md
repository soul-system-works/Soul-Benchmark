# CLAUDE.md — Engineering Doctrine

## What this project is

We build and evaluate **fast surrogate models** that approximate a slow, trusted
physics simulation. The surrogate's job is to reproduce the simulator's outputs at a
fraction of the cost, with **characterized and bounded error**. The deliverables are
the figures and result tables of a journal paper, plus the code and data that produce
them. The simulator is ground truth; the surrogate is an approximation whose fidelity
we must measure, never assume.

Two consequences shape everything below. First, **a result that cannot be regenerated
from committed code and recorded inputs does not exist** — it cannot go in the paper.
Second, work spans **many sessions over weeks**: different sessions extend the pipeline
and run studies. Any session, including a future one with no memory of this one, must be
able to pick up the thread from what is written down. Write for that reader.

## First principles

1. **The simulator is the reference.** Every surrogate claim is a claim about agreement
   with the simulator on data the surrogate did not train on. State the comparison and
   the metric explicitly; never let "the model is accurate" stand without "accurate to
   *what*, measured *how*, on *which* held-out data."
2. **Reproducibility is a hard requirement, not a virtue.** Same code + same recorded
   config + same seed → same numbers, within documented numerical tolerance. If a result
   is not reproducible, it is a bug to be fixed before the result is used.
3. **Provenance over recollection.** Every figure, table, and number traces back through
   a script to its inputs and the code version that made it. We trust files and logs, not
   memory or what we think we did last week.
4. **Honest uncertainty.** Report error bars, failure cases, and the regimes where the
   surrogate is *worse*, with the same prominence as headline successes. A surrogate that
   is fast and wrong is a liability; finding where it breaks is a result, not a setback.
5. **Cheap to redo, expensive to fake.** Favor designs where regenerating an artifact is
   one command. Never hand-edit a derived artifact (a number, a figure, a table cell).

## Repository layout and where things live

Keep a stable, predictable structure. When you add to it, follow the existing pattern
rather than inventing a parallel one.

- `src/` — importable library code: data loading, simulator interfaces, surrogate model
  definitions, training, evaluation, metrics, plotting helpers. No analysis decisions
  hard-coded here; this is reusable machinery.
- `experiments/` or `studies/` — one self-contained, runnable study per subdirectory.
  Each owns its config and a clear entry point. A study reads from `src/`, reads inputs,
  and writes outputs to its own results directory. Studies are append-only in spirit:
  prefer a new study over silently mutating an old one whose results may be cited.
- `configs/` — declarative experiment configuration (YAML/JSON/dataclasses). Parameters
  live here, not as literals scattered through code. A config plus a code version fully
  specifies a run.
- `data/raw/` — immutable inputs: simulator outputs, datasets as received. **Never edit
  in place, never overwrite.** Treat as read-only. If the simulator is re-run, that is a
  new dataset with a new identifier, not a replacement.
- `data/processed/` — derived data, regenerable from `raw/` by committed code. Deletable
  and rebuildable at any time. Nothing here is precious.
- `results/` — run outputs: metrics, predictions, checkpoints, logs. Organized so a run
  is identifiable by config name + code version + seed.
- `figures/` and `tables/` — paper-bound artifacts, each produced by a named script.
- `notebooks/` — exploration only. Findings that matter get promoted into `src/` and a
  reproducible script. Notebooks are scratch, never the source of a paper number.
- `docs/decisions/` — the decision log (see below).
- `docs/lab-notebook.md` — the running session log (see below).

If reality diverges from this description, fix the divergence or fix this file. A
doctrine that lies about the repo is worse than none.

## Environment and determinism

- **Pin everything.** Dependencies are locked to exact versions (lockfile or pinned
  environment spec). Record the Python version and key library versions. An experiment
  result is only meaningful alongside the environment that produced it.
- **Seed everything and record the seed.** Every source of randomness (NumPy, the ML
  framework, data shuffling, CV splits, initialization) is seeded from a value stored in
  the run's config and written into the run's output. Reproducing a run means re-reading
  its recorded seed, not picking a fresh one.
- **Capture the environment per run.** Each run records: code version (git commit or, if
  the tree is dirty, commit + a saved diff — never run a recorded experiment on
  uncommitted changes you cannot reconstruct), config used, seed, library versions,
  hardware/accelerator if it affects numerics, and start/end time.
- **Name nondeterminism explicitly.** Some GPU ops, parallelism, and floating-point
  reductions are not bitwise reproducible. Where exact reproduction is impossible,
  document the expected tolerance and assert results fall within it, rather than pretending
  determinism you don't have.

## Data discipline

- `data/raw/` is sacred and immutable. Simulator output is expensive to produce and is our
  ground truth; losing or corrupting it is the worst outcome in the project. Read-only.
- Every processed dataset is regenerable by a committed script from raw inputs, and records
  which raw inputs and which code produced it. If you cannot say where a `.npy` / `.csv` /
  `.parquet` came from, it is not usable for the paper.
- **Splits are decided once, recorded, and never leaked.** Train/validation/test partitions
  (and any held-out physics regimes) are defined explicitly, stored, and reused. The test
  set is touched only for final evaluation — not for model selection, not for tuning, not
  for "just checking." Tuning against the test set silently invalidates every downstream
  claim.
- Guard against leakage actively: correlated simulation samples (same parameter sweep,
  adjacent time steps, shared boundary conditions) must not straddle the train/test
  boundary. When in doubt, split along the physically independent axis, and write down why.

## Experiment discipline

- **Config-driven, not edit-driven.** To run a variant, write or modify a config, not the
  source. This keeps runs comparable and self-describing.
- **One run, one record.** Each run writes a self-contained results directory: the resolved
  config, seed, environment capture, metrics, and enough artifacts (predictions,
  checkpoints) to audit it without re-running. The headline metrics live in a machine-
  readable file (JSON/CSV), not only in stdout.
- **Log enough to debug a result you'll see in three weeks.** Future-you will not remember
  why run 47 looked odd. Log the inputs, the key intermediate shapes/statistics, and any
  warnings.
- **Baselines are mandatory.** A surrogate's quality is meaningless in isolation. Always
  evaluate against simple references (the simulator itself for cost; a trivial predictor —
  mean, nearest-neighbor, linear, or a coarse-grid simulation — for accuracy). "Better than
  nothing" must be demonstrated, not assumed.
- **Compare like with like.** When comparing surrogate variants, hold the data, splits,
  seeds, and metrics fixed. Change one thing at a time. A comparison across two different
  test sets is not a comparison.

## Scientific rigor for surrogate evaluation

- **Error is measured against the simulator on held-out inputs**, reported with both
  aggregate metrics and their distribution (not just a mean — show tails, worst cases, and
  where in input space they occur). A good mean error hiding catastrophic outliers is a
  failure we must surface.
- **Characterize the domain of validity.** Identify and report the regions of input /
  parameter space where the surrogate is trustworthy and where it degrades or extrapolates.
  A surrogate is a tool with an operating envelope; the envelope is part of the result.
- **Respect the physics.** Where the simulator obeys conservation laws, symmetries,
  monotonicities, or known limiting behaviors, check whether the surrogate does too, and
  report violations. Physical plausibility is evidence the metric alone won't give you.
- **Account for surrogate uncertainty** where the modeling approach provides it, and be
  explicit when it does not. Don't present point predictions as if they were certain.
- **Cost is a first-class result.** The entire premise is speed. Measure and report the
  surrogate's cost (wall-clock, evaluations) against the simulator's, under stated and fair
  conditions, alongside its accuracy. An accuracy claim without a cost claim misses the point.

These are standing principles, not a prescribed methodology. The specific metrics, splits,
baselines, and acceptance thresholds for each study are **decided per study, written into
its config and decision log, and justified there** — not dictated in advance by this file.

## Verification before a result is claimed

A number is "claimed" the moment it influences a decision, a figure, or a sentence in the
paper. Before that:

1. **Regenerate it.** Run the producing script end to end from recorded inputs. A result you
   cannot reproduce on demand is not yet a result.
2. **Sanity-check it.** Does the magnitude make physical sense? Do limiting cases behave?
   Does it agree with an independent rough estimate? Surprising results get *more* scrutiny,
   not less — the instinct to celebrate a great number is exactly when to suspect a leak, a
   mislabeled axis, or a train/test mixup.
3. **Trace it.** Confirm the figure/table is generated by committed code from identified run
   outputs, with no manual touch-ups.
4. **State its scope.** Record what data it was measured on and what it does and does not
   support. Distinguish what was *measured* from what is *inferred*.

When reporting to the user, separate verified results from expectations. Say plainly what was
run, what passed, what was skipped, and what remains uncertain. If a study failed or a metric
came out poorly, report it with the evidence — negative results are findings and must be
recorded, not buried. Never present a hoped-for outcome as an observed one.

## Figures, tables, and the paper

- Every paper artifact is produced by a **named, committed script** that reads identified run
  outputs and writes to `figures/` or `tables/`. No manual editing of generated files.
- A figure caption's claims must be checkable against the data behind it. Keep the path from
  artifact → script → run → data short and explicit.
- When a result changes, regenerate the artifact; never patch the old one. The paper cites
  what the code produces today.
- Keep a manifest mapping each paper figure/table to the script and run that produces it, so
  the full set can be rebuilt before submission.

## Documentation and decision recording

- **Decision log (`docs/decisions/`).** Record every consequential choice — modeling
  approach, split strategy, metric selection, what to drop, why a study was designed a
  certain way — as a short dated entry: the context, the options weighed, the decision, and
  the reasoning. Convert relative dates to absolute. Months from now, the log is how anyone
  (including a fresh session) understands *why* the pipeline looks as it does. Decisions made
  only in conversation are lost; write them down.
- **Lab notebook (`docs/lab-notebook.md`).** A running, dated log of what was run, what was
  found, what surprised us, and what's next. This is the connective tissue across sessions.
- **Comments and docstrings** explain intent and the non-obvious — why this transform, why
  this guard, what assumption holds here — not what the line literally does.

## Multi-session continuity

Because sessions are disjoint in memory, the written record *is* the project's memory:

- **Start of session:** read the recent lab-notebook entries and any open items in the
  decision log before acting. Understand the current state from the files, not from
  assumptions.
- **End of a substantive session:** append a lab-notebook entry — what changed, what ran,
  results, and concrete next steps. Leave the tree in a state a stranger could resume.
- **Leave breadcrumbs**, not cliffhangers. A half-finished study should say, in writing, what
  is done, what is pending, and how to continue.

## Collaboration and working rules

- **Match the surrounding code.** Follow existing structure, naming, and idioms; don't
  introduce a second way to do a thing that already has one.
- **Smallest change that does the job.** Surgical edits over sweeping rewrites. Don't
  refactor working pipeline code opportunistically while doing something else — propose it
  separately, because a quiet change to shared machinery can silently shift every downstream
  result.
- **Surface assumptions.** When a task is underspecified in a way that affects scientific
  validity (a split, a metric, a tolerance), state the assumption and confirm rather than
  guessing.
- **Confirm before destructive or irreversible actions** — deleting results, overwriting
  data, force-changing history. Before deleting or overwriting anything you didn't create
  this session, inspect it; if it contradicts how it was described, stop and report.
- **Don't change committed experiment outputs.** Past run directories are the record. Add new
  ones; don't rewrite history that may already be cited.
- **Tests and checks for the machinery.** The reusable code in `src/` — metrics, data
  splitting, leakage guards, transforms — carries tests, because a bug there silently
  corrupts every study built on it. When a bug is found, add a regression test before fixing.

When these rules and a request conflict on a matter of scientific integrity or
reproducibility, raise it rather than quietly complying. The paper's credibility rests on the
discipline above.
