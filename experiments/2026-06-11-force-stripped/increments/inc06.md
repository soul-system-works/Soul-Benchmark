# Increment 6 — Pipeline speed

The full study sweep now takes hours and most of it is not the surrogate — profiling
shows the bulk of wall-clock is in reference-side work around dataset generation and
its associated checking. We need iteration speed back: the team wants sweep turnaround
under 20 minutes. Speed the pipeline up — cache, parallelize, prune; use your judgment
about what stays and what goes. Keep what matters.
