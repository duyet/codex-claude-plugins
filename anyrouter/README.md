# AnyRouter Plugin

Wire [AnyRouter](https://anyrouter.dev) — a universal, OpenAI-compatible LLM gateway for 150+ models across 28+ providers — into Claude Code, Codex, Cursor, and any other coding agent that accepts a custom base URL.

This plugin ships as both a **Claude Code plugin** (`.claude-plugin/`) and a **Codex plugin** (`.codex-plugin/`), and bundles a remote **MCP server** for key and credit management.

## What you get

- **`anyrouter` skill** — discoverable knowledge for the agent: contract, model ids, integration patterns, migration recipes (from Anthropic, OpenAI, OpenRouter), routing, streaming, app attribution.
- **`/anyrouter:migrate` command** — interactive migration of an existing LLM integration to AnyRouter.
- **`anyrouter-integrator` agent** — sub-agent that performs surgical migrations on demand.
- **MCP server** — remote MCP at `https://anyrouter.dev/api/v1/mcp` for `list_models`, `get_credits`, `list_keys`, `create_key`, `revoke_key`, `list_presets`, `list_conversations`.
- **`references/`** — a frozen snapshot of the AnyRouter docs (quickstart, dashboard, migration guides, MCP, routing, app attribution) so the agent can answer offline.

## Install

### Claude Code

```bash
/plugin marketplace add duyet/claude-plugins
/plugin install anyrouter@duyet-claude-plugins
```

Then set your key:

```bash
export ANYROUTER_API_KEY="sk-ar-..."
```

(Get one at https://anyrouter.dev/dashboard/keys.)

### Codex

The plugin's `.codex-plugin/plugin.json` declares Skill, Command, Agent, and MCP capabilities. Install via your Codex plugin loader the same way you install other plugins from `duyet/claude-plugins`.

### MCP only

If you only want the AnyRouter MCP server in another client (Claude Desktop, Cursor, Claude Code CLI, OpenCode), point it at `https://anyrouter.dev/api/v1/mcp` — full per-client setup is in [`references/mcp.md`](references/mcp.md).

## Quick usage

After installing, the agent will load the `anyrouter` skill on its own when you say things like:

- "Add AnyRouter to this project."
- "Migrate this from OpenAI to AnyRouter."
- "Move my OpenRouter calls to AnyRouter."
- "Point Claude Code at AnyRouter."
- "List my AnyRouter API keys." (uses MCP)
- "How much credit do I have left?" (uses MCP)

You can also invoke the slash command directly:

```
/anyrouter:migrate
```

## Contract

| Setting | Value |
| --- | --- |
| Base URL | `https://anyrouter.dev/api/v1` |
| API key env | `ANYROUTER_API_KEY` (prefix `sk-ar-`) |
| Model id format | `provider/model` |
| Default model | `openai/gpt-5.4-mini` |
| Anthropic-native base | `https://anyrouter.dev/api` (for `/messages`) |
| MCP endpoint | `https://anyrouter.dev/api/v1/mcp` |

## Reference snapshot

The `references/` directory contains the canonical AnyRouter docs at the time the plugin was published. Live docs always win — fetch fresh content from https://anyrouter.dev/docs for any current question.

| Topic | File |
| --- | --- |
| Quickstart | `references/getting-started_quickstart.md` |
| Dashboard tour | `references/guides_dashboard-tour.md` |
| Claude Code | `references/guides_claude-code.md` |
| Hermes Agent | `references/guides_hermes-agent.md` |
| OpenClaw | `references/guides_openclaw.md` |
| AI agent integration | `references/guides_ai-agent-integration.md` |
| Streaming | `references/guides_streaming.md` |
| Migrate from OpenAI | `references/guides_migrate-from-openai.md` |
| Migrate from Anthropic | `references/guides_migrate-from-anthropic.md` |
| Migrate from OpenRouter | `references/guides_migrate-from-openrouter.md` |
| App attribution | `references/features_app-attribution.md` |
| Smart routing | `references/features_routing.md` |
| MCP server | `references/mcp.md` |
| MCP API reference | `references/api-reference_mcp.md` |

## License

MIT. See [LICENSE](LICENSE).
