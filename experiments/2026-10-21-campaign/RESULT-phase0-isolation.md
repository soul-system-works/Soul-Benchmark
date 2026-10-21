# Phase 0 — isolation check (2026-10-21)

**Verdict: PASS, with two fixes the harness now carries.** Subscription auth (no `--bare`).

Instrument: the CLI's own `stream-json` init event (plugins, MCP servers, memory paths)
and hook events, read per arm — not the model's word. Leak probe for the global
`~/.claude/CLAUDE.md`: ask for a script path that exists only there (not guessable).

| Finding | Evidence |
|---|---|
| `--setting-sources project` keeps user-enabled plugins and user skills out; only the arm's `--plugin-dir` plugins (plus Claude Code built-ins, identical in every arm) load | init `plugins`, `skills`, 7/7 arms |
| `--strict-mcp-config` → 0 MCP servers | init `mcp_servers`, 7/7 |
| **Leak 1:** the global `~/.claude/CLAUDE.md` still loads under `--setting-sources project` | control runs F and S without the fix quoted the global-only path |
| Fix 1: `--settings '{"claudeMdExcludes":["/home/fig/.claude/CLAUDE.md"]}'` | 7/7 arms answer NONE; both controls detect the leak without it |
| **Leak 2 (carry channel):** auto-memory is on per arm directory — notes could carry between chain sessions outside any doctrine | init `memory_paths.auto` present |
| Fix 2: `"autoMemoryEnabled": false` in the same `--settings` JSON | `memory_paths` absent |
| SessionStart hooks fire only in arms carrying soul-system or superpowers | `hook_response` events: S, SP, GS, SS |

Not yet observed: Soul's Stop gate firing inside an arm — the pilot's first edit-and-claim
turn checks it. Cost: ~$0.33 notional, 10 Sonnet runs + 2 Haiku runs.
