# /statusline:config

Configure the statusline display format and preferences.

## Action Required

When this command is invoked, ask the user what they want to change using AskUserQuestion:

### Question: What to Configure

**Header**: "Config"
**Question**: "What would you like to configure?"
**Options**:
1. **Layout** — Number of lines (1/2/3)
2. **Sections** — Which info to show/hide
3. **Context style** — How context usage is displayed
4. **Reset to defaults**

### If Layout selected:

**Header**: "Layout"
**Question**: "How many lines should the statusline display?"
**Options**:
1. **1 line (Compact)** — `dir │ model │ ctx% │ rate │ tasks`
2. **2 lines** — Line 1: location/model, Line 2: all metrics
3. **3 lines** — Full layout with progress bar, token details, activity

### If Sections selected:

**Header**: "Sections"
**Question**: "Which sections should be visible?"
**multiSelect**: true
**Options**:
1. **Context usage** — Token count and percentage
2. **Rate limits** — API usage percentages and reset timers
3. **Git branch** — Current branch name
4. **Active tools** — Running MCP servers

### If Context style selected:

**Header**: "Context"
**Question**: "How should context usage be displayed?"
**Options**:
1. **Compact** — `ctx: 21%`
2. **With tokens** — `ctx: 21% 43k/200k`
3. **Progress bar** — `██░░░░░░░░ 21% (43k/200k)`

### Save Configuration

Update `~/.claude/statusline.config.json` with the new values. Keep existing values for any settings not changed:

```json
{
  "line_format": "2",
  "show_context": true,
  "show_rate_limits": true,
  "show_git_branch": true,
  "show_tools": true,
  "context_style": "tokens",
  "separator": "pipe"
}
```

### Confirm

Output:
```
✓ Statusline updated: [setting changed]
  Config saved to ~/.claude/statusline.config.json
```

## Example Outputs by Provider

**Anthropic** (2-line, tokens style):
```
claude-plugins (master) │ claude-opus-4-5-20251101 │ v2.0.76
ctx: 21% 43k/200k │ 5h: 42% │ 7d: 28% │ Tasks: 2/5
```

**z.ai GLM** (2-line, tokens style):
```
claude-plugins (master) │ glm-5.1 │ v2.0.76
ctx: 21% 43k/200k │ tokens: 15% │ tools: 11% (883 left) Web:35 ZRead:82
```

**Anthropic** (3-line, progress_bar style):
```
claude-plugins (master) │ claude-opus-4-5-20251101 │ v2.0.76 │ explanatory
ctx: ██░░░░░░░░ 21% (43k/200k tokens) │ 5h: 42% │ 7d: 28%
Tools: Seq Ctx7 │ Agents: 2 active │ Tasks: 1/5 (20%)
```

## Related Commands

- `/statusline:setup` — Full interactive setup wizard
- `/statusline:status` — View current metrics
- `/statusline:disable` — Disable monitoring
