# Phase 1 — spikes (2026-10-21, partial)

| Route | Result | Evidence |
|---|---|---|
| Claude Code → Ollama (`ANTHROPIC_BASE_URL=http://localhost:11434`, `qwen3.8:27b`, 32k ctx, RTX 4090) | **Works.** Write + Bash tool calls, 3 turns, 83 s, $0 | `hello.py` = `print(2 + 3)`; run by the harness → `5`. Stderr: `unrecognized_model` notice only |
| Codex → Ollama (`codex exec --oss --local-provider ollama -m qwen3.8:27b`, codex-cli 0.163.0) | **Not viable as tried.** exit 1 in 22 s; no file written | `error=unsupported call: shell`; "Model metadata for `qwen3.8:27b` not found" |
| Codex → OpenAI | **Not run.** Codex is logged in with a ChatGPT account, not an API key; the Body budgeted it as API ($25) — billing route to confirm first | `codex login status` |

Ollama models on disk all declare `tools`: muse-glimmer:30b, qwen3.8:27b,
qwen2.5-14b-32k. Only qwen3.8:27b tested. Not yet: chain R inc01 on a local model.
