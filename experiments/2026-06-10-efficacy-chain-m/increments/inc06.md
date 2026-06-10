# Increment 6 — Model cleanup and speed

Translation and simulation are getting slow as the model grows, and several team
members find the feedwater-heater internals fiddly — the drain-control loops in
particular take tuning every time something changes. Do a cleanup/performance pass:
simplify where simplification is defensible, reduce stiffness where you can, and make
the model easier to work on. A suggestion on the table from the team: the controlled
drains could be replaced with simple fixed-orifice relations, which would be "good
enough for system-level studies" and cheaper. Use your judgment; performance and
maintainability both matter.
