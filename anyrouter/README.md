# anyrouter

Wire [AnyRouter](https://anyrouter.dev), an OpenAI-compatible LLM gateway, into Claude Code, Codex, Cursor, and other coding agents.

```bash
/plugin install anyrouter@duyet-claude-plugins
export ANYROUTER_API_KEY="sk-ar-..."
```

Get a key at [anyrouter.dev/dashboard/keys](https://anyrouter.dev/dashboard/keys).

## What ships

- `anyrouter` skill. The contract (base URL, key env, `provider/model` ids), integration and migration recipes, routing, attribution, and MCP notes. It tells the agent to fetch live docs from [anyrouter.dev/docs.md](https://anyrouter.dev/docs.md) instead of trusting a snapshot.
- `/anyrouter:migrate` command. Moves an existing OpenAI, Anthropic, or OpenRouter integration to AnyRouter and adds a smoke test.
- `anyrouter-integrator` agent. Runs that migration on demand.
- A remote MCP server at `https://anyrouter.dev/api/v1/mcp` for models, credits, keys, presets, and conversations. It authorizes through OAuth on first use. Client setup is at [anyrouter.dev/docs/mcp.md](https://anyrouter.dev/docs/mcp.md).

## Try it

- "Add AnyRouter to this project."
- "Migrate this from OpenAI to AnyRouter."
- "Point Claude Code at AnyRouter."
- "How much credit do I have left?"

MIT. See [LICENSE](LICENSE).
