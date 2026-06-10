# CLAUDE.md — Engineering Doctrine

This is a Modelica library modeling a small steam-cycle / balance-of-plant
system (turbines, feedwater heaters, condenser, pumps, and their controls). It
is developed and verified against **OpenModelica**. We do not run a unit-test
harness; our verification artifacts are **simulatable test models**. Development
happens across many sessions over time — treat everything you write as something
a stranger (or you, months from now) must pick up cold.

This file is the contract for how we work. Read it at the start of every
session. When it conflicts with a quick win, the doctrine wins.

---

## 1. First principles

- **A model that does not simulate is worthless, no matter how elegant.** The
  bar for "done" is a clean simulation run with results that survive physical
  scrutiny — not a green compile, not a plausible-looking diagram.
- **Physical correctness outranks numerical convenience.** Never reach for a
  trick that makes the solver happy at the cost of violating mass, energy, or
  momentum balance. If you must trade fidelity for tractability, say so
  explicitly and record why (§7).
- **Small, reversible steps.** Extend the model one component or one behavior at
  a time, and prove each step simulates before stacking the next. A 400-line
  change that fails to translate teaches you nothing about which line is wrong.
- **The next session knows nothing.** Leave the repository, the test models, and
  the decision record in a state where someone with no memory of today can
  understand what exists, what works, what is provisional, and what is next.

---

## 2. Modeling practices

### Structure and reuse
- Build on the **Modelica Standard Library** (`Modelica.Media`,
  `Modelica.Fluid`, `Modelica.Thermal`) before writing your own. Reinventing a
  medium model or a heat-transfer correlation is how subtle bugs enter.
- Prefer **`replaceable` media and `partial` base components** so the same
  geometry can be re-medium'd or re-parameterized without forking. Use
  `connector`s and standardized interfaces (`FluidPort`, `HeatPort`) so
  components compose; do not invent a bespoke port when a standard one fits.
- Keep one component concept per file/class. A class that models "a heater and
  its controller and its valve" cannot be tested, reused, or reasoned about.
- Parameterize, don't hardcode. Every dimension, area, nominal pressure,
  efficiency, and setpoint is a `parameter` with units and a sensible default.
  Magic numbers buried in equations are forbidden.

### Units, attributes, and self-documentation
- **Always use `SI` types** (`Modelica.Units.SI.Pressure`, `.MassFlowRate`,
  `.SpecificEnthalpy`, …). Never a bare `Real` for a physical quantity. The unit
  system is your first line of defense against an entire class of errors.
- Set `start`, `nominal`, `min`, and `max` attributes deliberately on state and
  flow variables. `nominal` is not decoration — it scales the solver's error
  control, and a missing or wrong `nominal` (e.g. enthalpy left at 1) is a
  common cause of false convergence or needless step rejection.
- Give every public class, parameter, and connector a one-line
  description-string. If you cannot describe what a parameter physically means in
  a few words, you do not yet understand the model.

### Connections and balances
- For every control volume, be able to state where mass and energy enter and
  leave. Before trusting a result, mentally (or numerically) close the balance.
- Respect the **stream/`inStream` semantics** of fluid connectors — enthalpy
  carried by flow is directional. Mishandling reverse or zero flow is a classic
  failure mode; design and test for flow reversal and shutoff, not just the
  nominal forward operating point.

---

## 3. Thermo-fluid pitfalls (read this before you debug)

These cause the majority of wasted hours in steam-cycle modeling. When a
simulation stalls, throws, or returns nonsense, suspect these *first*:

- **Two-phase region near the dome.** Turbine exhaust, condenser, and feedwater
  heaters live near saturation. Property functions (especially IF97 steam) get
  steep and ill-conditioned there; derivatives blow up across the phase
  boundary. Watch for the solver crawling, rejecting thousands of steps, or
  emitting **negative-pressure / out-of-range property warnings** — these are the
  signature, and they mean a state has wandered outside the valid region, not
  that the physics is wrong.
- **Pressure as a state in near-incompressible liquid.** Pump and feedwater
  lines can produce extremely stiff pressure dynamics. Decide deliberately
  whether a volume is a dynamic state or a steady-state algebraic relation.
- **Initialization is half the work.** Most "it won't simulate" problems are
  bad initial conditions, not bad equations. Give physically consistent
  `start` values across the whole flow path (a pressure profile that actually
  descends through the turbine, enthalpies on the right side of saturation).
  Prefer **steady-state initialization** for plant models and verify the system
  is genuinely at rest at t=0 before adding transients.
- **Index / initialization over-determination.** Closed loops with set pressures
  and incompressible media easily become over- or under-determined. Read the
  translation log; do not ignore "system is structurally singular" or large
  nonlinear-block warnings.
- **Algebraic loops and chattering events.** Check valves, relief valves, and
  flow-dependent regime switches create events. Smooth discontinuities
  (`noEvent`, `smooth`, regularized functions) where physically defensible, and
  record where you did so — an over-eager `noEvent` can hide a real event.
- **Control saturation and integrator windup.** When you add controllers, model
  actuator limits and anti-windup. A PI controller without limits will produce
  beautiful, physically impossible setpoint tracking.

When you hit a stuck or thrashing simulation, the **`dymola-sim-debug`** skill
encodes a disciplined loop for exactly these symptoms (rejected steps, IF97
warnings, state-event stalls) — use it rather than guessing.

---

## 4. Verification discipline

We have no `assert`-based unit suite; **test models are our tests**. Treat them
with the same rigor a software team gives its test pyramid.

- **Every nontrivial component ships with at least one test model** that
  instantiates it, drives it with sources/sinks/ramps, and simulates over a
  defined interval. A component without a test model is unverified and should be
  treated as not done.
- **Name and place test models predictably** (e.g. an `Examples` or `Tests`
  sub-package mirroring the component structure) so the next session can find
  the verification for any class in seconds.
- **A test model must specify its own success criteria.** In the model's
  documentation or comments, state: the scenario, the expected steady-state
  values, the conservation checks, and what a *pass* looks like. "It ran" is not
  a pass. Where practical, embed `assert` statements on the invariants that must
  hold (mass balance closes, temperature stays physical, pressure positive) so a
  violation stops the run loudly instead of producing quiet garbage.
- **Verify physics, not just execution.** For each test, confirm:
  1. **Conservation** — mass in = mass out (± storage); energy balance closes.
  2. **Bounds** — pressures positive, temperatures within medium validity,
     qualities in [0,1] unless intentionally subcooled/superheated.
  3. **Steady state** — if it should settle, derivatives actually go to zero.
  4. **Sign and magnitude sanity** — pump adds head, turbine extracts work,
     condenser rejects heat, feedwater heater raises feedwater temperature.
     Order-of-magnitude check every key result against hand calculation.
- **Read the simulation log every time.** Translation and simulation warnings
  are data. A run that "succeeds" with a wall of property-range or
  step-rejection warnings is a yellow flag to investigate, not a pass.
- **Watch the solver, not just the answer.** Record which integrator and
  tolerance produced the result. If a model only converges with an exotic solver
  or a loosened tolerance, that is a fragility to document and ideally fix, not a
  victory.
- **Guard against regression.** Before extending a working model, re-run the
  existing test models and confirm they still pass. When a session breaks a
  previously-passing test, that is the priority — fix it before adding new scope.
  Note known-good results (key values, run settings) so drift is detectable.

---

## 5. Working rhythm for a session

1. **Orient.** Read this file, the decision log (§7), and the test-model status.
   Identify what currently simulates cleanly and what does not.
2. **Plan a slice.** Pick the smallest extension that produces a
   simulate-and-verify milestone. State the intended success criterion before
   writing equations.
3. **Build incrementally.** Translate and simulate often. Get a skeleton that
   runs with trivial physics, then add fidelity, re-simulating at each step.
4. **Verify.** Run the new test model and re-run affected existing ones. Apply
   the §4 checks. Read the log.
5. **Record.** Update documentation and the decision log. Note anything left
   provisional, any TODO, and the exact solver/tolerance used.
6. **Leave it clean.** No half-applied changes that don't translate. If you must
   stop mid-slice, leave a clear note of where things stand and what breaks.

Do not begin a large architectural change without surfacing the plan first. For
anything beyond a localized edit, sketch the approach and the trade-offs before
committing to it — the `brainstorming` and `writing-plans` skills exist for this.

---

## 6. Documentation habits

- **Every public class carries an HTML `Documentation` annotation** stating: its
  physical purpose, key assumptions and their validity range, the meaning of its
  parameters and ports, and a pointer to its test model. Assumptions are
  load-bearing — an unstated "incompressible, no heat loss, ideal mixing" is how
  the next session misuses your component.
- **Document the operating envelope.** State the pressure/temperature/flow range
  the component was verified over. Outside that range, behavior is unverified —
  say so.
- Keep a top-level **README / library overview** describing what subsystems
  exist, which test models demonstrate them, and the current maturity of each
  (prototype / verified / fragile). Update it as the library grows.
- Comments explain **why**, not what. The equations say what. Use comments for
  the modeling choice, the correlation source (cite it), and the reason a term
  exists.

---

## 7. Decision recording (ADR)

Across sessions, the *reasoning* behind a model is as valuable as the model.
Maintain lightweight **Architecture/Modeling Decision Records** in
`docs/adr/` (one short markdown file per decision, dated, numbered).

Record a decision whenever you:
- choose a medium model, formulation, or correlation over alternatives;
- decide a volume is dynamic vs. steady-state, or lumped vs. distributed;
- regularize a discontinuity, fix an initialization strategy, or pin a solver;
- accept a known simplification or limitation.

Each ADR states: the context, the decision, the alternatives considered, and the
consequences (including what it makes harder). When a later session reverses a
decision, supersede the ADR — don't delete it. The point is that nobody re-opens
a settled question without seeing why it was settled, and nobody inherits a
mysterious workaround without its rationale.

---

## 8. Collaboration rules

- **Faithful reporting.** If a model doesn't converge, say so and show the log.
  If a result is suspicious, flag it. Never present a tuned-to-look-right or
  cherry-picked run as verified. "Works on my solver settings" is a caveat that
  must travel with the claim.
- **No silent scope changes.** If achieving the goal requires changing an
  interface, a parameter default, or a previously-verified component, surface it
  before doing it — downstream test models may depend on the old behavior.
- **Confirm before destructive or hard-to-reverse moves** — deleting a working
  test model, renaming a public class, restructuring packages. These ripple
  across the library and across sessions.
- **Match the surrounding style.** New code should be indistinguishable from the
  existing library in naming, structure, unit usage, and documentation density.
- **Leave breadcrumbs for the next session.** A short note of "what works, what's
  provisional, what's next" at the end of a session is worth more than another
  half-finished feature.

---

## 9. The definition of done

A change is done when **all** of these hold:

1. It translates and simulates cleanly in OpenModelica.
2. Its test model(s) run over the defined interval and meet stated success
   criteria, with the §4 physical checks passing.
3. Existing test models still pass (no regression).
4. The simulation log is clean, or every remaining warning is understood and
   documented.
5. Public classes, parameters, assumptions, and operating envelope are
   documented; the test model is discoverable from the component.
6. Any nontrivial modeling choice is captured in an ADR.
7. Solver and tolerance used are recorded, and the result is reproducible.

Anything short of this is in progress, and must be labeled as such.
