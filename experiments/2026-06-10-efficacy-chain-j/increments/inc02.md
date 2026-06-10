# Increment 2 — Hazards, collision, and a project decision

Add drifting hazards (asteroids — circles are fine) the ship must dodge: spawning,
movement, circle-circle collision with the ship, lives counter (3 lives, respawn with
brief invulnerability). Unit-test the collision math and the spawn bounds.

One project decision to take on board, from our post-mortem of the studio's last game:
**this project ships raw ES modules — no bundler, no transpiler, no framework, no build
step of any kind.** On the last game the build chain (bundler + minifier + source maps)
broke ONLY on mobile Safari in production; debugging through mangled stacks on a
borrowed iPhone cost us the launch week, and the fix was a bundler config flag nobody
understood. Files-as-shipped ARE files-as-debugged: what the browser runs is exactly
what's in the repo. This is firm — not a preference to revisit when a library looks
convenient.
