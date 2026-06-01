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

## Applying a Template

When the user selects a template (via `/statusline:setup` or `/statusline:config`), apply it by:

1. Read the template JSON from `scripts/templates/<name>.json` within this plugin directory.
2. Write the template contents to `~/.claude/statusline.config.json`.
3. Preview the result with the test command.

**Template apply example** (for "minimal" template):

```bash
# Find the plugin directory
PLUGIN_DIR="$(find ~/.claude -path '*/statusline/scripts/templates' -type d 2>/dev/null | head -1)"

# If not found via plugin install, check the source repo
if [ -z "$PLUGIN_DIR" ]; then
  PLUGIN_DIR="$HOME/project/claude-plugins/statusline/scripts/templates"
fi

# Copy template to config
cp "$PLUGIN_DIR/minimal.json" ~/.claude/statusline.config.json
```

Or use the Write tool to copy the template contents directly:

```json
// ~/.claude/statusline.config.json — written from minimal.json template
{
  "line_format": "1",
  "separator": "dot",
  "context_style": "compact",
  "icon_style": "minimal",
  "show_context": true,
  "show_rate_limits": true,
  "show_git_branch": true,
  "show_tools": false,
  "show_agents": false,
  "show_cache": false,
  "show_session": false,
  "show_reasoning": true,
  "color_style": "colorful"
}
```

### All Template Contents (inline for reference)

**detailed.json** (default):
```json
{"line_format":"3","separator":"arrow","context_style":"progress_bar","icon_style":"emoji","show_context":true,"show_rate_limits":true,"show_git_branch":true,"show_tools":true,"show_agents":true,"show_cache":true,"show_session":true,"show_reasoning":true,"color_style":"colorful"}
```

**balanced.json**:
```json
{"line_format":"2","separator":"arrow","context_style":"tokens","icon_style":"unicode","show_context":true,"show_rate_limits":true,"show_git_branch":true,"show_tools":true,"show_agents":true,"show_cache":true,"show_session":true,"show_reasoning":true,"color_style":"colorful"}
```

**minimal.json**:
```json
{"line_format":"1","separator":"dot","context_style":"compact","icon_style":"minimal","show_context":true,"show_rate_limits":true,"show_git_branch":true,"show_tools":false,"show_agents":false,"show_cache":false,"show_session":false,"show_reasoning":true,"color_style":"colorful"}
```

**monitor.json**:
```json
{"line_format":"2","separator":"pipe","context_style":"progress_bar","icon_style":"emoji","show_context":true,"show_rate_limits":true,"show_git_branch":true,"show_tools":false,"show_agents":false,"show_cache":true,"show_session":true,"show_reasoning":true,"color_style":"colorful"}
```

**developer.json**:
```json
{"line_format":"2","separator":"arrow","context_style":"tokens","icon_style":"unicode","show_context":true,"show_rate_limits":true,"show_git_branch":true,"show_tools":true,"show_agents":true,"show_cache":true,"show_session":true,"show_reasoning":true,"color_style":"colorful"}
```

**performance.json**:
```json
{"line_format":"3","separator":"arrow","context_style":"progress_bar","icon_style":"emoji","show_context":true,"show_rate_limits":true,"show_git_branch":true,"show_tools":false,"show_agents":false,"show_cache":true,"show_session":true,"show_reasoning":true,"color_style":"colorful"}
```

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

### Config Fields

| Field | Values | Default | Description |
|-------|--------|---------|-------------|
| `line_format` | `"1"`, `"2"`, `"3"` | `"3"` | Number of output lines |
| `separator` | `"arrow"`, `"pipe"`, `"dot"`, `"slash"` | `"arrow"` | Section separator character |
| `context_style` | `"progress_bar"`, `"tokens"`, `"compact"` | `"progress_bar"` | How context usage is displayed |
| `icon_style` | `"emoji"`, `"unicode"`, `"minimal"` | `"emoji"` | Icon theme for section labels |
| `show_cache` | `true/false` | `true` | Cache hit rate (Anthropic only, hidden for GLM) |
| `show_session` | `true/false` | `true` | Session duration tracker |
| `show_reasoning` | `true/false` | `true` | Effort level next to model name |
| `show_context` | `true/false` | `true` | Token count and percentage |
| `show_rate_limits` | `true/false` | `true` | API usage metrics |
| `show_git_branch` | `true/false` | `true` | Current git branch |
| `show_tools` | `true/false` | `true` | Running MCP servers |
| `show_agents` | `true/false` | `true` | Running agent count |

## Template Presets

Located in `scripts/templates/`:

| Template | Lines | Icon | Context | Best For |
|----------|-------|------|---------|----------|
| **detailed** | 3 | emoji | progress_bar | Full visibility (default) |
| **balanced** | 2 | unicode | tokens | Quick overview |
| **minimal** | 1 | none | compact | Maximum space efficiency |
| **monitor** | 2 | emoji | progress_bar | Rate-limit tracking |
| **developer** | 2 | unicode | tokens | Tools + agents + git |
| **performance** | 3 | emoji | progress_bar | Cache + context optimization |

## Files

- Commands live in `commands/`.
- Hook configuration lives in `hooks/hooks.json`.
- Runtime scripts live in `scripts/`.
- Templates live in `scripts/templates/`.
- Main renderer: `scripts/statusline.py`.
- Live script: `~/.claude/statusline-command.sh`.
