# Workflow value — test kit

The experiment asks whether `/soul-workflow build-verify` (Soul System v3.7.2) is worth
using, judged on quality, speed and usage: the same game task, run three ways, by the
owner. `PLAN.md` is the plan and `SPEC.md` the task, both approved by the owner on
2026-10-28; everything else here is the kit that runs and judges it.

## Files

| File | What it is |
|---|---|
| `SPEC.md` | The task, word for word as every arm gets it: the game Orbit Courier, 12 must-haves, the test hooks (`window.game`). |
| `PLAN.md` | The question, the three arms, the measures, the order. |
| `check.mjs` | The task's "Done when". Each arm gets a copy and runs `node check.mjs` from its own folder. Opens `index.html` in headless Chromium and checks the hooks, start, thrust, rotate keys, pause and resume, no console error, no request other than `file:`/`data:`. A minimum on purpose. |
| `playtest.mjs` | The **hidden** playtest — never copied into an arm folder. `node playtest.mjs <game-folder> [--out report.json]`. Runs the same check (it imports `check.mjs`), then drives what a script can reach: the W/A/D keys, a life lost with no input, game over at 0 lives and restart, best score across a reload, the hooks well-typed at every sample. Prints a JSON report keyed by must-have number: `pass`, `fail` or `unverified (needs a human)`, each with a note. Takes up to about 6 minutes on a game that never ends (90 s waiting for a life loss, then up to 240 s driving toward game over). |
| `controls/blank/` | Known-bad control: an empty page. |
| `controls/stub/` | Known-good-for-the-check control: a minimal state machine with the hooks and keys right and no gameplay at all. |
| `confined-check.py` | Runs a game folder's `check.mjs` under bubblewrap through the Soul System's `tools/confine.py` — the way `/soul-workflow` runs a worker's check. |
| `make-arms.sh` | Creates `/mnt/d/Projects/soul/wf-value-arms/{A,B,C}` (each a fresh git repo with `SPEC.md`, `check.mjs`, `.gitignore`; B and C also a minimal Soul project) and `MANIFEST.txt` with the sha256 of each arm's `check.mjs` and `SPEC.md`. Refuses if any arm exists. `WFV_ARMS_BASE` moves it elsewhere. |
| `measure.py` | Usage and time per arm, read from Claude Code's session logs afterwards: tokens per model (each message once, by id), main session vs subagents and workers, wall time, human prompts; plus Codex tokens and Ollama wall minutes from `.ai/workflow-runs/`. `python3 measure.py A B C [--json [FILE]]`. Classifies by each record's recorded `cwd`, never by the log folder's name. |
| `tests/test_measure.py` | Tests for `measure.py` on synthetic transcripts: `python3 tests/test_measure.py`. |
| `SCORING-SHEET.md` | For the two blind scorers: how the games are blinded, the 12-row table, playability 1–5. |
| `RUN-SHEET.md` | One page for the owner: setup, the launch line and first prompt per arm, the stop rule, what to run afterwards. |
| `package.json`, `package-lock.json` | Playwright, installed here only; `node_modules/` is not committed. |

## Versions (as installed 2026-10-28)

- Node v22.23.4, npm 10.9.9
- `playwright` 1.64.1 (exact pin); Chromium 156.0.8078.4 (Playwright build 1248), from
  `npx playwright install chromium`, kept in `~/.cache/ms-playwright/`
- bubblewrap 0.11.1; Python 3.14.4

To set up on a fresh machine: `npm install && npx playwright install chromium` here.
`check.mjs` loads Playwright from this folder by absolute path, so the arm folders need
no install — and the kit must stay at this path.

## How the controls proved the checker (2026-10-28)

`check.mjs`, run from each control folder:

- `controls/blank`: **FAIL**, exit 1 — `window.game is missing`; the six checks after it
  are reported "not run"; 3/10 passed (page loads, no console error, no request).
- `controls/stub`: **PASS**, exit 0 — 10/10.
- `controls/stub` inside the bubblewrap jail (`python3 confined-check.py <copy of stub>`,
  which uses `confine_argv`: filesystem read-only except the game folder, no network,
  secret folders hidden): **PASS**, exit 0 — 10/10, both from a folder under `/tmp` and
  from `controls/stub` itself on the `/mnt/d` drive. The blank control fails there too.

Planted faults (throwaway copies of the stub, not kept): a `console.error` call, a
`fetch` of an `https:` URL, and an `<img>` from `http:` each made `check.mjs` FAIL with
the cause named.

`playtest.mjs` on the controls:

- `controls/blank`: must-haves 1, 2, 7, 8, 10, 11 **fail** (no `window.game`); 3, 4, 5,
  6, 9 unverified; 12 pass (no requests).
- `controls/stub` (full waits, 334 s): 1 pass (title and prompt are in the page text),
  12 pass, every gameplay item **unverified** — no life lost in 90 s, game over not
  reached in 240 s, best score 0 so the reload proved nothing. So a game that only
  satisfies the check is not mistaken for a game.

Two more throwaway variants exercised the playtest's other paths: one that loses a life
every 2 s reached game over and got pass on 3, 10 and 11; one whose lives went past 0
while still "playing" got **fail** on 10.
