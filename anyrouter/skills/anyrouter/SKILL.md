---
name: anyrouter
description: Wire AnyRouter, an OpenAI-compatible LLM gateway, into a project, migrate from OpenAI, Anthropic, or OpenRouter, point coding agents at it, and use its MCP server. Use when the user mentions AnyRouter, wants a unified LLM gateway, or needs provider routing, attribution headers, BYOK, or `provider/model` ids.
---

# AnyRouter

One base URL, one API key, many models and providers, with failover and a remote MCP server for keys and credits.

## Fetch live docs first

This skill is a map. Before answering any non-trivial question, fetch the relevant markdown page and cite its URL. Do not rely on remembered model ids, scopes, or header values.

- `https://anyrouter.dev/docs.md` is the index of every page. Start here when unsure.
- Append `.md` to any docs URL for raw markdown, for example `https://anyrouter.dev/docs/guides/migrate-from-openai.md`.
- `https://anyrouter.dev/llms-full.txt` is every doc in one file, and `https://anyrouter.dev/llms.txt` is the short index.
- If a page 404s, it was renamed. Re-read the index.

Useful pages: `getting-started/quickstart`, `getting-started/authentication`, `guides/ai-agent-integration`, `guides/claude-code`, `guides/migrate-from-openai`, `guides/migrate-from-anthropic`, `guides/migrate-from-openrouter`, `guides/provider-routing`, `features/app-attribution`, `features/byok`, `api-reference/overview`, `api-reference/mcp`, and `mcp`.

## Contract

| Setting | Value |
| --- | --- |
| Base URL | `https://anyrouter.dev/api/v1` |
| Anthropic-native base | `https://anyrouter.dev/api` (for `/messages`) |
| API key env var | `ANYROUTER_API_KEY` (keys start with `sk-ar-`) |
| Model id | `provider/model` |
| Endpoints | `/chat/completions` (OpenAI-compatible), `/messages` (Anthropic-native), `/responses` |
| MCP | `https://anyrouter.dev/api/v1/mcp`, registered by this plugin |

For current model ids, call the MCP `list_models` tool or read the models catalog at `https://anyrouter.dev/models`. Never invent an id.

## Add to a project

If the project already has an LLM client, change its base URL, key, and model id instead of adding a client. Read the key from `ANYROUTER_API_KEY`, never inline it, and read the model from `ANYROUTER_MODEL`.

```typescript
import OpenAI from "openai"

export const llm = new OpenAI({
  baseURL: "https://anyrouter.dev/api/v1",
  apiKey: process.env.ANYROUTER_API_KEY,
})
```

```python
import os
from openai import OpenAI

client = OpenAI(base_url="https://anyrouter.dev/api/v1", api_key=os.environ["ANYROUTER_API_KEY"])
```

The integration is done when calls hit the base URL, the key comes from env, model ids use `provider/model`, streaming still streams, and errors flow through the existing error path. Prove it with one short request to `/chat/completions`.

## Coding agents

- Claude Code: set `ANTHROPIC_BASE_URL="https://anyrouter.dev/api"` and `ANTHROPIC_AUTH_TOKEN` to the key. For tier pinning see `guides/claude-code`.
- Codex, Cursor, Aider, Hermes, OpenClaw: any client with a custom OpenAI base URL works. Use the base URL, the key, and a `provider/model` id.

## Migrating

Swap the base URL and key and keep the request shape. For the full procedure, run `/anyrouter:migrate` (`commands/anyrouter-migrate.md`).

- From OpenAI, prefix model ids with `openai/`.
- From Anthropic, either keep the SDK and set `ANTHROPIC_BASE_URL`, or move to `/chat/completions` with `anthropic/<model>` ids.
- From OpenRouter, the request and `provider` object are identical.

## Routing and attribution

Steer routing with a `provider` object in the request body (`only`, `order`, `sort`, `allow_fallbacks`, `max_price`, `preferred_max_latency`, `preferred_min_throughput`). Pin one upstream with the `X-AnyRouter-Provider` header. Send `X-AnyRouter-Title`, `X-AnyRouter-Source`, and `X-AnyRouter-Version` so dashboard analytics work. Keep `allow_fallbacks: true` unless an eval needs a fixed upstream. Schemas are in `guides/provider-routing` and `features/app-attribution`.

## MCP server

The plugin registers the MCP server. It exposes tools for listing models, credits, keys, presets, and conversations, and for creating and revoking keys. OAuth runs on the first tool call and the user picks a scope. There is no chat tool, so use the chat endpoint for inference. Details are in `api-reference/mcp`.

## Production defaults

- Respect the `X-RateLimit-Remaining` and `X-Upstream-RateLimit-Remaining` headers.
- Raise the SDK timeout for long agent loops (`API_TIMEOUT_MS=3000000` for Claude Code).
