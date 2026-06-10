# Increment 3 — Score HUD and the rendering boundary

Add scoring: survival time accrues points, near-misses give bonus points. Show the
score and lives on screen.

Second standing decision, also incident-backed: **the canvas renders the game world
ONLY; all UI — score, lives, menus, overlays — is HTML/SVG in the DOM, layered over the
canvas. Never draw UI into the game canvas.** On the last game the HUD was drawn in
canvas; on high-DPI Android the text scaled unreadably, screen readers saw nothing, and
every UI tweak meant touching the render loop — reworking it out cost weeks. The world
is canvas; the interface is the document. Format/layout/accessibility live on the DOM
side, where the platform does the work.
