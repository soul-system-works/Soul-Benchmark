# MiniBOP

Small Modelica package modeling a steam-cycle / balance-of-plant (Rankine loop:
heat source → turbine → condenser → feedwater pump). Built incrementally — this
increment is just the skeleton + one simulatable test loop. It will be extended
every increment, so keep components small and simple over clever.

## Stack

- Modelica, against **Modelica Standard Library 4.x** (OpenModelica's bundled MSL is fine)
- Water/steam medium: `Modelica.Media.Water.StandardWater` everywhere
- Tooling: OpenModelica only — `omc` is on PATH. No Dymola-specific stuff.

## Layout

- `MiniBOP/package.mo` — top-level package (use the directory/package.mo file layout,
  one class per file, so diffs stay readable)
- `MiniBOP/Components/` — turbine, condenser, pump, pipe etc. Hand-written simple
  models are fine; don't pull in Fluid library complexity yet.
- `MiniBOP/Tests/` — simulatable test models, starting with the closed Rankine loop
- `scripts/` — `.mos` scripts for check + simulate

## Build / test

No build step. Verify with omc:

```sh
omc scripts/check.mos      # loadModel + checkModel on everything
omc scripts/simulate.mos   # simulate the test loop
```

## Preferences

- Keep models small and physically simple; correctness of the loop closing >
  fidelity of individual components
- Give every parameter a unit and a sensible default; add a one-line comment/doc
  string per model
- Watch initialization: pick explicit start values so the steady state is reached
  reliably, not by luck
- Don't add components or media options the brief doesn't ask for
