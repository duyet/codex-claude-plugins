# Statusline

A Claude Code plugin that provides real-time visibility into your coding session. Track context usage, active tools, running agents, and task progress at a glance.

**Inspired by [claude-hud](https://github.com/jarrodwatts/claude-hud) — enhanced for the claude-plugins ecosystem.**

## Overview

Statusline keeps you informed about what's happening during your Claude Code session without interrupting your workflow. Get immediate feedback on:

| Metric | Purpose |
|--------|---------|
| **Context Health** | Know exactly how much of your token window is in use |
| **Active Tools** | See which tools Claude is using right now |
| **Agent Tracking** | Monitor running agents and their execution time |
| **Task Progress** | Track todo completion in real-time |
| **API Rate Limits** | Monitor usage across Anthropic (5h/7d) or z.ai GLM (5h) |

## Installation

Add the plugin to your Claude Code instance:

```bash
/plugin install statusline
```

Then enable monitoring:

```bash
/statusline:enable
```

## Quick Start

### View Current Status
Check your session metrics anytime:
```bash
/statusline:status
```

### Continuous Monitoring
Enable automatic status updates (5-second interval by default):
```bash
/statusline:enable
```

### Custom Update Interval
Set a custom monitoring interval (in seconds):
```bash
/statusline:enable 10
```

### Stop Monitoring
Pause background updates while keeping the plugin active:
```bash
/statusline:disable
```

## Commands

| Command | Purpose |
|---------|---------|
| `/statusline:status` | Display current session metrics immediately |
| `/statusline:enable [interval]` | Enable real-time monitoring with optional custom interval |
| `/statusline:disable` | Pause automatic status updates |

## What Each Metric Shows

### Context Window
A visual progress bar showing your token usage with color coding:
- 🟢 Green: 0-60% — Comfortable usage
- 🟡 Yellow: 60-85% — Getting full
- 🔴 Red: 85%+ — Approaching limit

Example:
```
Context: ████░░░░░░ 45% (90,000 / 200,000 tokens)
```

### Compact One-Line Format
All metrics displayed in a single line with empty values hidden:
```
📊 🟡 45% | Model: Opus 4.5 | 12m 34s | Tools: Glob×4 Bash×8 Read×12 | Agents: Explore(12s) | Tasks: 🔄 1 ⏳ 2 ✓ 5 | Context: 3 prompts
```

**Smart hiding:**
- ✓ No "None" values displayed
- ✓ Empty collections omitted (no agents/tools if zero)
- ✓ Claude Code version hidden
- ✓ Context shows matching system prompts and tools

### API Rate Limits

The plugin automatically detects your model provider and shows appropriate usage metrics:

**Anthropic Models** (default, Claude, Opus, Sonnet, etc.):
```
5h: 42% | 7d: 28%
```
- Shows 5-hour and 7-day utilization percentages
- Requires Claude Code OAuth credentials

**z.ai GLM Models** (glm-4, glm-4.7, glm-flash, glm-plus, etc.):
```
z.ai: 15%
```
- Shows token quota percentage (5h equivalent)
- Requires z.ai API key from opencode auth file

#### z.ai Setup

For GLM models, the plugin tries multiple credential sources in order:

**1. macOS Keychain** (macOS only - highest priority)
- Looks for keychain entries named: `z.ai`, `zai`, `opencode`, or `zai-coding-plan`
- Parses JSON or uses raw value as API key

**2. Environment Variables** (cross-platform)
- `ZAI_API_KEY` - Generic z.ai API key
- `ZAI_CODING_PLAN_KEY` - Coding plan specific key

**3. Configuration Files** (cross-platform fallback)
Tries these paths in order:
```
~/.local/share/opencode/auth.json    # Linux/Unix XDG standard
~/.config/opencode/auth.json         # Alternative XDG location
~/.opencode/auth.json                # Legacy location
~/.zai/auth.json                     # z.ai specific
```

Example auth file structure:
```json
{
  "zai-coding-plan": {
    "key": "your-zai-api-key-here"
  }
}
```

Alternative JSON structures supported:
```json
{"zai": {"key": "..."}}
{"apiKey": "..."}
{"key": "..."}
```

**Recommended Setup by Platform:**

| Platform | Recommended Method |
|----------|-------------------|
| macOS | Keychain: `security add-generic-password -s "z.ai" -w "your-key"` |
| Linux | File: `~/.local/share/opencode/auth.json` |
| Windows | File: `%USERPROFILE%\.local\share\opencode\auth.json` |

The provider is automatically detected from the `CLAUDE_MODEL` environment variable. Any model starting with `glm-` will use the z.ai API.

## Features

✅ **Real-time Updates** — Status refreshes automatically at your chosen interval

✅ **Non-intrusive** — Displays without interrupting your workflow

✅ **Customizable** — Set monitoring frequency that works for you

✅ **Manual Control** — Check status anytime with `/statusline:status`

✅ **Plugin Integration** — Works seamlessly with other Claude Code plugins

✅ **Token Awareness** — Shows actual token counts from Claude Code

## Use Cases

- **Monitor Context** — Know when you're approaching context limits before running out
- **Track Progress** — See how many tasks have been completed in your session
- **Debug Workflows** — Understand tool and agent activity during complex operations
- **Optimize Sessions** — Identify bottlenecks and adjust your approach
- **Stay Informed** — Keep awareness of background operations

## How It Works

The plugin reads session data from Claude Code's internal state and displays aggregated metrics about:

1. **Token Usage** — Real counts from Claude Code's context window
2. **Tool Activity** — Tracked from tool invocations in your session
3. **Agent Operations** — Monitored from subagent execution
4. **Task Management** — Read from your TodoWrite operations

Updates happen at a regular interval (default 5 seconds) without blocking your work.

## Requirements

- Claude Code v1.0.80+
- Node.js 18+ or Bun (if running custom build)

## Inspiration

This plugin is inspired by [claude-hud](https://github.com/jarrodwatts/claude-hud) but optimized for the claude-plugins marketplace with enhanced integration and customization options.

## Development

Session Monitor is built with:
- TypeScript for type safety
- Claude Code's native APIs
- Minimal dependencies for quick performance

### Source Structure

```
session-monitor/
├── .claude-plugin/
│   └── plugin.json         # Plugin manifest
├── commands/
│   ├── status.md          # Status command documentation
│   ├── enable.md          # Enable command documentation
│   └── disable.md         # Disable command documentation
└── README.md              # This file
```

## Contributing

Found an issue or have a feature idea? Contributions are welcome! This plugin is part of the [claude-plugins](https://github.com/duyet/claude-plugins) marketplace.

## License

MIT License — see LICENSE file

## Related Plugins

- **[team-agents](../team-agents)** — Coordinated parallel task execution
- **[commit](../commit)** — Semantic Git commit automation

---

**Questions?** Open an issue on the [claude-plugins repository](https://github.com/duyet/claude-plugins/issues)
