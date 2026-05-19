# MCP Server

> Bring AnyRouter into Claude Desktop, Cursor, Claude Code, OpenCode, and any other MCP-aware client.


# MCP Server

AnyRouter MCP is a [Model Context Protocol](https://modelcontextprotocol.io) server. MCP-aware clients can connect with one URL and get tools for browsing the model catalog, managing your API keys, and checking credits — without leaving the client.

The endpoint is:

```
https://anyrouter.dev/api/v1/mcp
```

## Who is this for

Anyone using an MCP-aware tool day-to-day:

- **Claude Desktop** users who want to ask Claude "what AnyRouter models support vision?" or "create me a new API key called staging" without opening a browser.
- **Cursor**, **Claude Code**, and **OpenCode** users who want AnyRouter tools inline alongside their other MCP integrations.
- **Builders of MCP-aware agents** who want a hosted, OAuth-secured catalog and key-management surface for their users.

If you only need to call models, you do **not** need MCP — point your client at the standard [Chat Completions](/docs/api-reference/chat-completions), [Messages](/docs/api-reference/messages), or [Responses](/docs/api-reference/responses) endpoint with an API key.

## Connect a client

Every supported client uses the same URL. The first tool call redirects you to AnyRouter, where you pick a permission level (Read-only is the default and safest) and approve. From then on the tools just work.

### Claude Desktop

Claude Desktop has a built-in UI for adding MCP servers — no config file editing needed.

1. Open Claude Desktop → **Settings** → **Connectors**.
2. Click **Add custom connector**.
3. Fill in:
   - **Name**: `AnyRouter`
   - **Remote MCP server URL**: `https://anyrouter.dev/api/v1/mcp`
4. Click **Add** and approve the OAuth consent screen.

Ask Claude "what AnyRouter models support vision?" to verify the connection.

### Claude Code

Add the server with one command:

```bash
claude mcp add --transport http anyrouter https://anyrouter.dev/api/v1/mcp
```

The next time you invoke a tool, Claude Code opens the OAuth consent page in your browser.

### Cursor

1. Open **Cursor Settings** → **MCP & Integrations** → **Add Custom MCP**.
2. Name: `anyrouter`, URL: `https://anyrouter.dev/api/v1/mcp`.
3. Save and approve on the consent screen.

Alternatively, edit `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "anyrouter": {
      "url": "https://anyrouter.dev/api/v1/mcp"
    }
  }
}
```

### OpenCode

Add the server to `opencode.json` (project root) or `~/.config/opencode/opencode.json` (global):

```json
{
  "mcp": {
    "anyrouter": {
      "type": "remote",
      "url": "https://anyrouter.dev/api/v1/mcp",
      "enabled": true
    }
  }
}
```

Restart OpenCode and approve the OAuth consent screen on first tool use.

### Other MCP-aware clients

Any client that supports remote MCP servers over HTTP works the same way: point it at `https://anyrouter.dev/api/v1/mcp` and complete OAuth on first use. If your client cannot run OAuth, see [Manual authentication](/docs/api-reference/mcp#manual-authentication).

## What can the client do

Seven tools, gated by the permission level you grant on the consent screen:

| Tool | What it does |
|---|---|
| `list_models` | Search the catalog by provider, capability, or context window |
| `get_credits` | Check workspace balance and lifetime usage |
| `list_keys` | List your AnyRouter API keys |
| `create_key` | Mint a new API key |
| `revoke_key` | Disable a key by id |
| `list_presets` | List saved request presets |
| `list_conversations` | Search workspace conversations |

There is no chat tool — MCP clients already call models directly. The MCP server is for the surrounding workflow (browsing, key hygiene, presets) that the chat API can't do.

See the [MCP API reference](/docs/api-reference/mcp) for full argument schemas, scope requirements, JSON-RPC error shapes, and the manual-authentication path for clients that can't run OAuth.

## Managing connected clients

The [MCP dashboard](/dashboard/mcp) shows every client that has authorized your workspace and lets you revoke any of them with one click. Revoking takes effect immediately — the next tool call from that client returns `401 Unauthorized`.

## Where to go next

- **[/docs/api-reference/mcp](/docs/api-reference/mcp)** — full tool catalog, scope rules, error shapes, manual authentication
- **[/dashboard/mcp](/dashboard/mcp)** — your connected MCP clients and revoke controls
