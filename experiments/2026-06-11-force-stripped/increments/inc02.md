# Increment 2 — Validate the reference, and the ground-truth rule

Before any surrogate work, validate the reference solver. Standing rule for this
project: **ground truth is established by agreement between two INDEPENDENT
integrator families (different method families, ideally different libraries), to
~1e-8 on cross-check scenarios — never by a single integrator's word, however tight
its tolerances.** Implement the cross-check (e.g., an implicit Runge-Kutta family vs
a BDF/multistep family), run it on a documented scenario set, record the agreement
numbers, and wire it so the dataset generator refuses to run if the cross-check
hasn't passed for the current model version.
