# Duyetbot Plugin

A pragmatic software development companion for Claude Code.

> **Transparency over magic. Craftsmanship over speed. Evidence over assumptions.**

## Philosophy

Based on [duyetbot-agent](https://github.com/duyet/duyetbot-agent):

1. **Loop-based simplicity** - Iterative cycles, not complex routing
2. **Transparency** - Every step visible via execution chain
3. **Engineering discipline** - No shortcuts, no hacks

## Personality

- Direct. No fluff.
- Shows execution chain.
- Acknowledges limitations.
- Results over abstractions.

## Commands

| Command | Description |
|---------|-------------|
| `/duyetbot [task]` | Main interaction |
| `/duyetbot:think [problem]` | Deep structured analysis |
| `/duyetbot:loop [task]` | Iterate until complete |

## Usage

### Basic
```
/duyetbot Fix the auth bug in auth.ts
```

### Deep Analysis
```
/duyetbot:think Why is API response time increasing?
```

### Iterative Execution
```
/duyetbot:loop Implement user registration with validation and tests
```

## Output Style

Duyetbot shows execution chain:

```
[1] Read config.ts → Found db settings
[2] Grep "connection" → 3 refs found
[3] Edit db.ts:45 → Added timeout
[4] Test → Passing

─── duyetbot ── complete ─────
```

## Skills

| Skill | Purpose |
|-------|---------|
| `engineering-discipline` | Quality gates, no shortcuts |
| `transparency` | Execution chain visibility |
| `task-loop` | Iterative methodology |

## MCP Integration

- **memory** - Persistent cross-session context
- **research** - Web search and synthesis

## When to Use

**Good for:**
- Methodical problem-solving
- Quality-focused implementations
- Debugging with visible reasoning
- Sustainable code

**Not for:**
- Quick one-liners
- Creative exploration
- Speed > quality tasks

## Structure

```
duyetbot/
├── .claude-plugin/
│   └── plugin.json
├── .mcp.json
├── agents/
│   └── duyetbot.md
├── commands/
│   ├── duyetbot.md
│   ├── think.md
│   └── loop.md
├── skills/
│   ├── engineering-discipline/
│   ├── transparency/
│   └── task-loop/
└── README.md
```

## Changelog

### 1.0.0
- Initial release
- Agent with opus model
- Commands: duyetbot, think, loop
- Skills: engineering-discipline, transparency, task-loop
- MCP: memory, research

## Credits

Inspired by [duyetbot-agent](https://github.com/duyet/duyetbot-agent) - the original duyetbot implementation.
