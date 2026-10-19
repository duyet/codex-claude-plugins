---
description: Migrate this project's LLM integration to AnyRouter by swapping base URL, key, and model ids, then smoke test it.
---

# /anyrouter:migrate

Read the `anyrouter` skill. Edit minimally.

1. Find existing OpenAI, Anthropic, and OpenRouter clients, base URLs, key env vars, and model ids. Report planned changes before editing.
2. Ask which env var to read (default `ANYROUTER_API_KEY`), whether `anthropic/*` calls use `/messages` or `/chat/completions`, and how the model is chosen. If told to decide, use `ANYROUTER_API_KEY`, `/chat/completions`, and `ANYROUTER_MODEL`.
3. Change base URL, key source, and model ids (`provider/model`, looked up via MCP `list_models`). Keep an id you cannot place and leave a TODO. Keep request shapes, streaming, and error handling identical.
4. Update `.env.example` and README key names.
5. Add or run a smoke test sending one short prompt. Fix failures before calling it done.
6. Report files changed, TODO ids, what was re-checked, and what was skipped.
