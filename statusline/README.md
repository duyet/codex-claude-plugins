# Statusline

A Claude Code plugin that provides real-time visibility into your coding session. Track context usage, API rate limits, active tools, running agents, and task progress at a glance.

**Multi-provider support:** Automatically detects Anthropic vs z.ai GLM models and shows provider-specific metrics.

## Overview

Statusline keeps you informed about what's happening during your Claude Code session without interrupting your workflow.

| Metric | Anthropic | z.ai GLM |
|--------|-----------|----------|
| **Context Health** | Token count, percentage, progress bar | Token count, percentage, progress bar |
| **Rate Limits** | 5h utilization, 7d utilization | Token quota %, monthly tools % |
| **Tool Breakdown** | — | Search, Web, ZRead usage counts |
| **Active Tools** | MCP server detection | MCP server detection |
| **Agent Tracking** | Running agents and count | Running agents and count |
| **Task Progress** | Todo completion tracking | Todo completion tracking |

## Installation

Add the plugin to your Claude Code instance:

```bash
/plugin install statusline
```

## Commands

| Command | Purpose |
|---------|---------|
| `/statusline:status` | Display current session metrics |
| `/statusline:config` | Configure display format (1/2/3 lines) |
| `/statusline:setup` | Interactive setup wizard |
| `/statusline:disable` | Pause automatic status updates |

## Provider Auto-Detection

The plugin automatically detects your model provider:

- **Anthropic** — Any Claude model (claude-opus, claude-sonnet, claude-haiku, etc.)
- **z.ai GLM** — Any model starting with `glm-` (glm-5.1, glm-4, glm-flash, etc.)

Detection happens from the model ID injected by Claude Code into the statusline JSON input.

## Display Formats

### 1-line (Compact)

Everything on a single line:
```
claude-plugins (master) │ GLM 5.1 │ ctx: 21% 43k/200k │ tokens: 15% │ tools: 11% (883 left)
```

### 2-line (Default)

Location + model on line 1, all metrics on line 2:
```
claude-plugins (master) │ GLM 5.1 │ v2.0.76
ctx: 21% 43k/200k │ tokens: 15% │ tools: 11% (883 left) Web:35 ZRead:82
```

### 3-line (Detailed)

Full layout with progress bar and token details:
```
claude-plugins (master) │ GLM 5.1 │ v2.0.76 │ explanatory
ctx: ██░░░░░░░░ 21% (43k/200k tokens) │ tokens: 15% │ tools: 11% (883 left) Web:35 ZRead:82
Tools: Seq Ctx7 │ Agents: 2 active │ Tasks: 3/5 (60%)
```

## Context Health

Color-coded progress indicator:
- 🟢 Green: 0-60% — Comfortable
- 🟡 Yellow: 60-85% — Getting full
- 🔴 Red: 85%+ — Approaching limit

The 3-line format includes a visual progress bar: `███░░░░░░░ 30%`

## API Rate Limits

### Anthropic

Shows 5-hour and 7-day utilization percentages:
```
5h: 42% │ 7d: 28%
```

Requires Claude Code OAuth credentials (auto-detected from keychain or config files).

### z.ai GLM

Shows token quota and monthly tool usage:
```
tokens: 15% │ tools: 11% (883 left) Web:35 ZRead:82
```

- **tokens** — 5-hour rolling window (equivalent to Anthropic's 5h)
- **tools** — Monthly tool quota with remaining count
- **Per-tool breakdown** — Search, Web-reader, ZRead usage

#### z.ai Credential Sources (tried in order)

1. **macOS Keychain** — `security add-generic-password -s "z.ai" -w "your-key"`
2. **Environment** — `ZAI_API_KEY` or `ZAI_CODING_PLAN_KEY`
3. **Config files** — `~/.local/share/opencode/auth.json` or `~/.zai/auth.json`

## Smart Hiding

Empty values are never shown:
- No "None", "0%", or "No tasks" clutter
- Tool/agent sections hidden when inactive
- Per-tool breakdown only shown when usage > 0
- Output style hidden when set to "default"

## Requirements

- Claude Code v1.0.80+
- Node.js 18+ (for TypeScript CLI)
- `jq` (for Bash statusline script)

## Contributing

Found an issue or have a feature idea? Open an issue on the [claude-plugins repository](https://github.com/duyet/claude-plugins/issues).

## License

MIT License
