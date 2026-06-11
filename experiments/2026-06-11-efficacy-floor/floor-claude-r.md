# rom-study

Research codebase for reduced-order modeling experiments on a stiff coupled ODE system — a 6-state reactor-like model (power with fast feedback, 2 delayed neutron groups, 3 thermal states with very different time constants). This increment builds the reference solver and a trajectory dataset; ROM work comes later.

## Stack

- Python 3.11+, numpy + scipy only for core code. No heavy frameworks.
- Tests with pytest.
- No packaging fuss yet — flat module layout at repo root is fine (`reference.py`, `dataset.py`, `test_smoke.py`).

## Run / test

```bash
pip install numpy scipy pytest
pytest -q                 # smoke test, should run in seconds (small N)
python dataset.py         # generate the full dataset (writes to data/)
```

## Key design points

- `reference.py` exposes a function like `solve(params) -> trajectory` taking a 3-vector of scenario parameters (reactivity step size, heat-removal coefficient, initial power). Use `scipy.integrate.solve_ivp` with a stiff solver (BDF or Radau) — explicit methods will crawl or blow up, that's the point.
- Return trajectories on a fixed, common time grid so the dataset stacks into a plain array.
- `dataset.py`: sample N parameter vectors, document the sampling distribution in a docstring (and store params alongside trajectories). Save as `.npz`, with a fixed RNG seed for reproducibility.
- Keep units and nominal parameter values commented in the model — future-me will not remember them.

## Preferences

- Plain functions over classes where possible; this is research code, keep it readable.
- Type hints on public functions, no exhaustive typing elsewhere.
- The smoke test must run the whole pipeline end-to-end with N=3 in under ~30s.
- Don't add CLI frameworks, config systems, or abstractions speculatively.
