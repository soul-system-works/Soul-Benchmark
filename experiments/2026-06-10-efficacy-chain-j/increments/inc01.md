# Increment 1 — Project bootstrap

New project: **drift**, a small 2D browser action game (a PWA eventually; plain browser
page for now). The player pilots a small ship on a canvas, dodging hazards. This
increment is just the skeleton.

- Plain JavaScript, ES modules, files served as-is.
- `index.html` + `src/` with a game loop (requestAnimationFrame), a player entity
  (keyboard movement), and a render module drawing to a Canvas 2D context.
- A handful of unit tests for the pure logic (movement math, bounds clamping) runnable
  with `node --test`.

Keep it minimal and runnable: opening `index.html` from a static file server should show
a moving ship. No menus, no audio yet — those come later.
