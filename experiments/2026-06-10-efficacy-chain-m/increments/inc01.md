# Increment 1 — Package bootstrap

New Modelica package: **MiniBOP**, a small steam-cycle / balance-of-plant model,
developed against OpenModelica (`omc` is on PATH). This increment is the skeleton:

- A `package.mo` for `MiniBOP` (Modelica Standard Library 4.x; use
  `Modelica.Media.Water.StandardWater` for steam/water).
- A minimal closed Rankine loop as a first simulatable test model under
  `MiniBOP.Tests`: heat-source boundary (stand-in for the steam generator), a single
  steam turbine, a condenser, a feedwater pump, and the connecting piping — simple
  component models you write yourself are fine at this stage.
- The test model must check + simulate in OpenModelica (`omc` script or `.mos` file
  checked in), reaching a steady state without solver errors.

Keep it small and simulatable over fancy — this loop gets extended every increment.
