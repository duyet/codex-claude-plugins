# Duyetbot MCP Gateway with GitHub OAuth

> Build an authenticated MCP gateway that aggregates multiple backend services - GitHub, Memory, Knowledge, System Prompts - all via single OAuth login.

## Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Claude Code                                     │
│                              (duyetbot)                                      │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          duyetbot-mcp (Gateway)                              │
│                         GitHub OAuth 2.1 + PKCE                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            │
│  │   Router    │ │   Auth      │ │   Tools     │ │  Resources  │            │
│  │   Layer     │ │   Layer     │ │   Registry  │ │   Registry  │            │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘            │
└───────┬─────────────────┬─────────────────┬─────────────────┬───────────────┘
        │                 │                 │                 │
        ▼                 ▼                 ▼                 ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│  GitHub MCP   │ │  Memory MCP   │ │ Knowledge MCP │ │  Prompt MCP   │
│               │ │               │ │               │ │               │
│ • repos       │ │ • store       │ │ • search      │ │ • system      │
│ • issues      │ │ • recall      │ │ • retrieve    │ │ • templates   │
│ • PRs         │ │ • list        │ │ • embed       │ │ • personas    │
│ • commits     │ │ • forget      │ │ • context     │ │ • workflows   │
│ • actions     │ │ • sessions    │ │ • RAG         │ │ • skills      │
└───────┬───────┘ └───────┬───────┘ └───────┬───────┘ └───────┬───────┘
        │                 │                 │                 │
        ▼                 ▼                 ▼                 ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│  GitHub API   │ │ Cloudflare D1 │ │ Vectorize +   │ │ R2 Bucket +   │
│               │ │ + KV          │ │ Workers AI    │ │ D1            │
└───────────────┘ └───────────────┘ └───────────────┘ └───────────────┘
```

## Architecture

### Gateway Pattern

**duyetbot-mcp** acts as a unified gateway:
- Single OAuth login → access all services
- Route requests to appropriate backend MCP
- Aggregate responses from multiple MCPs
- Unified error handling and logging

### Backend MCPs

| MCP | Purpose | Storage | Tools |
|-----|---------|---------|-------|
| **GitHub** | Code operations | GitHub API | repos, issues, PRs, actions |
| **Memory** | Persistent context | D1 + KV | store, recall, list, forget |
| **Knowledge** | RAG & embeddings | Vectorize | search, retrieve, embed |
| **Prompt** | System prompts | R2 + D1 | templates, personas, skills |

### Authentication Flow

1. **GitHub OAuth 2.1 + PKCE** - Single sign-on
2. **User Identity** - GitHub user ID as primary key
3. **Token Propagation** - Gateway forwards auth to backends
4. **Scope Isolation** - Each backend has minimal required permissions

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

### Phase 2: MCP Gateway Structure

```
duyetbot-mcp/
├── src/
│   ├── index.ts                    # Entry point
│   ├── gateway.ts                  # MCP gateway router
│   ├── auth/
│   │   ├── oauth.ts                # OAuth 2.1 + PKCE flow
│   │   ├── github-provider.ts      # GitHub OAuth provider
│   │   └── tokens.ts               # Token management
│   ├── mcps/
│   │   ├── github/                 # GitHub MCP backend
│   │   │   ├── tools.ts            # repos, issues, PRs, actions
│   │   │   └── resources.ts        # repository resources
│   │   ├── memory/                 # Memory MCP backend
│   │   │   ├── tools.ts            # store, recall, list, forget
│   │   │   └── sessions.ts         # session context
│   │   ├── knowledge/              # Knowledge MCP backend
│   │   │   ├── tools.ts            # search, retrieve, embed
│   │   │   ├── vectorize.ts        # vector embeddings
│   │   │   └── rag.ts              # RAG pipeline
│   │   └── prompts/                # Prompt MCP backend
│   │       ├── tools.ts            # system, templates, personas
│   │       ├── skills.ts           # skill definitions
│   │       └── workflows.ts        # workflow templates
│   ├── storage/
│   │   ├── d1.ts                   # D1 database adapter
│   │   ├── kv.ts                   # KV token/cache store
│   │   ├── r2.ts                   # R2 object storage
│   │   └── vectorize.ts            # Vectorize adapter
│   └── utils/
│       ├── router.ts               # Tool routing logic
│       └── aggregator.ts           # Response aggregation
├── schema/
│   ├── memories.sql                # Memory tables
│   ├── knowledge.sql               # Knowledge base tables
│   └── prompts.sql                 # Prompt storage tables
├── wrangler.toml                   # Cloudflare config
├── package.json
└── tsconfig.json
```

### Backend MCP Details

#### 1. GitHub MCP
```typescript
// Tools provided:
github_whoami()           // Get authenticated user
github_list_repos()       // List repositories
github_create_issue()     // Create issue
github_create_pr()        // Create pull request
github_get_pr()           // Get PR details
github_merge_pr()         // Merge PR
github_list_actions()     // List workflow runs
github_trigger_action()   // Trigger workflow
github_search_code()      // Search code in repos
```

#### 2. Memory MCP
```typescript
// Tools provided:
memory_store()            // Store key-value with optional TTL
memory_recall()           // Retrieve by key
memory_list()             // List with prefix filter
memory_forget()           // Delete memory
memory_search()           // Semantic search memories
session_create()          // Create session context
session_update()          // Update session
session_get()             // Get current session
```

#### 3. Knowledge MCP
```typescript
// Tools provided:
knowledge_search()        // Semantic search knowledge base
knowledge_retrieve()      // Get document by ID
knowledge_embed()         // Create embedding for text
knowledge_ingest()        // Add document to knowledge base
knowledge_context()       // Get relevant context for query
rag_query()               // Full RAG pipeline query
```

#### 4. Prompt MCP
```typescript
// Tools provided:
prompt_get_system()       // Get system prompt for context
prompt_list_templates()   // List available templates
prompt_render()           // Render template with variables
persona_get()             // Get persona definition
persona_list()            // List available personas
skill_get()               // Get skill definition
skill_list()              // List available skills
workflow_get()            // Get workflow template
workflow_list()           // List workflows
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

### GitHub MCP Tools
| Tool | Description |
|------|-------------|
| `github_whoami` | Get authenticated user info |
| `github_list_repos` | List user's repositories |
| `github_create_issue` | Create GitHub issue |
| `github_create_pr` | Create pull request |
| `github_get_pr` | Get PR details |
| `github_merge_pr` | Merge pull request |
| `github_list_actions` | List workflow runs |
| `github_trigger_action` | Trigger GitHub Action |
| `github_search_code` | Search code in repositories |

### Memory MCP Tools
| Tool | Description |
|------|-------------|
| `memory_store` | Store key-value with optional TTL |
| `memory_recall` | Retrieve stored memory |
| `memory_list` | List memories with prefix filter |
| `memory_forget` | Delete memory |
| `memory_search` | Semantic search memories |
| `session_create` | Create session context |
| `session_update` | Update session context |
| `session_get` | Get current session |

### Knowledge MCP Tools
| Tool | Description |
|------|-------------|
| `knowledge_search` | Semantic search knowledge base |
| `knowledge_retrieve` | Get document by ID |
| `knowledge_embed` | Create embedding for text |
| `knowledge_ingest` | Add document to knowledge base |
| `knowledge_context` | Get relevant context for query |
| `rag_query` | Full RAG pipeline query |

### Prompt MCP Tools
| Tool | Description |
|------|-------------|
| `prompt_get_system` | Get system prompt for context |
| `prompt_list_templates` | List available templates |
| `prompt_render` | Render template with variables |
| `persona_get` | Get persona definition |
| `persona_list` | List available personas |
| `skill_get` | Get skill definition |
| `skill_list` | List available skills |
| `workflow_get` | Get workflow template |
| `workflow_list` | List workflows |

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

### Phase 1: Foundation
1. **Create GitHub OAuth App** → Get Client ID and Secret
2. **Initialize project** → `npm init`, install dependencies
3. **Implement OAuth flow** → auth routes, PKCE, token exchange
4. **Setup Cloudflare** → D1, KV, R2, Vectorize

### Phase 2: Backend MCPs
5. **GitHub MCP** → repos, issues, PRs, actions
6. **Memory MCP** → store, recall, sessions
7. **Knowledge MCP** → embeddings, RAG, search
8. **Prompt MCP** → templates, personas, skills

### Phase 3: Gateway
9. **Router layer** → Route tools to correct backend
10. **Aggregator** → Combine multi-MCP responses
11. **Error handling** → Unified error responses

### Phase 4: Integration
12. **Update plugin** → Connect duyetbot to gateway
13. **Test end-to-end** → Login, all tool categories
14. **Deploy production** → Cloudflare Workers

---

## Prompt for Implementation

```
Build duyetbot-mcp: an MCP gateway with GitHub OAuth 2.1 + PKCE that aggregates
multiple backend MCPs (GitHub, Memory, Knowledge, Prompts).

Stack:
- Cloudflare Workers (Hono framework)
- MCP TypeScript SDK
- D1 database (memories, sessions, prompts)
- KV storage (tokens, PKCE, cache)
- R2 (prompt templates, knowledge docs)
- Vectorize (embeddings for RAG)
- Workers AI (embedding generation)

Gateway Architecture:
┌──────────────────────────────────────────────────────────┐
│                    duyetbot-mcp Gateway                   │
│  ┌────────┐ ┌────────┐ ┌────────────┐ ┌────────────┐    │
│  │ Router │ │  Auth  │ │ Tool       │ │ Resource   │    │
│  │ Layer  │ │ Layer  │ │ Registry   │ │ Registry   │    │
│  └────────┘ └────────┘ └────────────┘ └────────────┘    │
└────────┬──────────┬──────────┬──────────┬───────────────┘
         │          │          │          │
         ▼          ▼          ▼          ▼
    ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
    │ GitHub  │ │ Memory  │ │Knowledge│ │ Prompt  │
    │   MCP   │ │   MCP   │ │   MCP   │ │   MCP   │
    └─────────┘ └─────────┘ └─────────┘ └─────────┘

Requirements:
1. OAuth 2.1 + PKCE flow with GitHub as identity provider
2. Single login → access all backend MCPs
3. Tool routing based on prefix (github_, memory_, knowledge_, prompt_)
4. GitHub MCP: repos, issues, PRs, actions, code search
5. Memory MCP: store, recall, list, forget, session management
6. Knowledge MCP: search, retrieve, embed, ingest, RAG query
7. Prompt MCP: system prompts, templates, personas, skills, workflows
8. Streamable HTTP transport
9. Token validation on every request
10. Unified error handling and logging

Implementation Order:
1. OAuth flow + GitHub MCP (MVP)
2. Memory MCP
3. Knowledge MCP with Vectorize
4. Prompt MCP
5. Gateway routing and aggregation
6. Production deployment

Start with OAuth flow, then build each backend MCP, then wire up gateway.
```

---

## Database Schemas

### Memory MCP Schema
```sql
-- Persistent memories
CREATE TABLE memories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  key TEXT NOT NULL,
  value TEXT NOT NULL,
  metadata JSON,
  embedding BLOB,           -- For semantic search
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  expires_at INTEGER,
  UNIQUE(user_id, key)
);

-- Session context
CREATE TABLE sessions (
  session_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  context JSON,
  created_at INTEGER NOT NULL,
  last_active INTEGER NOT NULL
);
```

### Knowledge MCP Schema
```sql
-- Knowledge documents
CREATE TABLE documents (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT,
  content TEXT NOT NULL,
  source TEXT,              -- URL or file path
  metadata JSON,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Document chunks for RAG
CREATE TABLE chunks (
  id TEXT PRIMARY KEY,
  document_id TEXT NOT NULL,
  content TEXT NOT NULL,
  chunk_index INTEGER NOT NULL,
  metadata JSON,
  FOREIGN KEY (document_id) REFERENCES documents(id)
);
```

### Prompt MCP Schema
```sql
-- System prompts
CREATE TABLE prompts (
  id TEXT PRIMARY KEY,
  user_id TEXT,             -- NULL for global prompts
  name TEXT NOT NULL,
  content TEXT NOT NULL,
  variables JSON,           -- Template variables
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

-- Personas
CREATE TABLE personas (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  name TEXT NOT NULL,
  description TEXT,
  system_prompt TEXT NOT NULL,
  traits JSON,
  created_at INTEGER NOT NULL
);

-- Skills
CREATE TABLE skills (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  name TEXT NOT NULL,
  description TEXT,
  content TEXT NOT NULL,    -- Skill definition
  triggers JSON,            -- When to activate
  created_at INTEGER NOT NULL
);

-- Workflows
CREATE TABLE workflows (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  name TEXT NOT NULL,
  description TEXT,
  steps JSON NOT NULL,      -- Workflow steps
  created_at INTEGER NOT NULL
);
```
