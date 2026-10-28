# Scoring sheet — Orbit Courier (two blind scorers)

You are scoring three browser games built from the same task, `SPEC.md` (in this
folder; read it first). Score each game on its own; you will not be told how it was made.

**Do not look at** the arm folders, their git history, any session log, `measure.py`
output, the playtest reports, or each other's scores until both sheets are handed in.
Ask the owner, not the files, if anything is unclear.

## How the games are blinded (the owner does this, before handing over)

1. Toss a coin (or roll a die) to put the three arms A, B, C in an order; copy each
   arm's game files — `index.html` and whatever it loads, nothing else — into
   `game-1/`, `game-2/`, `game-3/` in that order.
2. Write the key (`game-1 = ?`, …) on paper or in a private file outside this repo.
   Keep it private until both scorers have handed in their sheets.
3. Hand the scorers the three `game-N` folders, `SPEC.md` and this sheet.

## How to score

Open each game's `index.html` in a desktop browser (double-click it; no server
needed). Play each game long enough to judge every row: at least once to game over
and back, and reload the page once for row 11. Browsers may share saved data between
pages opened from files, so two games that happen to use the same storage name can see
each other's best score: if a game shows a best score before you have played it, note
that rather than counting it against the game.

For each must-have mark **pass** (fully there and working), **partial** (there but
incomplete or buggy), or **fail** (missing or broken), with a short note — what you
saw, not a guess at the cause.

| # | Must-have (SPEC.md) | game-1 | note | game-2 | note | game-3 | note |
|---|---|---|---|---|---|---|---|
| 1 | Start screen: title and "Press Enter to start" | | | | | | |
| 2 | Controls: Left/Right or A/D rotate, Up or W thrust, P pause/resume, Enter start/restart | | | | | | |
| 3 | Gravity toward the planet, stronger when closer; touching the planet costs a life | | | | | | |
| 4 | Packages: at most 3 at a time, in orbit; fly into one to pick it up; carry at most 1 | | | | | | |
| 5 | Station: fixed, visibly different; reaching it while carrying delivers, +100 | | | | | | |
| 6 | Debris in orbit; hitting it costs a life; more and faster debris each level | | | | | | |
| 7 | 3 lives; level +1 every 3 deliveries | | | | | | |
| 8 | Fuel: thrust uses it, a delivery refills it, no thrust at 0 fuel | | | | | | |
| 9 | HUD: score, lives, level and fuel always visible while playing | | | | | | |
| 10 | Game over at 0 lives: final score, best score, "Press Enter to play again" | | | | | | |
| 11 | Best score kept across page reloads | | | | | | |
| 12 | No downloads at runtime; plain HTML/CSS/JS; opens from `index.html` | | | | | | |

**Playability, 1–5** (1 = not a game; 3 = works, but you would not play it twice;
5 = you would happily keep playing). One sentence of why.

| Game | Playability (1–5) | Why (one sentence) |
|---|---|---|
| game-1 | | |
| game-2 | | |
| game-3 | | |

Scorer: ____________  Date: ____________  Browser and version: ____________

Hand the sheet to the owner. The key is revealed only when both sheets are in.
