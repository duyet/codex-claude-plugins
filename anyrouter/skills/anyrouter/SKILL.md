---
name: anyrouter
description: Wire AnyRouter, an OpenAI-compatible LLM gateway, into a project, migrate from OpenAI, Anthropic, or OpenRouter, point coding agents at it, and use its MCP server. Use when the user mentions AnyRouter, wants a unified LLM gateway, or needs provider routing, attribution headers, BYOK, or `provider/model` ids.
---

# AnyRouter

This skill is a map. Fetch the relevant page and cite its URL before answering non-trivial questions. Never rely on remembered model ids, scopes, or headers.

- Docs index: `https://anyrouter.dev/docs.md`. Append `.md` to any docs URL for markdown. `https://anyrouter.dev/llms-full.txt` is everything in one file.
- Guides live under `guides/` (quickstart, claude-code, migrate-from-openai, migrate-from-anthropic, migrate-from-openrouter, provider-routing) and `features/` (app-attribution, byok).
- Model ids: MCP `list_models` tool or `https://anyrouter.dev/models`. Never invent one.

Contract:

| Setting               | Value                                                         |
| --------------------- | ------------------------------------------------------------- |
| Base URL              | `https://anyrouter.dev/api/v1`                                |
| Anthropic-native base | `https://anyrouter.dev/api` (for `/messages`)                 |
| API key env var       | `ANYROUTER_API_KEY` (keys start with `sk-ar-`)                |
| Model id              | `provider/model`                                              |
| MCP                   | `https://anyrouter.dev/api/v1/mcp`, registered by this plugin |

- In an existing project, change the client's base URL, key, and model id rather than adding a client. Read the key and `ANYROUTER_MODEL` from env, never inline.
- Claude Code: set `ANTHROPIC_BASE_URL="https://anyrouter.dev/api"` and `ANTHROPIC_AUTH_TOKEN` to the key.
- Send `X-AnyRouter-Title`, `X-AnyRouter-Source`, and `X-AnyRouter-Version` so analytics work. Keep `allow_fallbacks: true` unless an eval needs a fixed upstream.
- Done means calls hit the base URL, streaming still streams, and one short `/chat/completions` request succeeds. For migrations run `/anyrouter:migrate`.
- The MCP server has no chat tool. Use the chat endpoint for inference.
