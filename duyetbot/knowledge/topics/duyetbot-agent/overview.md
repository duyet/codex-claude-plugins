# Duyetbot Agent - Autonomous Development Companion

> **Type**: project
> **Last Updated**: 2025-01-05
> **Status**: Active Development
> **Related**: [duyet-profile](../../duyet-profile.md), [writing-style](../../writing-style.md)

## Project Overview

Duyetbot is an **autonomous AI agent** designed to maximize automation and self-improvement of codebases. It combines:

1. **Transparent execution** - Every step visible via execution chains
2. **Team coordination** - Spawns specialized sub-agents for parallel work
3. **Knowledge persistence** - RAG-powered memory across sessions
4. **GitHub automation** - Automated PRs, issues, and CI/CD integration

## Architecture

```
┌─────────────────┐     ┌─────────────────┐
│  Claude Code    │────▶│  MCP Server     │
│   (duyetbot)    │     │  (Cloudflare)   │
└─────────────────┘     └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌─────────────────┐
│  Knowledge Base │     │  GitHub API     │
│  (local files)  │     │  Automation     │
└─────────────────┘     └─────────────────┘
```

## Components

### 1. Claude Code Plugin (`duyetbot/`)

**Location**: `/duyetbot/`

**Agent Definition** (`agents/duyetbot.md`):
- Model: Opus (primary), Sonnet, Haiku (for sub-tasks)
- Personality: Friendly, transparent, evidence-based
- Execution: Iterative loops (UNDERSTAND → PLAN → EXECUTE → VERIFY)

**Commands**:
| Command | Purpose |
|---------|---------|
| `/duyetbot [task]` | Main interaction |
| `/duyetbot:think [problem]` | Deep structured analysis |
| `/duyetbot:loop [task]` | Iterate until complete |
| `/duyetbot:spawn [task]` | Delegate to team agents |
| `/duyetbot:orchestrate [task]` | Coordinate parallel workstreams |
| `/learn <url|topic>` | Learn about @duyet and update knowledge |

### 2. MCP Server (`duyetbot-mcp/`)

**Location**: `/duyetbot-mcp/`

**Tech Stack**:
- Runtime: Cloudflare Workers
- Database: D1 (SQLite)
- Language: TypeScript
- Deployment: Wrangler CLI

**Capabilities**:

**GitHub Tools**:
- `github_whoami` - Get authenticated user info
- `github_list_repos` - List repositories
- `github_create_issue` - Create issues
- `github_create_pr` - Create pull requests
- `github_get_pr` - Get PR details
- `github_merge_pr` - Merge PRs
- `github_list_actions` - List workflow runs
- `github_trigger_action` - Trigger workflows
- `github_search_code` - Search code across repos

**Memory Tools**:
- `memory_store` - Store information persistently
- `memory_recall` - Retrieve stored memory
- `memory_list` - List all memories
- `memory_forget` - Delete memory
- `memory_search` - Search by content

**Knowledge Tools** (RAG):
- `knowledge_search` - Semantic search
- `knowledge_retrieve` - Retrieve by ID
- `knowledge_ingest` - Ingest documents
- `knowledge_embed` - Generate embeddings
- `knowledge_context` - Get relevant context
- `rag_query` - Full RAG with prompt formatting

### 3. Team Agents Integration

**Location**: `/team-agents/`

**Available Agents**:
| Agent | Model | Use Case |
|-------|-------|----------|
| `@leader` | opus | Complex decomposition, coordination |
| `@senior-engineer` | sonnet | Architectural decisions |
| `@junior-engineer` | haiku | Fast execution of clear tasks |

**Orchestration Patterns**:

**Fan-Out** (Parallel independent tasks):
```
├── @junior-engineer: Frontend component
├── @senior-engineer: Backend API
└── @junior-engineer: Database schema
```

**Pipeline** (Sequential dependent stages):
```
Research → Design → Implement → Test
```

**Map-Reduce** (Distribute then aggregate):
```
Map: Analyze each module
Reduce: Synthesize findings
```

## Knowledge Base

**Location**: `/duyetbot/knowledge/`

**Structure**:
```
knowledge/
├── duyet-profile.md       # Profile, work experience, skills
├── writing-style.md       # Writing patterns for duyetbot
├── blog-archive.md        # 299+ blog posts by topic
├── structure.md           # Knowledge organization
└── topics/                # Nested topic-based knowledge
    ├── clickhouse/
    ├── rust/
    └── duyetbot-agent/    # This file
```

**Data Sources**:
- https://duyet.net/llms.txt - Profile
- https://cv.duyet.net/llms.txt - Resume
- https://blog.duyet.net/llms.txt - Blog posts
- https://github.com/duyet - Repositories
- https://x.com/_duyet - Thoughts and updates

## Execution Philosophy

### Loop-Based Simplicity
```
UNDERSTAND → PLAN → EXECUTE → VERIFY → (repeat)
```

Each iteration:
1. **Understand** - Current state, goal, blockers
2. **Plan** - Single next action, why this action
3. **Execute** - Take action, one change only
4. **Verify** - Validate result, tests pass

### Transparency
Every step shows in execution chain:
```
[1] Read config.ts → Found db settings
[2] Grep "connection" → 3 refs found
[3] Edit db.ts:45 → Added timeout
[4] Test → Passing

─── duyetbot ── complete ─────
```

### Quality Gates
Before marking complete:
- [ ] No errors/warnings
- [ ] Tests pass
- [ ] Lint clean
- [ ] Changes focused
- [ ] No shortcuts

## Automation Capabilities

### Self-Improvement Loops
- **Codebase Analysis** - Automated code reviews and refactoring suggestions
- **Pattern Detection** - Identify and apply consistent patterns
- **Documentation** - Auto-generate docs from code
- **Testing** - Expand test coverage automatically

### GitHub Automation
- **PR Management** - Create, review, merge PRs
- **Issue Tracking** - Auto-create issues from code analysis
- **CI/CD** - Trigger and monitor workflows
- **Code Search** - Find patterns across repositories

### Knowledge Management
- **Continuous Learning** - `/learn` command updates knowledge
- **Semantic Search** - RAG-powered context retrieval
- **Cross-Session Memory** - Persistent context via D1
- **Writing Style Mirror** - Matches @duyet's communication style

## Personality Traits

**Mirrors @duyet's style**:
- Friendly but focused
- Evidence-based (uses benchmarks, metrics)
- Visual (ASCII diagrams for clarity)
- Humble (admits limits, asks for feedback)
- Transparent (shows work, explains reasoning)

**Say**:
- "Let me break this down..."
- "Based on my analysis..."
- "Here's what I found..."
- "I hope this helps."

**Never Say**:
- Overly enthusiastic marketing language
- "This is the best/only way"
- Unsubstantiated claims
- Unnecessary emojis

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.3.0 | 2025-01-05 | Knowledge base, ASCII visualizations, friendly style |
| 1.2.0 | 2025-01-04 | Team-agents integration, orchestration patterns |
| 1.1.0 | 2025-01-03 | MCP server, knowledge base integration |
| 1.0.0 | 2025-01-01 | Initial release with core duyetbot functionality |

## Future Roadmap

**Planned Features**:
- [ ] OAuth GitHub integration (vs personal access tokens)
- [ ] Multi-user support with D1 database
- [ ] Advanced RAG with vector embeddings
- [ ] Autonomous bug detection and fixing
- [ ] Self-healing codebase patterns
- [ ] Integration with more MCP servers

**Technical Debt**:
- None - early development, doing it RIGHT from the start

## Related Projects

| Project | URL | Description |
|---------|-----|-------------|
| duyetbot-agent | https://github.com/duyet/duyetbot-agent | Original standalone implementation |
| MCP Servers | https://mcp.duyet.net | Model Context Protocol tools |
| Insights | https://insights.duyet.net | Analytics dashboard |

## Commit Convention

```bash
# Format
feat(duyetbot): add new feature
fix(duyetbot): fix bug
docs(duyetbot): update documentation

# Co-author (always)
Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>
```

---

**Design Principle**: Transparency over magic. Craftsmanship over speed. Evidence over assumptions.

**Inspired by**: [duyetbot-agent](https://github.com/duyet/duyetbot-agent) - Original standalone implementation.
