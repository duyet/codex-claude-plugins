# MCP API Reference

> JSON-RPC tool catalog, scopes, error shapes, and manual authentication for the AnyRouter MCP server.


# MCP API Reference

AnyRouter runs a [Model Context Protocol](https://modelcontextprotocol.io) server at:

```
https://anyrouter.dev/api/v1/mcp
```

For step-by-step client setup (Claude Desktop, Claude Code, Cursor, OpenCode, …), see [MCP Server](/docs/mcp). This page is the protocol reference: tools, arguments, scopes, errors, and the manual auth path for clients that can't run OAuth.

## Transport

- Endpoint: `POST https://anyrouter.dev/api/v1/mcp`
- Protocol: JSON-RPC 2.0 over HTTPS (Streamable HTTP transport)
- Authentication: OAuth 2.1 bearer token (`Authorization: Bearer <token>`), or a static API key (see [Manual authentication](#manual-authentication))
- Content type: `application/json`

The MCP server does **not** expose a chat tool. Clients call the existing [Chat Completions](/docs/api-reference/chat-completions), [Messages](/docs/api-reference/messages), or [Responses](/docs/api-reference/responses) endpoints directly with your API keys.

## Tools

| Tool | Purpose | Arguments | Scope |
|------|---------|-----------|-------|
| `list_models` | Search the AnyRouter model catalog. | `provider` (string), `capability` (string), `min_context` (number), `limit` (number, default 100) | None (always available) |
| `get_credits` | Return workspace balance and lifetime usage totals. | None | `read:credits` |
| `list_keys` | List workspace LLM API keys. | `include_disabled` (boolean, default `false`) | `read:llm-keys` |
| `create_key` | Create a new LLM API key. | `name` (string), `label` (string, optional), `rate_limit` (number, optional) | `write:llm-keys` |
| `revoke_key` | Disable an LLM API key. | `key_id` (string) | `write:llm-keys` |
| `list_presets` | List workspace presets. | None | `read:presets` |
| `list_conversations` | Search workspace conversations. | `starred` (boolean), `limit` (number, default 50), `search` (string) | `read:llm-keys` |

## Scopes and consent bundles

When a client requests authorization, the user picks one of these bundles on the AnyRouter consent screen:

| Bundle | Includes | Use when |
|--------|----------|----------|
| **Read-only** (default) | `read:llm-keys`, `read:presets`, `read:credits`, `list_models` | The client should observe the workspace without making changes. |
| **Standard** | Read-only + `write:llm-keys`, `write:presets` | The client needs to create/revoke keys or modify presets. |
| **Full** | Standard + `read:byok`, `write:byok`, `read:management-keys`, `write:management-keys` | The client manages BYOK providers and management keys (rare). |

Users can downgrade from what a client requests. A tool that requires a scope outside the granted bundle returns a `permission denied` error.

## Manual authentication

Clients that cannot run OAuth can authenticate with a static bearer token:

- An **LLM API key** (`sk-ar-v1-*`) from [/dashboard/keys](/dashboard/keys). Grants access to `list_models` only.
- A **Management API key** (`ak_*`) from [/dashboard/management-keys](/dashboard/management-keys) with the scopes you need.

```bash
curl https://anyrouter.dev/api/v1/mcp \
  -H "Authorization: Bearer ak_your_management_key" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"tools/list","params":{},"id":1}'
```

## Errors

Tool failures return a JSON-RPC error:

```json
{
  "jsonrpc": "2.0",
  "error": {
    "code": -32001,
    "message": "Tool <name> failed: <details>"
  },
  "id": 1
}
```

Common cases:

- **No workspace bound** — the credential is not associated with a workspace. Create a key from the dashboard first.
- **Unauthorized** — the credential is invalid, revoked, or expired. Check [/dashboard/keys](/dashboard/keys) or [/dashboard/management-keys](/dashboard/management-keys).
- **Permission denied** — the credential lacks the scope the tool requires. Pick a higher permission level on the consent screen or upgrade the management key's scopes.

## Revoking access

To revoke an MCP client's access:

1. Open [/dashboard/mcp](/dashboard/mcp).
2. Find the client under **Connected clients**.
3. Click **Revoke**. The token is deleted immediately; subsequent tool calls return `401 Unauthorized`.

Revoking does not uninstall the client config. The next tool invocation simply re-runs OAuth.

## Security notes

- Access tokens are bearer tokens — treat them like passwords.
- All connections use HTTPS. The MCP endpoint refuses unencrypted HTTP.
- If you lose a device or suspect a leak, revoke the corresponding client on [/dashboard/mcp](/dashboard/mcp) immediately.
- Starting a new consent flow from the same client (e.g., after clearing browser state) mints a new token. Old tokens remain valid until explicitly revoked.
