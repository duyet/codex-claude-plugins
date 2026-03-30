# /statusline:config

Configure the statusline display format.

## Action Required

When this command is invoked, you MUST use the AskUserQuestion tool to ask:

### Question: Line Format

Ask the user which display format they prefer:

**Header**: "Lines"
**Question**: "How many lines should the statusline display?"

**Options**:
1. **1 line (Compact)** — `dir (branch) │ Model │ Ctx% │ Rate │ Tasks`
2. **2 lines** — Line 1: location/model, Line 2: all metrics
3. **3 lines (Default)** — Full layout with progress bar, token details, and activity

### Save Configuration

After the user answers, save their choice to `~/.claude/statusline.config.json`:

```json
{
  "line_format": "1"
}
```

Use values: `"1"`, `"2"`, or `"3"`

### Confirm

Output:
```
✓ Statusline configured: [N]-line format
  Config saved to ~/.claude/statusline.config.json
```

## Example Outputs

**Anthropic** (Claude, Opus, Sonnet):

1-line:
```
claude-plugins (master) │ Opus 4.5 │ ctx: 21% 43k/200k │ 5h: 42% 7d: 28%
```

2-line:
```
claude-plugins (master) │ Opus 4.5 │ v2.0.76
ctx: 21% 43k/200k │ 5h: 42% │ 7d: 28% │ Tasks: 2/5 (40%)
```

3-line:
```
claude-plugins (master) │ Opus 4.5 │ v2.0.76 │ explanatory
ctx: ██░░░░░░░░ 21% (43k/200k tokens) │ 5h: 42% │ 7d: 28%
Tools: Seq Ctx7 │ Agents: 2 active │ Tasks: 1/5 (20%)
```

**z.ai GLM** (glm-5.1, glm-4, etc.):

1-line:
```
claude-plugins (master) │ GLM 5.1 │ ctx: 21% 43k/200k │ tokens: 15% │ tools: 11% (883 left)
```

2-line:
```
claude-plugins (master) │ GLM 5.1 │ v2.0.76
ctx: 21% 43k/200k │ tokens: 15% │ tools: 11% (883 left) Web:35 ZRead:82
```

3-line:
```
claude-plugins (master) │ GLM 5.1 │ v2.0.76 │ explanatory
ctx: ██░░░░░░░░ 21% (43k/200k tokens) │ tokens: 15% │ tools: 11% (883 left) Web:35 ZRead:82
Tools: Seq Ctx7 │ Agents: 1 active
```

**Note**: Empty values are automatically hidden (no "None", no "0%", no "No tasks").
Provider is auto-detected from the model name.

## Related Commands

- `/statusline:status` — View current metrics
- `/statusline:disable` — Disable monitoring
