---
name: statusline
description: Use when configuring, previewing, troubleshooting, or disabling the Claude Code statusline plugin.
---

# Statusline

Use this skill to help configure and troubleshoot the statusline plugin.

## Workflow

1. Inspect the existing statusline config and scripts before changing settings.
2. For setup, choose layout, visible sections, context display style, icon theme, and separator.
3. Update the user's Claude settings only when requested or clearly part of setup.
4. Preview the generated statusline command with representative session input.
5. For troubleshooting, check provider detection, rate-limit fields, and empty-section hiding.

## Dual-Provider Support

The statusline automatically adapts to two model providers:

| Feature | Anthropic Claude | z.ai GLM |
|---------|-----------------|----------|
| **Model name** | `opus-4.8[200k]` | `glm-5.1[1m]` |
| **Rate limits** | 5h/7d from JSON payload | May be empty (n/a) |
| **Cache stats** | ✅ Real prompt caching data | ❌ Hidden (proxy artifacts) |
| **Context window** | From JSON payload | From JSON payload |
| **Effort level** | low/medium/high/max | low/medium/high/max |
| **Session duration** | File-based tracker | File-based tracker |
| **Tools/agents** | Process detection | Process detection |

## Configuration

Config file: `~/.claude/statusline.config.json`

```json
{
  "line_format": "3",
  "separator": "arrow",
  "context_style": "progress_bar",
  "icon_style": "emoji",
  "show_context": true,
  "show_rate_limits": true,
  "show_git_branch": true,
  "show_tools": true,
  "show_agents": true,
  "show_cache": true,
  "show_session": true,
  "show_reasoning": true,
  "color_style": "colorful"
}
```

### Config Fields

| Field | Values | Description |
|-------|--------|-------------|
| `line_format` | `"1"`, `"2"`, `"3"` | Number of output lines |
| `separator` | `"arrow"`, `"pipe"`, `"dot"`, `"slash"` | Section separator character |
| `context_style` | `"progress_bar"`, `"tokens"`, `"compact"` | How context usage is displayed |
| `icon_style` | `"emoji"`, `"unicode"`, `"minimal"` | Icon theme for section labels |
| `show_cache` | `true/false` | Cache hit rate (Anthropic only, hidden for GLM) |
| `show_session` | `true/false` | Session duration tracker |
| `show_reasoning` | `true/false` | Effort level next to model name |
| `show_*` | `true/false` | Toggle individual sections |

## Template Presets

Located in `scripts/templates/`:

| Template | Lines | Icon | Best For |
|----------|-------|------|----------|
| **detailed** | 3 | emoji | Full visibility (default) |
| **balanced** | 2 | unicode | Quick overview |
| **minimal** | 1 | none | Maximum space efficiency |
| **monitor** | 2 | emoji | Rate-limit tracking |
| **developer** | 2 | unicode | Tools + agents + git |
| **performance** | 3 | emoji | Cache + context optimization |

## Files

- Commands live in `commands/`.
- Hook configuration lives in `hooks/hooks.json`.
- Runtime scripts live in `scripts/`.
- Templates live in `scripts/templates/`.
- Main renderer: `scripts/statusline.py`.
- Live script: `~/.claude/statusline-command.sh`.
