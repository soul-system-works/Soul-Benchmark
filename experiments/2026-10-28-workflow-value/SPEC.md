# Orbit Courier — the task every arm receives (word for word)

Build a small browser game, **Orbit Courier**, in this folder.

You fly a courier ship around a planet. The planet's gravity pulls you in. Pick up
packages that drift in orbit and deliver them to the station; avoid debris.

## Must have

1. **Start screen** with the title and "Press Enter to start".
2. **Controls:** Left/Right (or A/D) rotate the ship; Up (or W) thrusts. P pauses and
   resumes. Enter starts from the start screen and restarts from game over.
3. **Gravity:** the ship and packages are pulled toward the planet, stronger when
   closer (inverse-square is fine). Touching the planet costs a life.
4. **Packages:** at most 3 at a time, appearing in orbit. Flying into one picks it up
   (the ship carries at most 1).
5. **Station:** a fixed, visibly different object. Reaching it while carrying a package
   delivers it: +100 points.
6. **Debris:** pieces in orbit; hitting one costs a life. More debris, moving faster,
   at each new level.
7. **Lives and levels:** 3 lives. Every 3 deliveries the level goes up by 1.
8. **Fuel:** thrusting uses fuel; each delivery refills it; with no fuel the ship
   cannot thrust.
9. **HUD:** score, lives, level and fuel, always visible while playing.
10. **Game over** at 0 lives: final score, best score, "Press Enter to play again".
11. **Best score** kept across page reloads (localStorage).
12. **No downloads at runtime:** everything ships in this folder (no CDNs, no image
    or sound files fetched from the internet). Plain HTML/CSS/JavaScript; the game
    opens from `index.html`.

## Test hooks (required)

The page exposes `window.game` with these read-only fields, updated as the game runs:
`state` (`"start"`, `"playing"`, `"paused"` or `"over"`), `score`, `lives`, `level`,
`fuel` (0–100), `carrying` (true/false), `deliveries`, `best`.

## Done when

`node check.mjs` passes. It opens the game in a headless browser, checks the start
screen and the hooks, starts a game, presses the controls, pauses and resumes, and
checks that nothing errors in the console. (The check is a minimum. The game is judged
on the whole list above and on how it plays.)
