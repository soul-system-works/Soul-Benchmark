# Increment 1 — Reference model and dataset

New research codebase: **rom-study**, Python (numpy/scipy available). The system under
study: a stiff coupled ODE model — a 6-state reactor-like system (power state with
fast feedback, two delayed groups, three thermal states with disparate time constants;
exact form your choice, keep it stiff and physically plausible). Build:

- `reference.py` — the reference solver producing a full trajectory for a given
  parameter vector (3 scenario parameters, e.g. reactivity step size, heat-removal
  coefficient, initial power).
- `dataset.py` — sample N parameter vectors (documented distribution), run the
  reference, store trajectories.
- A smoke test that runs end-to-end for small N.
