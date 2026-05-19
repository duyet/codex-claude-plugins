# Duyet MCP Server

> **Type**: project
> **Last Updated**: 2025-01-05
> **Repository**: https://github.com/duyet/duyet-mcp-server
> **Live Demo**: https://mcp.duyet.net
> **Related**: [duyet-profile](../../duyet-profile.md), [duyetbot-agent](../duyetbot-agent/)

## Project Overview

Duyet MCP Server is an **experimental remote MCP (Model Context Protocol) server** that helps AI assistants connect to and retrieve information about @duyet. This server provides access to information primarily available at https://duyet.net, making it available directly to AI assistants.

**Key Purpose**: Enable AI assistants to access and retrieve information about duyet's work, projects, and content that would otherwise require manual web browsing.

**Note**: This is a study, demo, and experimental project designed to explore MCP capabilities. The project serves as a learning exercise in building remote MCP servers and is mostly written by LLM as well.

## Tech Stack

- **Framework**: Hono.js running on Cloudflare Workers
- **Database**: Cloudflare D1 with Drizzle ORM
- **Testing**: Jest with comprehensive test coverage
- **Linting**: Biome for code quality
- **Type Safety**: TypeScript with strict configuration
- **Deployment**: Cloudflare Workers (serverless)

## Architecture

```
┌─────────────────┐     ┌─────────────────┐
│  AI Assistant   │────▶│  MCP Client     │
│  (Claude Code)  │     │  (mcp-remote)   │
└─────────────────┘     └─────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────┐
│         Cloudflare Workers (MCP Server)         │
│  ┌───────────────┐      ┌─────────────────────┐ │
│  │  Hono.js      │─────▶│  Cloudflare D1     │ │
│  │  Endpoints    │      │  (Database)         │ │
│  └───────────────┘      └─────────────────────┘ │
└─────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────┐
│          External Data Sources                   │
│  ┌──────────────┐  ┌──────────────┐             │
│  │ duyet.net    │  │ GitHub API   │             │
│  │ blog.duyet.  │  │ (activity)   │             │
│  │ net          │  │              │             │
│  └──────────────┘  └──────────────┘             │
└─────────────────────────────────────────────────┘
```

## Deployment

**Live Endpoint**: https://mcp.duyet.net

**Available Endpoints**:
- `/sse` - Server-Sent Events transport
- `/mcp` - Standard HTTP transport

### Claude Code Integration

```bash
claude mcp add --transport http duyet https://mcp.duyet.net/mcp
```

### Configuration

For local AI assistant configuration:

```json
{
  "mcpServers": {
    "duyet-mcp-server": {
      "command": "npx",
      "args": ["mcp-remote", "https://mcp.duyet.net/sse"]
    }
  }
}
```

### Deploy Your Own

```bash
git clone https://github.com/duyet/duyet-mcp-server
cd duyet-mcp-server
npm install
npm run deploy
```

This will deploy your MCP server to a URL like: `duyet-mcp-server.<your-account>.workers.dev/sse`

## Available Resources

Resources provide read-only access to information through URI-based requests. These are automatically discoverable by Claude Chat.

### Core Information Resources

| Resource URI | Description |
|--------------|-------------|
| `duyet://about` | Basic information about Duyet with dynamically calculated years of experience |
| `duyet://cv/summary` | Brief CV overview |
| `duyet://cv/detailed` | Comprehensive CV information |
| `duyet://cv/json` | Structured CV data (when available) |

### Content Resources

| Resource URI | Description |
|--------------|-------------|
| `duyet://blog/posts/{limit}` | Latest blog posts (limit: 1-10) |
| `duyet://blog/posts/1` | Latest blog post |
| `duyet://blog/posts/5` | Latest 5 blog posts |
| `duyet://github-activity` | Recent GitHub contributions and activity |

## Available Tools

Tools provide interactive functionality with input parameters and side effects.

### Core Information Tools

| Tool | Description |
|------|-------------|
| `get_cv` | Retrieve Duyet's CV in different formats (summary, detailed, JSON) |
| `get_about_duyet` | Get basic information including experience, skills, contact links |

### Content Tools

| Tool | Description |
|------|-------------|
| `get_blog_posts` | Get blog posts from blog.duyet.net in JSON format (1-20 posts) |
| `get_blog_post_content` | Get full content of a specific blog post by URL |
| `get_github_activity` | Recent GitHub activity (commits, issues, PRs, releases, up to 20 activities) |

### Web Tools

| Tool | Description |
|------|-------------|
| `web-search` | Search web using DuckDuckGo (1-10 results) |
| `web-fetch` | Fetch content from URL (HTML, JSON, text) - restricted to trusted domains |

### Interaction Tools

| Tool | Description |
|------|-------------|
| `send_message` | Send message to Duyet for collaboration, job opportunities, consulting |
| `hire_me` | Get information about hiring Duyet (full-time, contract, consulting, part-time) |
| `say_hi` | Send friendly greeting with optional personal message, get contact info |

### Management Tools

| Tool | Description |
|------|-------------|
| `contact_analytics` | Generate analytics on contact submissions (summary, trends, recent activity) |

## Natural Conversation Flow

The key advantage of this MCP server design is natural discovery through resources:

### Information Questions → Automatic Resource Access

```
User: "Who is Duyet?"
Claude: [Accesses duyet://about]
→ Duyet is a Data Engineer with 8+ years of experience...

User: "What's his experience?"
Claude: [Accesses duyet://cv/detailed]
→ Based on Duyet's detailed CV, he has 8 years of experience...

User: "What's he writing about?"
Claude: [Accesses duyet://blog/posts/3]
→ His latest blog posts include topics on data engineering...
```

### Action Requests → Interactive Tools

```
User: "I want to contact him"
Claude: [Uses send_message tool]
→ What type of opportunity is this?

User: "Get his resume"
Claude: [Uses get_cv tool]
→ Here's Duyet's CV in detailed format...
```

### Progressive Disclosure

1. Start with general questions
2. Drill down into specific areas
3. Take actions when ready

## Claude Chat Examples

### Learning About Duyet

```
User: Who is Duyet and what does he do?

Claude: [Automatically accesses duyet://about resource]
Duyet is a Data Engineer with 8 years of experience. He is confident
in his knowledge of Data Engineering concepts, best practices and
state-of-the-art data and Cloud technologies.

User: What has he been writing about lately?

Claude: [Automatically accesses duyet://blog/posts/3 resource]
His latest blog posts include topics on data engineering, cloud
technologies, and distributed systems.
```

### Hiring and Collaboration

```
User: I'm looking to hire a data engineer

Claude: I can help you send a message to Duyet using the send_message tool.
What type of opportunity is this?

User: Full-time position at our startup

Claude: [Uses send_message tool]
Your message has been sent successfully! Reference ID: abc-123-def
```

### Technical Research

```
User: I want to understand Duyet's technical background

Claude: [Accesses duyet://cv/detailed]
Based on Duyet's detailed CV, he has 8 years of experience in data
engineering with expertise in Apache Spark, Kafka, cloud platforms,
and distributed systems.

User: Can you show me some of his recent technical work?

Claude: [Accesses duyet://github-activity]
His recent GitHub activity shows contributions to data engineering
projects, MCP server implementations, and open source tools.
```

## Customization

To add your own tools to the MCP server, define each tool inside the `init()` method of `src/index.ts` using `this.server.tool(...)`.

### Testing

You can test your MCP server using the **Cloudflare AI Playground**:

1. Go to https://playground.ai.cloudflare.com/
2. Enter your deployed MCP server URL
3. Use the duyet information tools directly from the playground!

### Claude Desktop Integration

Update Claude Desktop config (Settings > Developer > Edit Config):

```json
{
  "mcpServers": {
    "duyet-info": {
      "command": "npx",
      "args": ["mcp-remote", "https://duyet-mcp-server.<account>.workers.dev/sse"]
    }
  }
}
```

## CI/CD Pipeline

- **CI/CD Pipeline**: Automated testing and deployment
- **Codecov**: Code coverage reporting
- **Security and Dependencies**: Automated security scanning

## License

MIT License - see LICENSE file for details.

## Related Projects

| Project | URL | Description |
|---------|-----|-------------|
| duyetbot | https://github.com/duyet/codex-claude-plugins | Duyetbot plugin for Claude Code |
| clickhouse-monitoring | https://github.com/duyet/clickhouse-monitoring | ClickHouse monitoring dashboard |
| duyet.net | https://duyet.net | Personal website |
| blog.duyet.net | https://blog.duyet.net | Technical blog |

---

**Design Philosophy**: Enable AI assistants to naturally discover and reference information through resources, making conversations more fluid. Resources are automatically discovered, while tools are used for actions requiring user input.

**Inspired by**: Model Context Protocol (MCP) by Anthropic, exploring how remote MCP servers can provide personalized AI assistance.
