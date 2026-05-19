---
name: anyrouter
description: Wire AnyRouter into a project, migrate from Anthropic / OpenAI / OpenRouter, and call its MCP server. Use when the user mentions AnyRouter, asks to add a unified LLM gateway, wants to swap providers without code churn, migrates an existing OpenAI/Anthropic/OpenRouter integration, sets up Claude Code / Codex / Cursor against a custom base URL, or needs help with model ids like `provider/model`, app attribution headers (`X-AnyRouter-*`), provider preferences, streaming, BYOK, or the AnyRouter MCP server at `https://anyrouter.dev/api/v1/mcp`.
---

# AnyRouter

AnyRouter is a universal, OpenAI-compatible LLM gateway. One base URL, one API key, 150+ models across 28+ providers, deterministic failover, and a remote MCP server for key + credit management. Use this skill whenever you need to wire AnyRouter into a project or migrate an existing integration.

## The contract

| Setting | Value |
| --- | --- |
| Base URL | `https://anyrouter.dev/api/v1` |
| API key env var | `ANYROUTER_API_KEY` (keys are prefixed `sk-ar-`) |
| Model id format | `provider/model` (e.g. `openai/gpt-5.4-mini`, `anthropic/claude-sonnet-4.6`) |
| Chat endpoint | `POST /chat/completions` (OpenAI-compatible) |
| Anthropic-native endpoint | `POST /messages` (for `anthropic/*` models) |
| Modern agent endpoint | `POST /responses` (typed output items + tools) |
| MCP endpoint | `https://anyrouter.dev/api/v1/mcp` (configured by this plugin) |
| Dashboard | https://anyrouter.dev/dashboard |
| Docs | https://anyrouter.dev/docs |

Default model when unspecified: `openai/gpt-5.4-mini`. Cheap+fast: `openai/gpt-5.4-nano`, `anthropic/claude-haiku-4.5`. High-quality: `anthropic/claude-sonnet-4.6`, `openai/gpt-5.4`.

## When to use this skill

- The user mentions **AnyRouter** by name.
- They want to **add a unified LLM gateway** so they can swap providers without rewriting client code.
- They have an existing **OpenAI**, **Anthropic**, or **OpenRouter** integration and want to migrate to AnyRouter.
- They want to point **Claude Code**, **Codex**, **Cursor**, **Aider**, **Hermes**, or another agent at AnyRouter.
- They need **app attribution**, **provider preferences**, **price caps**, **failover**, or **routing controls**.
- They want to use the **AnyRouter MCP server** from a client.

Before integrating, check if the project already has an LLM client. If so, change the **base URL, key, and model id** rather than introducing a new client.

## Adding AnyRouter to a project (fresh)

### TypeScript (`openai` SDK)

```bash
npm install openai
```

```typescript
import OpenAI from "openai"

export const llm = new OpenAI({
  baseURL: "https://anyrouter.dev/api/v1",
  apiKey: process.env.ANYROUTER_API_KEY,
})

export const MODEL = process.env.ANYROUTER_MODEL ?? "openai/gpt-5.4-mini"

export async function generate(prompt: string) {
  const r = await llm.chat.completions.create({
    model: MODEL,
    messages: [{ role: "user", content: prompt }],
  })
  return r.choices[0]?.message.content ?? ""
}
```

### Python

```bash
pip install openai
```

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url="https://anyrouter.dev/api/v1",
    api_key=os.environ["ANYROUTER_API_KEY"],
)

resp = client.chat.completions.create(
    model=os.getenv("ANYROUTER_MODEL", "openai/gpt-5.4-mini"),
    messages=[{"role": "user", "content": "Reply with: anyrouter-ok"}],
)
print(resp.choices[0].message.content)
```

### Smoke test

```bash
curl https://anyrouter.dev/api/v1/chat/completions \
  -H "Authorization: Bearer $ANYROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"openai/gpt-5.4-mini","messages":[{"role":"user","content":"Reply with: anyrouter-ok"}],"max_tokens":20}'
```

Integration is **done** when:

- Calls hit `https://anyrouter.dev/api/v1`
- The key is read from `ANYROUTER_API_KEY` (no inline literal in source)
- Model ids use the `provider/model` form
- Streaming still streams if it did before
- Errors flow through the project's existing error path

## Integrating with coding agents

### Claude Code

Two env vars:

```bash
export ANTHROPIC_BASE_URL="https://anyrouter.dev/api"
export ANTHROPIC_AUTH_TOKEN="sk-ar-your-key"
```

For a side-by-side wrapper (`claude-ar` vs bare `claude`), see [`references/guides_claude-code.md`](../../references/guides_claude-code.md). Pin tier names with `ANTHROPIC_DEFAULT_HAIKU_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_OPUS_MODEL`.

### Codex / Cursor / Aider / Hermes / OpenClaw

Any client that accepts a custom OpenAI base URL works. Set:

- Base URL: `https://anyrouter.dev/api/v1`
- API key: `sk-ar-…` from the dashboard
- Model: `provider/model` from the catalog

For Hermes specifics see [`references/guides_hermes-agent.md`](../../references/guides_hermes-agent.md). For OpenClaw see [`references/guides_openclaw.md`](../../references/guides_openclaw.md). For a generic prompt to paste into any coding agent, see [`references/guides_ai-agent-integration.md`](../../references/guides_ai-agent-integration.md).

## Migration recipes

The three migrations all boil down to **swap base URL, swap key, keep request shape**.

### From OpenAI

```diff
- baseURL: "https://api.openai.com/v1"
- apiKey: process.env.OPENAI_API_KEY
+ baseURL: "https://anyrouter.dev/api/v1"
+ apiKey: process.env.ANYROUTER_API_KEY
- model: "gpt-4o-mini"
+ model: "openai/gpt-5.4-mini"
```

Full notes: [`references/guides_migrate-from-openai.md`](../../references/guides_migrate-from-openai.md).

### From Anthropic

Two options:

1. **Stay native** — keep the Anthropic SDK, point `ANTHROPIC_BASE_URL` at `https://anyrouter.dev/api` and use `/messages` with `anthropic/*` model ids.
2. **Unify on Chat Completions** — move to the `openai` SDK with `model: "anthropic/claude-sonnet-4.6"`. One client, every provider.

Full notes: [`references/guides_migrate-from-anthropic.md`](../../references/guides_migrate-from-anthropic.md).

### From OpenRouter

`provider/model` ids and the request-level `provider` object are compatible. Most projects only change the base URL and key:

```typescript
const client = new OpenAI({
  baseURL: "https://anyrouter.dev/api/v1",    // was: https://openrouter.ai/api/v1
  apiKey: process.env.ANYROUTER_API_KEY,      // was: OPENROUTER_API_KEY
})
```

`provider.only`, `provider.ignore`, `provider.order`, `provider.sort`, `provider.max_price`, and `provider.allow_fallbacks` all map across. Full notes: [`references/guides_migrate-from-openrouter.md`](../../references/guides_migrate-from-openrouter.md).

## Provider preferences and routing

Steer routing from the request body:

```json
{
  "model": "openai/gpt-5.4-mini",
  "provider": {
    "only": ["OpenAI", "Groq"],
    "order": ["Groq", "OpenAI"],
    "sort": "latency",
    "allow_fallbacks": true,
    "max_price": { "prompt": "1.00", "completion": "4.00" },
    "preferred_max_latency": 300,
    "preferred_min_throughput": 40
  }
}
```

Pin a single upstream with `X-AnyRouter-Provider: <provider_id>` — useful for reproducibility, BYOK testing, and outage debugging. Full routing model: [`references/features_routing.md`](../../references/features_routing.md).

## App attribution

Identify your app in the AnyRouter dashboard:

```typescript
new OpenAI({
  baseURL: "https://anyrouter.dev/api/v1",
  apiKey: process.env.ANYROUTER_API_KEY,
  defaultHeaders: {
    "X-AnyRouter-Title": "My App",
    "X-AnyRouter-Source": "web-app",
    "X-AnyRouter-Version": process.env.APP_VERSION ?? "dev",
  },
})
```

Full schema: [`references/features_app-attribution.md`](../../references/features_app-attribution.md).

## Streaming

`stream: true` works exactly like OpenAI:

```typescript
const stream = await llm.chat.completions.create({
  model: MODEL,
  stream: true,
  messages: [{ role: "user", content: "..." }],
})
for await (const chunk of stream) process.stdout.write(chunk.choices[0]?.delta?.content ?? "")
```

Details and cancellation behavior: [`references/guides_streaming.md`](../../references/guides_streaming.md).

## MCP server (bundled)

This plugin registers a remote MCP server at `https://anyrouter.dev/api/v1/mcp`. Tools exposed:

| Tool | Purpose |
| --- | --- |
| `list_models` | Search the catalog by provider, capability, or context window |
| `get_credits` | Workspace balance and lifetime usage |
| `list_keys` | List API keys |
| `create_key` | Mint a new API key |
| `revoke_key` | Disable a key by id |
| `list_presets` | List saved request presets |
| `list_conversations` | Search workspace conversations |

OAuth runs on first tool call — the user picks Read-only / Standard / Full on the consent screen. There is no `chat` tool; use the regular chat endpoint for inference.

Full tool catalog, scopes, and manual-auth path: [`references/api-reference_mcp.md`](../../references/api-reference_mcp.md). Client setup for Claude Desktop / Cursor / Claude Code / OpenCode: [`references/mcp.md`](../../references/mcp.md).

## Defaults that almost always belong in production

- Read the key from env, never inline.
- Use `provider/model` ids; never bare model names except via aliases the docs explicitly list.
- Set the three `X-AnyRouter-*` attribution headers so dashboard analytics work.
- Keep `allow_fallbacks: true` unless you're running an eval that needs a fixed upstream.
- Long agent loops: bump SDK timeout (`API_TIMEOUT_MS=3000000` for Claude Code).
- Respect `X-RateLimit-Remaining` and `X-Upstream-RateLimit-Remaining` headers.

## Reference index

| Topic | Reference file |
| --- | --- |
| Quickstart | `references/getting-started_quickstart.md` |
| Dashboard tour | `references/guides_dashboard-tour.md` |
| Claude Code | `references/guides_claude-code.md` |
| Hermes Agent | `references/guides_hermes-agent.md` |
| OpenClaw | `references/guides_openclaw.md` |
| AI agent integration (paste-prompt) | `references/guides_ai-agent-integration.md` |
| Streaming | `references/guides_streaming.md` |
| Migrate from OpenAI | `references/guides_migrate-from-openai.md` |
| Migrate from Anthropic | `references/guides_migrate-from-anthropic.md` |
| Migrate from OpenRouter | `references/guides_migrate-from-openrouter.md` |
| App attribution | `references/features_app-attribution.md` |
| Smart routing | `references/features_routing.md` |
| MCP server (consumer guide) | `references/mcp.md` |
| MCP API reference | `references/api-reference_mcp.md` |

Always check the live docs at https://anyrouter.dev/docs for changes; these references are a frozen snapshot kept inside the plugin for offline reasoning.
