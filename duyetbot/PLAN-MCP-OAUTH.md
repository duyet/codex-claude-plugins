# Duyetbot MCP Server with GitHub OAuth

> Build an authenticated MCP server that gives duyetbot access to GitHub operations and persistent memory via OAuth login.

## Overview

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
│  Claude Code    │────▶│  duyetbot-mcp    │────▶│   GitHub    │
│  (duyetbot)     │     │  (OAuth Server)  │     │   API       │
└─────────────────┘     └──────────────────┘     └─────────────┘
        │                       │
        │                       ▼
        │               ┌──────────────────┐
        └──────────────▶│  Cloudflare D1   │
                        │  (Memory Store)  │
                        └──────────────────┘
```

## Architecture

### Components

1. **duyetbot-mcp** - MCP server providing:
   - GitHub operations (repos, issues, PRs, commits)
   - Persistent memory (cross-session context)
   - User identity and preferences

2. **GitHub OAuth 2.1 + PKCE** - Authentication flow:
   - User logs in via GitHub
   - Short-lived access tokens
   - Secure token refresh

3. **Cloudflare Workers** - Deployment:
   - Edge compute for low latency
   - D1 database for memory
   - KV for token storage

---

## Implementation Plan

### Phase 1: GitHub OAuth App Setup

```bash
# 1. Create OAuth App at: github.com/settings/developers
# 2. Configure:
#    - Application name: duyetbot-mcp
#    - Homepage URL: https://duyetbot.duyet.net
#    - Callback URL: https://duyetbot-mcp.duyet.workers.dev/auth/callback
# 3. Save Client ID and Client Secret
```

**Environment Variables:**
```env
GITHUB_CLIENT_ID=xxx
GITHUB_CLIENT_SECRET=xxx
MCP_SERVER_URL=https://duyetbot-mcp.duyet.workers.dev
```

### Phase 2: MCP Server Structure

```
duyetbot-mcp/
├── src/
│   ├── index.ts              # Entry point
│   ├── server.ts             # MCP server setup
│   ├── auth/
│   │   ├── oauth.ts          # OAuth 2.1 + PKCE flow
│   │   ├── github.ts         # GitHub provider
│   │   └── tokens.ts         # Token management
│   ├── tools/
│   │   ├── github.ts         # GitHub API tools
│   │   ├── memory.ts         # Memory tools
│   │   └── identity.ts       # User identity tools
│   ├── resources/
│   │   ├── repos.ts          # Repository resources
│   │   └── context.ts        # Session context
│   └── storage/
│       ├── d1.ts             # D1 database adapter
│       └── kv.ts             # KV token store
├── wrangler.toml             # Cloudflare config
├── package.json
└── tsconfig.json
```

### Phase 3: OAuth Flow Implementation

```typescript
// src/auth/oauth.ts
import { Hono } from 'hono';

const GITHUB_AUTH_URL = 'https://github.com/login/oauth/authorize';
const GITHUB_TOKEN_URL = 'https://github.com/login/oauth/access_token';

export function createOAuthRouter(env: Env) {
  const app = new Hono();

  // OAuth discovery endpoint (RFC 9728)
  app.get('/.well-known/oauth-authorization-server', (c) => {
    return c.json({
      issuer: env.MCP_SERVER_URL,
      authorization_endpoint: `${env.MCP_SERVER_URL}/auth/authorize`,
      token_endpoint: `${env.MCP_SERVER_URL}/auth/token`,
      response_types_supported: ['code'],
      grant_types_supported: ['authorization_code', 'refresh_token'],
      code_challenge_methods_supported: ['S256'],
      scopes_supported: ['repo', 'user', 'read:org']
    });
  });

  // Start OAuth flow
  app.get('/auth/authorize', async (c) => {
    const { code_challenge, code_challenge_method, redirect_uri, state } = c.req.query();

    // Store PKCE challenge
    await env.KV.put(`pkce:${state}`, code_challenge, { expirationTtl: 600 });

    // Redirect to GitHub
    const params = new URLSearchParams({
      client_id: env.GITHUB_CLIENT_ID,
      redirect_uri: `${env.MCP_SERVER_URL}/auth/callback`,
      scope: 'repo user read:org',
      state,
    });

    return c.redirect(`${GITHUB_AUTH_URL}?${params}`);
  });

  // OAuth callback from GitHub
  app.get('/auth/callback', async (c) => {
    const { code, state } = c.req.query();

    // Exchange code for token
    const tokenResponse = await fetch(GITHUB_TOKEN_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({
        client_id: env.GITHUB_CLIENT_ID,
        client_secret: env.GITHUB_CLIENT_SECRET,
        code,
      }),
    });

    const { access_token, refresh_token } = await tokenResponse.json();

    // Store tokens securely
    await env.KV.put(`token:${state}`, JSON.stringify({
      access_token,
      refresh_token,
      created_at: Date.now(),
    }), { expirationTtl: 86400 });

    // Return authorization code to MCP client
    const redirectUri = await env.KV.get(`redirect:${state}`);
    return c.redirect(`${redirectUri}?code=${state}`);
  });

  // Token endpoint (exchange auth code for access token)
  app.post('/auth/token', async (c) => {
    const { code, code_verifier, grant_type } = await c.req.json();

    if (grant_type === 'authorization_code') {
      // Verify PKCE
      const storedChallenge = await env.KV.get(`pkce:${code}`);
      const computedChallenge = await computePKCEChallenge(code_verifier);

      if (storedChallenge !== computedChallenge) {
        return c.json({ error: 'invalid_grant' }, 400);
      }

      // Return stored token
      const tokenData = await env.KV.get(`token:${code}`);
      return c.json(JSON.parse(tokenData));
    }

    return c.json({ error: 'unsupported_grant_type' }, 400);
  });

  return app;
}
```

### Phase 4: MCP Tools

```typescript
// src/tools/github.ts
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';

export function registerGitHubTools(server: McpServer, getToken: () => string) {
  // List repositories
  server.tool(
    'github_list_repos',
    'List GitHub repositories for the authenticated user',
    {
      visibility: z.enum(['all', 'public', 'private']).optional(),
      sort: z.enum(['created', 'updated', 'pushed', 'full_name']).optional(),
    },
    async ({ visibility = 'all', sort = 'updated' }) => {
      const response = await fetch(
        `https://api.github.com/user/repos?visibility=${visibility}&sort=${sort}`,
        {
          headers: {
            'Authorization': `Bearer ${getToken()}`,
            'Accept': 'application/vnd.github.v3+json',
          },
        }
      );
      const repos = await response.json();
      return {
        content: [{
          type: 'text',
          text: JSON.stringify(repos.map(r => ({
            name: r.full_name,
            description: r.description,
            url: r.html_url,
            stars: r.stargazers_count,
          })), null, 2)
        }]
      };
    }
  );

  // Create issue
  server.tool(
    'github_create_issue',
    'Create a new GitHub issue',
    {
      repo: z.string().describe('Repository in format owner/repo'),
      title: z.string().describe('Issue title'),
      body: z.string().describe('Issue body'),
      labels: z.array(z.string()).optional(),
    },
    async ({ repo, title, body, labels }) => {
      const response = await fetch(
        `https://api.github.com/repos/${repo}/issues`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${getToken()}`,
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ title, body, labels }),
        }
      );
      const issue = await response.json();
      return {
        content: [{
          type: 'text',
          text: `Created issue #${issue.number}: ${issue.html_url}`
        }]
      };
    }
  );

  // Create pull request
  server.tool(
    'github_create_pr',
    'Create a new pull request',
    {
      repo: z.string(),
      title: z.string(),
      body: z.string(),
      head: z.string().describe('Branch with changes'),
      base: z.string().describe('Target branch'),
    },
    async ({ repo, title, body, head, base }) => {
      const response = await fetch(
        `https://api.github.com/repos/${repo}/pulls`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${getToken()}`,
            'Accept': 'application/vnd.github.v3+json',
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ title, body, head, base }),
        }
      );
      const pr = await response.json();
      return {
        content: [{
          type: 'text',
          text: `Created PR #${pr.number}: ${pr.html_url}`
        }]
      };
    }
  );

  // Get user info
  server.tool(
    'github_whoami',
    'Get authenticated GitHub user information',
    {},
    async () => {
      const response = await fetch('https://api.github.com/user', {
        headers: {
          'Authorization': `Bearer ${getToken()}`,
          'Accept': 'application/vnd.github.v3+json',
        },
      });
      const user = await response.json();
      return {
        content: [{
          type: 'text',
          text: `Logged in as: ${user.login} (${user.name})\nEmail: ${user.email}\nRepos: ${user.public_repos}`
        }]
      };
    }
  );
}
```

```typescript
// src/tools/memory.ts
export function registerMemoryTools(server: McpServer, env: Env, userId: string) {
  // Store memory
  server.tool(
    'memory_store',
    'Store a piece of information in persistent memory',
    {
      key: z.string().describe('Memory key'),
      value: z.string().describe('Content to store'),
      ttl: z.number().optional().describe('Time to live in seconds'),
    },
    async ({ key, value, ttl }) => {
      await env.D1.prepare(
        'INSERT OR REPLACE INTO memories (user_id, key, value, created_at, expires_at) VALUES (?, ?, ?, ?, ?)'
      ).bind(
        userId,
        key,
        value,
        Date.now(),
        ttl ? Date.now() + ttl * 1000 : null
      ).run();

      return {
        content: [{ type: 'text', text: `Stored memory: ${key}` }]
      };
    }
  );

  // Retrieve memory
  server.tool(
    'memory_recall',
    'Recall a stored memory by key',
    { key: z.string() },
    async ({ key }) => {
      const result = await env.D1.prepare(
        'SELECT value FROM memories WHERE user_id = ? AND key = ? AND (expires_at IS NULL OR expires_at > ?)'
      ).bind(userId, key, Date.now()).first();

      if (!result) {
        return { content: [{ type: 'text', text: `Memory not found: ${key}` }] };
      }

      return { content: [{ type: 'text', text: result.value as string }] };
    }
  );

  // List memories
  server.tool(
    'memory_list',
    'List all stored memories',
    { prefix: z.string().optional() },
    async ({ prefix }) => {
      const query = prefix
        ? 'SELECT key, substr(value, 1, 100) as preview FROM memories WHERE user_id = ? AND key LIKE ?'
        : 'SELECT key, substr(value, 1, 100) as preview FROM memories WHERE user_id = ?';

      const results = prefix
        ? await env.D1.prepare(query).bind(userId, `${prefix}%`).all()
        : await env.D1.prepare(query).bind(userId).all();

      return {
        content: [{
          type: 'text',
          text: JSON.stringify(results.results, null, 2)
        }]
      };
    }
  );

  // Delete memory
  server.tool(
    'memory_forget',
    'Delete a stored memory',
    { key: z.string() },
    async ({ key }) => {
      await env.D1.prepare(
        'DELETE FROM memories WHERE user_id = ? AND key = ?'
      ).bind(userId, key).run();

      return { content: [{ type: 'text', text: `Deleted memory: ${key}` }] };
    }
  );
}
```

### Phase 5: Main Server

```typescript
// src/index.ts
import { Hono } from 'hono';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js';
import { createOAuthRouter } from './auth/oauth';
import { registerGitHubTools } from './tools/github';
import { registerMemoryTools } from './tools/memory';

interface Env {
  GITHUB_CLIENT_ID: string;
  GITHUB_CLIENT_SECRET: string;
  MCP_SERVER_URL: string;
  KV: KVNamespace;
  D1: D1Database;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const app = new Hono();

    // OAuth routes
    app.route('/', createOAuthRouter(env));

    // MCP endpoint
    app.all('/mcp', async (c) => {
      // Validate Bearer token
      const authHeader = c.req.header('Authorization');
      if (!authHeader?.startsWith('Bearer ')) {
        return c.json({ error: 'unauthorized' }, 401);
      }

      const token = authHeader.slice(7);
      const tokenData = await validateToken(token, env);
      if (!tokenData) {
        return c.json({ error: 'invalid_token' }, 401);
      }

      // Create MCP server for this request
      const server = new McpServer({
        name: 'duyetbot-mcp',
        version: '1.0.0',
      });

      // Register tools with user's token
      registerGitHubTools(server, () => tokenData.access_token);
      registerMemoryTools(server, env, tokenData.user_id);

      // Handle MCP request
      const transport = new StreamableHTTPServerTransport({
        sessionIdGenerator: undefined,
      });

      await server.connect(transport);
      return transport.handleRequest(c.req.raw);
    });

    // Health check
    app.get('/health', (c) => c.json({ status: 'ok' }));

    return app.fetch(request, env);
  }
};

async function validateToken(token: string, env: Env) {
  // Validate with GitHub
  const response = await fetch('https://api.github.com/user', {
    headers: {
      'Authorization': `Bearer ${token}`,
      'Accept': 'application/vnd.github.v3+json',
    },
  });

  if (!response.ok) return null;

  const user = await response.json();
  return {
    access_token: token,
    user_id: user.id.toString(),
    login: user.login,
  };
}
```

### Phase 6: Database Schema

```sql
-- D1 Schema: schema.sql

-- User tokens
CREATE TABLE IF NOT EXISTS tokens (
  user_id TEXT PRIMARY KEY,
  access_token TEXT NOT NULL,
  refresh_token TEXT,
  expires_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Persistent memories
CREATE TABLE IF NOT EXISTS memories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  expires_at INTEGER,
  UNIQUE(user_id, key)
);

-- Session context
CREATE TABLE IF NOT EXISTS sessions (
  session_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  context TEXT,
  created_at INTEGER NOT NULL,
  last_active INTEGER NOT NULL
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_memories_user ON memories(user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions(user_id);
```

### Phase 7: Cloudflare Configuration

```toml
# wrangler.toml
name = "duyetbot-mcp"
main = "src/index.ts"
compatibility_date = "2024-01-01"

[vars]
MCP_SERVER_URL = "https://duyetbot-mcp.duyet.workers.dev"

[[kv_namespaces]]
binding = "KV"
id = "xxx"

[[d1_databases]]
binding = "D1"
database_name = "duyetbot-db"
database_id = "xxx"
```

### Phase 8: Plugin Integration

Update duyetbot plugin to use the new MCP:

```json
// duyetbot/.mcp.json
{
  "mcpServers": {
    "duyetbot": {
      "url": "https://duyetbot-mcp.duyet.workers.dev/mcp",
      "transport": "streamable-http",
      "auth": {
        "type": "oauth2",
        "authorizationUrl": "https://duyetbot-mcp.duyet.workers.dev/auth/authorize",
        "tokenUrl": "https://duyetbot-mcp.duyet.workers.dev/auth/token",
        "scopes": ["repo", "user"]
      },
      "description": "Duyetbot's GitHub operations and persistent memory"
    }
  }
}
```

---

## Available Tools After Implementation

| Tool | Description |
|------|-------------|
| `github_whoami` | Get authenticated user info |
| `github_list_repos` | List user's repositories |
| `github_create_issue` | Create GitHub issue |
| `github_create_pr` | Create pull request |
| `github_get_pr` | Get PR details |
| `github_merge_pr` | Merge pull request |
| `memory_store` | Store persistent memory |
| `memory_recall` | Retrieve stored memory |
| `memory_list` | List all memories |
| `memory_forget` | Delete memory |

---

## Security Checklist

- [ ] PKCE mandatory for all OAuth flows
- [ ] Short-lived access tokens (1 hour max)
- [ ] Refresh tokens with secure rotation
- [ ] Origin header validation on all requests
- [ ] Rate limiting on auth endpoints
- [ ] No secrets in code or logs
- [ ] HTTPS only in production
- [ ] Token validation on every MCP request

---

## Development Commands

```bash
# Setup
npm init -y
npm install hono @modelcontextprotocol/sdk zod

# Local development
wrangler dev

# Deploy
wrangler deploy

# Create D1 database
wrangler d1 create duyetbot-db
wrangler d1 execute duyetbot-db --file=schema.sql

# Create KV namespace
wrangler kv:namespace create KV

# Set secrets
wrangler secret put GITHUB_CLIENT_ID
wrangler secret put GITHUB_CLIENT_SECRET
```

---

## Next Steps

1. **Create GitHub OAuth App** → Get Client ID and Secret
2. **Initialize project** → `npm init`, install dependencies
3. **Implement OAuth flow** → auth routes, PKCE, token exchange
4. **Build MCP server** → tools, resources, transport
5. **Setup Cloudflare** → D1, KV, deploy
6. **Update plugin** → Connect duyetbot to new MCP
7. **Test end-to-end** → Login flow, tool execution

---

## Prompt for Implementation

```
Build duyetbot-mcp: an MCP server with GitHub OAuth 2.1 + PKCE authentication.

Stack:
- Cloudflare Workers (Hono framework)
- MCP TypeScript SDK
- D1 database (memories, sessions)
- KV storage (tokens, PKCE)

Requirements:
1. OAuth 2.1 + PKCE flow with GitHub as identity provider
2. Tools: github_whoami, github_list_repos, github_create_issue, github_create_pr
3. Memory tools: store, recall, list, forget
4. Streamable HTTP transport for MCP
5. Token validation on every request
6. Secure token storage and refresh

Start with OAuth flow, then add MCP tools, then deploy to Cloudflare.
```
