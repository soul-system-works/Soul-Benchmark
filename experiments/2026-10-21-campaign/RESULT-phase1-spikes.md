# Phase 1 — spikes (2026-10-21, partial)

| Route | Result | Evidence |
|---|---|---|
| Claude Code → Ollama (`ANTHROPIC_BASE_URL=http://localhost:11434`, `qwen3.8:27b`, 32k ctx, RTX 4090) | **Works.** Write + Bash tool calls, 3 turns, 83 s, $0 | `hello.py` = `print(2 + 3)`; run by the harness → `5`. Stderr: `unrecognized_model` notice only |
| Codex → Ollama (`codex exec --oss --local-provider ollama -m qwen3.8:27b`, codex-cli 0.163.0) | **Not viable as tried.** exit 1 in 22 s; no file written | `error=unsupported call: shell`; "Model metadata for `qwen3.8:27b` not found" |
| Codex → OpenAI (`gpt-6.1-sol`, ChatGPT login per the Body, `--ignore-user-config`, AGENTS.md form, chain R inc01) | **Works.** G: 210 s, sentinel present, src/ package + 5 own tests; S: 136 s, sentinel present, own tests 5 passed under the harness | per-turn token usage in the JSONL (no $ figure under a ChatGPT login). Soul under Codex here = contract in AGENTS.md only — the Codex hook opt-in was not enabled |

Ollama models on disk all declare `tools`: muse-glimmer:30b, qwen3.8:27b,
qwen2.5-14b-32k. Only qwen3.8:27b tested. Not yet: chain R inc01 on a local model.

Harness fix found by this spike: the harness's own pytest run must put `src/` on the
path (`PYTHONPATH=src:.`) — G's src-layout tests errored on `import rom_study` under the
harness while passing for the model. Recomputable from the per-increment snapshots.
