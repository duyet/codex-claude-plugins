# anyrouter

[AnyRouter](https://anyrouter.dev) is an OpenAI-compatible LLM gateway.

Install: `/plugin install anyrouter@duyet-claude-plugins`, then `export ANYROUTER_API_KEY="sk-ar-..."` (keys at anyrouter.dev/dashboard/keys).

- `anyrouter` skill: contract and pointers to live docs.
- `/anyrouter:migrate`: move an OpenAI, Anthropic, or OpenRouter integration to AnyRouter.
- `anyrouter-integrator` agent: runs that migration.
- Remote MCP server at `https://anyrouter.dev/api/v1/mcp` (OAuth on first use).

MIT. See [LICENSE](LICENSE).
