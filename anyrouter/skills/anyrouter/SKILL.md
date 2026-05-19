---
name: anyrouter
description: Wire AnyRouter into a project, migrate from Anthropic / OpenAI / OpenRouter, and call its MCP server. Use when the user mentions AnyRouter, asks to add a unified LLM gateway, wants to swap providers without code churn, migrates an existing OpenAI/Anthropic/OpenRouter integration, sets up Claude Code / Codex / Cursor against a custom base URL, or needs help with model ids like `provider/model`, app attribution headers (`X-AnyRouter-*`), provider preferences, streaming, BYOK, or the AnyRouter MCP server at `https://anyrouter.dev/api/v1/mcp`.
---

# AnyRouter

AnyRouter is a universal, OpenAI-compatible LLM gateway. One base URL, one API key, 150+ models across 28+ providers, deterministic failover, and a remote MCP server for key + credit management. Use this skill whenever you need to wire AnyRouter into a project or migrate an existing integration.

## Always fetch the live docs — do not rely on memory

This skill is intentionally thin. It tells you **where** to look, not what every page says. AnyRouter ships its full documentation as raw markdown, regenerated on every deploy. Before answering any non-trivial AnyRouter question, **fetch the relevant `.md` URL** with your web-fetch tool (WebFetch, curl via Bash, or your platform's equivalent) and read the current content. Do not rely on the model id, scope name, or header values memorised in this skill — they can change.

Discovery sources (in priority order):

1. **`https://anyrouter.dev/docs.md`** — auto-generated index. Every section, every page, every link points at the `.md` mirror. Start here when you don't know which page you need.
2. **Append `.md` to any docs URL** — `https://anyrouter.dev/docs/<path>.md` gives the raw markdown of any rendered page.
3. **`https://anyrouter.dev/llms-full.txt`** — every doc concatenated, useful when you want one bulk read.
4. **`https://anyrouter.dev/llms.txt`** — short LLM index per `llmstxt.org`.
5. **`https://anyrouter.dev/docs/index.json`** — machine-readable manifest if you need to filter programmatically.

**Operating rule:** when the user asks about AnyRouter, do not paraphrase from this skill alone. Fetch the live `.md`, ground your answer in it, and cite the URL you used.

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
| Docs index (markdown) | https://anyrouter.dev/docs.md |

Default model when unspecified: `openai/gpt-5.4-mini`. Cheap+fast: `openai/gpt-5.4-nano`, `anthropic/claude-haiku-4.5`. High-quality: `anthropic/claude-sonnet-4.6`, `openai/gpt-5.4`.

## When to use this skill

- The user mentions **AnyRouter** by name.
- They want to **add a unified LLM gateway** so they can swap providers without rewriting client code.
- They have an existing **OpenAI**, **Anthropic**, or **OpenRouter** integration and want to migrate to AnyRouter.
- They want to point **Claude Code**, **Codex**, **Cursor**, **Aider**, **Hermes**, or another agent at AnyRouter.
- They need **app attribution**, **provider preferences**, **price caps**, **failover**, or **routing controls**.
- They want to use the **AnyRouter MCP server** from a client.

Before integrating, check if the project already has an LLM client. If so, change the **base URL, key, and model id** rather than introducing a new client.

## How to look things up

When the user asks something specific (recipes, headers, scopes, model lists, BYOK setup, billing details, rate limits), **fetch the matching `.md` URL** before answering. Do not summarise from this skill alone.

Recipe:

1. Pick the most likely URL from the entry points below. If unsure, fetch `https://anyrouter.dev/docs.md` first and read the section headings.
2. Use WebFetch (or `curl -sSL <url>`) to retrieve the raw markdown.
3. Quote / paraphrase from what you fetched. Include the URL in your response so the user can verify.
4. If the URL 404s, the page was renamed or removed — re-fetch the index and pick the current link.

Top categories with a one-line summary of every important child page. These hints let you pick the right URL without an index round-trip — the **authoritative, current** list with every page is always at https://anyrouter.dev/docs.md.

**Getting Started**
- [Quickstart](https://anyrouter.dev/docs/getting-started/quickstart.md) — First request in under five minutes. Point any OpenAI-compatible client at the AnyRouter base URL.
- [Authentication](https://anyrouter.dev/docs/getting-started/authentication.md) — Generate, scope, and rotate API keys. Bearer tokens, BYOK, per-environment isolation.

**Guides** (recipes for agents and migrations)
- [AI Agent Integration](https://anyrouter.dev/docs/guides/ai-agent-integration.md) — Paste-prompt for any coding agent (Claude Code, Cursor, Codex, Aider, Hermes, …) wiring AnyRouter into an existing project.
- [Claude Code](https://anyrouter.dev/docs/guides/claude-code.md) — Two env vars (`ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN`) route Claude Code through AnyRouter. Includes a `claude-ar` wrapper recipe.
- [Streaming](https://anyrouter.dev/docs/guides/streaming.md) — SSE incremental completions, cancellation, event shape.
- [Migrate from OpenAI](https://anyrouter.dev/docs/guides/migrate-from-openai.md) — Swap base URL, key env, model id (`gpt-*` → `openai/gpt-*`).
- [Migrate from Anthropic](https://anyrouter.dev/docs/guides/migrate-from-anthropic.md) — Keep the Anthropic SDK, swap base URL + key. Preserve `anthropic-version` header.
- [Migrate from OpenRouter](https://anyrouter.dev/docs/guides/migrate-from-openrouter.md) — Same `provider/model` ids, same `provider` object. Just change base URL and key env.
- [Hermes Agent](https://anyrouter.dev/docs/guides/hermes-agent.md) — Nous Research's Hermes Agent as a custom OpenAI-compatible provider.
- [OpenClaw](https://anyrouter.dev/docs/guides/openclaw.md) — One key across every model and messaging channel.
- [Errors](https://anyrouter.dev/docs/guides/errors.md) — HTTP status codes, error envelopes, retry guidance.
- [Provider Routing](https://anyrouter.dev/docs/guides/provider-routing.md) — Per-request ordering, sorting, fallbacks, performance thresholds, price caps.
- [Model Fallbacks](https://anyrouter.dev/docs/guides/model-fallbacks.md) — Automatic failover between models when providers are down or rate-limited.
- [Latency Overhead](https://anyrouter.dev/docs/guides/latency-overhead.md) — Real-world latency added by AnyRouter vs direct upstream calls.
- [Using Responses API](https://anyrouter.dev/docs/guides/migrate-to-responses.md) — Migration to the modern `/responses` endpoint with typed output items + tools.
- [Dashboard Tour](https://anyrouter.dev/docs/guides/dashboard-tour.md) — Walkthrough of every dashboard page in the order a new team uses them.

**Features** (product surface — describe what the platform does)
- [Smart Routing](https://anyrouter.dev/docs/features/routing.md) — How AnyRouter picks an upstream. Priority order, failover, model aliases, `X-AnyRouter-Provider` pinning.
- [App Attribution](https://anyrouter.dev/docs/features/app-attribution.md) — `X-AnyRouter-Title / -Source / -Version` headers; public-ranking surface.
- [Prompt Caching](https://anyrouter.dev/docs/features/caching.md) — Cache long system prompts across requests.
- [BYOK (Bring Your Own Key)](https://anyrouter.dev/docs/features/byok.md) — Attach upstream provider keys so requests run at list price through your accounts.
- [Tool Use](https://anyrouter.dev/docs/features/tool-use.md) — Cross-provider function calling + structured outputs.
- [Presets](https://anyrouter.dev/docs/features/presets.md) — Reusable config bundles, callable as `@preset/<name>` from any request.
- [Rate Limits](https://anyrouter.dev/docs/features/rate-limits.md) — Per-IP and per-key tiers; `429` vs `403` semantics; backoff guidance.
- [Privacy & Logging Controls](https://anyrouter.dev/docs/features/privacy-controls.md) — Body capture, PII redaction, training opt-out, blocked providers, residency.
- [Credits & Billing](https://anyrouter.dev/docs/features/credits.md) — How credits work, free monthly grants, top-ups.
- [Models Catalog](https://anyrouter.dev/docs/features/models-catalog.md) — Browse every model with pricing, context limits, capabilities.
- [Request Logs](https://anyrouter.dev/docs/features/request-logs.md) — Per-request inspection: latency, tokens, cost, upstream provider, full body when privacy allows.
- [Usage Explorer](https://anyrouter.dev/docs/features/usage-explorer.md) — Cost / token / request charts grouped by model, key, or time.
- [Managing API Keys](https://anyrouter.dev/docs/features/api-keys.md) — Create, rotate, scope, and rate-limit keys from the dashboard.
- [Organizations & Workspaces](https://anyrouter.dev/docs/features/organizations.md) — Multi-tenant: invite teammates, set roles, isolate billing.

**MCP** (configured by this plugin)
- [MCP Server](https://anyrouter.dev/docs/mcp.md) — Consumer setup for Claude Desktop, Cursor, Claude Code, OpenCode. OAuth consent on first tool call.
- [MCP API Reference](https://anyrouter.dev/docs/api-reference/mcp.md) — JSON-RPC tool catalog, scopes (Read-only / Standard / Full), error shapes, manual auth.

**API Reference** (every inference + management endpoint)
- [API Overview](https://anyrouter.dev/docs/api-reference/overview.md) — Pick the right surface: Chat Completions, Messages, Responses, Images, Embeddings, Models.
- [Chat Completions](https://anyrouter.dev/docs/api-reference/chat-completions.md) — `POST /api/v1/chat/completions`, OpenAI-compatible, every model.
- [Messages](https://anyrouter.dev/docs/api-reference/messages.md) — `POST /api/v1/messages`, Anthropic-compatible passthrough for `anthropic/*` models.
- [Responses](https://anyrouter.dev/docs/api-reference/responses.md) — `POST /api/v1/responses`, structured output items + tools.
- [Models](https://anyrouter.dev/docs/api-reference/models.md) — List and inspect catalog entries: pricing, context, capabilities, routing.
- [Providers](https://anyrouter.dev/docs/api-reference/providers.md) — Upstream backends AnyRouter can dispatch to.
- [Embeddings](https://anyrouter.dev/docs/api-reference/embeddings.md) — Text embeddings for semantic search.
- [Images](https://anyrouter.dev/docs/api-reference/images.md) — Text-to-image generation.
- [Keys](https://anyrouter.dev/docs/api-reference/keys.md) — Inspect, create, update, delete LLM API keys.
- [Management Keys](https://anyrouter.dev/docs/api-reference/management-keys.md) — Programmatic admin credentials (`ak_*`) for keys, presets, BYOK, credits.
- [OAuth](https://anyrouter.dev/docs/api-reference/oauth.md) — PKCE authorization codes for AnyRouter API keys.
- [Credits](https://anyrouter.dev/docs/api-reference/credits.md) — Remaining balance per API key.
- [Health](https://anyrouter.dev/docs/api-reference/health.md) — Gateway and per-provider availability snapshot.
- [Errors (guide)](https://anyrouter.dev/docs/guides/errors.md) — Cross-endpoint error envelope and retry behavior.

If a URL above 404s, the page was renamed or removed — fetch `/docs.md` and pick the current link from the live index.

## Adding AnyRouter to a project (fresh)

### TypeScript (`openai` SDK)

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

```bash
export ANTHROPIC_BASE_URL="https://anyrouter.dev/api"
export ANTHROPIC_AUTH_TOKEN="sk-ar-your-key"
```

For tier-name pinning and a `claude-ar` wrapper, see https://anyrouter.dev/docs/guides/claude-code.md.

### Codex / Cursor / Aider / Hermes / OpenClaw

Any client that accepts a custom OpenAI base URL works. Set:

- Base URL: `https://anyrouter.dev/api/v1`
- API key: `sk-ar-…` from the dashboard
- Model: `provider/model` from the catalog

Generic paste-prompt for any coding agent: https://anyrouter.dev/docs/guides/ai-agent-integration.md.

## Migration recipes (one-line summary)

All three boil down to **swap base URL, swap key, keep request shape**.

- **From OpenAI** → change `baseURL` to `https://anyrouter.dev/api/v1`, env to `ANYROUTER_API_KEY`, model id `gpt-*` → `openai/gpt-*`. Details: https://anyrouter.dev/docs/guides/migrate-from-openai.md.
- **From Anthropic** → either keep the Anthropic SDK and set `ANTHROPIC_BASE_URL=https://anyrouter.dev/api` (Anthropic-native `/messages`), or unify on `/chat/completions` with `model: "anthropic/claude-sonnet-4.6"`. Details: https://anyrouter.dev/docs/guides/migrate-from-anthropic.md.
- **From OpenRouter** → identical request shape. Change base URL to `https://anyrouter.dev/api/v1`, key env to `ANYROUTER_API_KEY`. `provider.only / .ignore / .order / .sort / .max_price / .allow_fallbacks` all map across. Details: https://anyrouter.dev/docs/guides/migrate-from-openrouter.md.

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

Pin a single upstream with `X-AnyRouter-Provider: <provider_id>` — useful for reproducibility, BYOK testing, and outage debugging. Full routing model: https://anyrouter.dev/docs/features/routing.md.

## App attribution

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

Full schema: https://anyrouter.dev/docs/features/app-attribution.md.

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

Full tool catalog, scopes, and manual-auth path: https://anyrouter.dev/docs/api-reference/mcp.md. Client setup for Claude Desktop / Cursor / Claude Code / OpenCode: https://anyrouter.dev/docs/mcp.md.

## Defaults that almost always belong in production

- Read the key from env, never inline.
- Use `provider/model` ids; never bare model names except via aliases the docs explicitly list.
- Set the three `X-AnyRouter-*` attribution headers so dashboard analytics work.
- Keep `allow_fallbacks: true` unless you're running an eval that needs a fixed upstream.
- Long agent loops: bump SDK timeout (`API_TIMEOUT_MS=3000000` for Claude Code).
- Respect `X-RateLimit-Remaining` and `X-Upstream-RateLimit-Remaining` headers.
