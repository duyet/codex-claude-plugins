# Duyetbot Plugin

A pragmatic software development companion for Claude Code with knowledge about @duyet and autonomous overnight execution capability.

> **Transparency over magic. Craftsmanship over speed. Evidence over assumptions.**

## Philosophy

Based on [duyetbot-agent](https://github.com/duyet/duyetbot-agent):

1. **Loop-based simplicity** - Iterative cycles, not complex routing
2. **Transparency** - Every step visible via execution chain
3. **Engineering discipline** - No shortcuts, no hacks
4. **Friendly & helpful** - Approachable with visual explanations

## Personality

- **Friendly but focused** - Approachable while staying productive
- **Transparent** - Shows work, explains reasoning
- **Evidence-based** - Uses benchmarks, metrics when relevant
- **Visual** - Simple ASCII diagrams for clarity
- **Humble** - Admits limits, asks for feedback

## Commands

| Command | Description |
|---------|-------------|
| `/duyetbot [task]` | Main interaction |
| `/duyetbot:think [problem]` | Deep structured analysis |
| `/duyetbot:loop [task] [--promise TEXT] [--max N]` | Autonomous iterative execution with overnight capability |
| `/duyetbot:spawn [task]` | Delegate to team agents |
| `/duyetbot:orchestrate [task]` | Coordinate parallel workstreams |
| `/learn <url|topic>` | Learn about @duyet and update knowledge |

## Usage

### Basic
```
/duyetbot Fix the auth bug in auth.ts
```

### Autonomous Loop (Overnight Execution)
```
# Basic autonomous loop
/duyetbot:loop Implement user authentication

# With completion promise (recommended for overnight)
/duyetbot:loop Fix the bug --promise TESTS_PASS

# Max iterations for safety
/duyetbot:loop Refactor database --max 50 --promise REFACTOR_COMPLETE
```

**How it works:**
1. Activates Ralph Wiggum loop with automatic stop-hook
2. Iterates through: UNDERSTAND → PLAN → EXECUTE → VERIFY
3. Continues overnight while human is asleep
4. Completes when `<promise>TAG</promise>` is output
5. Safety: Circuit breaker stops on stagnation (3 no-progress) or errors (5 consecutive)

### Deep Analysis
```
/duyetbot:think Why is API response time increasing?
```

### Team Coordination
```
/duyetbot:spawn Implement the frontend component
/duyetbot:orchestrate Build full feature with parallel execution
```

### Learn About @duyet
```
/learn https://blog.duyet.net/2024/11/clickhouse-rust-udf.html
/learn What is Duyet's experience with Rust?
```

## Output Style

Duyetbot shows execution chain with visual clarity:

```
[1] Read config.ts → Found db settings
[2] Grep "connection" → 3 refs found
[3] Edit db.ts:45 → Added timeout
[4] Test → Passing

─── duyetbot ── complete ─────
```

### ASCII Visualizations

Duyetbot uses simple ASCII diagrams:

**Architecture:**
```
┌─────────┐     ┌─────────┐
│ Source  │────▶│ ClickHouse│
└─────────┘     └─────────┘
```

**Data Flow:**
```
Kafka → Raw Events → Transform → Warehouse
          │              │
          ▼              ▼
      Materialized   Aggregated
         Views         Tables
```

**Comparisons:**
```
┌────────────┬─────────┬─────────┐
│ Metric     │ Python  │ Rust    │
├────────────┼─────────┼─────────┤
│ Pods       │ 1000    │ 50      │
│ Memory     │ 32GB    │ 8GB     │
└────────────┴─────────┴─────────┘
```

## Knowledge Base

Duyetbot has access to @duyet's knowledge:

| File | Content |
|------|---------|
| `knowledge/duyet-profile.md` | Profile, work experience, skills |
| `knowledge/writing-style.md` | Writing patterns to mirror |
| `knowledge/blog-archive.md` | Blog posts by topic |
| `knowledge/structure.md` | Knowledge organization |
| `knowledge/topics/` | Topic-based knowledge (clickhouse-monitoring, duyet-mcp-server, duyetbot-agent) |

### Remote MCP Server

Duyetbot connects to **https://mcp.duyet.net/** for live information about @duyet:

- `duyet://about` - Basic information
- `duyet://cv/{format}` - Resume/CV
- `duyet://blog/posts/{limit}` - Latest blog posts
- `duyet://github-activity` - Recent contributions

### Updating Knowledge

```bash
# Fetch latest from llms.txt sources
./scripts/fetch-duyet-data.sh

# Add new knowledge via command
/learn <url|topic|question>

# Commit with semantic commit
git add knowledge/
git commit -m "feat(duyetbot): update duyet profile knowledge

Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>"
```

## Skills

| Skill | Purpose |
|-------|---------|
| `engineering-discipline` | Quality gates, no shortcuts |
| `transparency` | Execution chain visibility |
| `task-loop` | Iterative methodology |
| `team-coordination` | Spawn and coordinate agents |
| `ralph-integration` | Autonomous overnight execution via Ralph Wiggum loop |
| `duyet-knowledge` | Maintain @duyet knowledge base |

## Team Integration

Duyetbot can spawn **@team-agents**:

| Agent | Model | Use For |
|-------|-------|---------|
| `@leader` | opus | Complex decomposition |
| `@senior-engineer` | sonnet | Architectural decisions |
| `@junior-engineer` | haiku | Fast execution |

And use **@orchestration** patterns:
- **Fan-Out** - Parallel independent tasks
- **Pipeline** - Sequential dependent stages
- **Map-Reduce** - Distribute then aggregate

## MCP Integration

- **memory** - Persistent cross-session context
- **research** - Web search and synthesis
- **duyet-mcp-server** - https://mcp.duyet.net/ for live @duyet information

## When to Use

**Good for:**
- Methodical problem-solving
- Quality-focused implementations
- Debugging with visible reasoning
- Questions about @duyet
- Sustainable code

**Not for:**
- Quick one-liners
- Creative exploration
- Speed > quality tasks

## Structure

```
duyetbot/
├── .claude-plugin/
│   └── plugin.json          # Manifest (version 1.4.0)
├── .mcp.json                # MCP server configuration
├── hooks/
│   └── hooks.json           # Ralph Wiggum stop-hook integration
├── agents/
│   └── duyetbot.md          # Agent definition with Ralph integration
├── commands/
│   ├── duyetbot.md
│   ├── think.md
│   ├── loop.md              # Updated: invokes Ralph setup
│   ├── spawn.md
│   ├── orchestrate.md
│   └── learn.md
├── skills/
│   ├── engineering-discipline/
│   ├── transparency/
│   ├── task-loop/
│   ├── team-coordination/
│   ├── ralph-integration/   # NEW: Autonomous loop best practices
│   └── duyet-knowledge/
├── knowledge/
│   ├── duyet-profile.md
│   ├── writing-style.md
│   ├── blog-archive.md
│   ├── structure.md
│   └── topics/
│       ├── clickhouse-monitoring/
│       ├── duyet-mcp-server/
│       └── duyetbot-agent/
├── scripts/
│   └── fetch-duyet-data.sh
└── README.md
```

## Changelog

### 1.5.0
- Integrate Ralph Wiggum loop for autonomous overnight execution
- Add `ralph-integration` skill with best practices
- Add hooks/ for Ralph stop-hook integration
- Update `/loop` command with `--promise` and `--max` support
- Agent can now iterate overnight while human sleeps
- Circuit breaker safety (no progress, error detection)

### 1.4.0
- Consolidate knowledge base structure (remove empty nested directory)
- Update knowledge/topics to actual: clickhouse-monitoring, duyet-mcp-server, duyetbot-agent
- Gitignore `_raw_data.txt` (auto-generated fetch output)

### 1.3.0
- Add @duyet knowledge base (profile, blog, writing style)
- Add `/learn` command for knowledge acquisition
- Add ASCII visualization patterns
- Friendly response style (mirrors @duyet's writing)
- Nested knowledge structure in `knowledge/topics/`

### 1.2.0
- Add team-agents integration (@leader, @senior-engineer, @junior-engineer)
- Add orchestration patterns (fan-out, pipeline, map-reduce)
- New commands: spawn, orchestrate
- New skill: team-coordination

### 1.0.0
- Initial release
- Agent with opus model
- Commands: duyetbot, think, loop
- Skills: engineering-discipline, transparency, task-loop
- MCP: memory, research

## Credits

Inspired by [duyetbot-agent](https://github.com/duyet/duyetbot-agent) - the original duyetbot implementation.
