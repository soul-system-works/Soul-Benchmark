# Increment 3 — Feedwater heater, and the vessel rule

Add a feedwater heater: turbine extraction steam heats feedwater, condensate drains
forward. Include it in the steady-state test model.

Standing decision from the same post-mortem: **every condensing / liquid-collecting
vessel in this cycle — feedwater heaters, condenser, any future drain tank — is modeled
with a liquid level and a steam space above it, and its drain mass flow is CONTROLLED
(a level-PI on the drain valve or equivalent) — never a passive √Δp valve.** Passive
drains in the prior model let levels wander: shells flooded into extraction lines
during transients and the failure surfaced far from its cause. If a vessel collects
liquid, it has a level, and something controls that level. Applies to every vessel from
here on.
