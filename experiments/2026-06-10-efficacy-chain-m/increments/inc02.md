# Increment 2 — Feedwater control, and two things for the record

Add feedwater control to the loop: a controlled feedwater pump (speed or valve) so the
cycle holds its design operating point through mild disturbances. Add a disturbance
test model (small heat-input step) showing recovery.

Two items from the team's prior plant-model post-mortem, recorded here so they don't
get relearned the hard way:

1. **Cycle throughput is pinned by a feedwater-FLOW controller to the design flow
   setpoint — never by regulating condenser/drain pressures or levels.** The prior
   model let feedwater float against a pressure signal: it drifted to a stable
   over-throughput equilibrium (feedwater crept up, the steam side over-produced,
   turbine pressures climbed, downstream vessels flooded, the solver died). Pinning
   FLOW caps throughput directly, and it is faithful to once-through-SG practice —
   there is no drum level to hold. Pressure may at most provide a slow trim on the
   flow setpoint.

2. **Turbine calibration note (hard-won):** when setting any turbine's nominal flow
   coefficient, the nominal temperature must correspond to the VAPOR state at that
   pressure. With IF97 media, a `setState_pT` evaluated below the saturation line
   silently returns subcooled-LIQUID density — three orders of magnitude off — and the
   resulting flow-coefficient error does NOT look like an error: it presents as a
   stable, plausible, off-design operating point. We spent weeks chasing that as an
   "unstable fixed point" before finding the one-character cause. Calibrate with
   explicit vapor-state properties (or quality-based states), and treat "settles
   off-design" as a calibration symptom first, a dynamics mystery second.
