# /statusline:setup

Interactive setup wizard that configures and generates your personalized statusline.

## Action Required

When this command is invoked, conduct an interview using AskUserQuestion, then generate the statusline script.

### Interview Questions

Use AskUserQuestion to ask these questions (up to 4 at a time):

#### Q1: Line Format
**Header**: "Layout"
**Question**: "How many lines should the statusline display?"
**Options**:
1. **1 line (Compact)** — Everything on one line
2. **2 lines** — Location/model + metrics (Recommended)
3. **3 lines** — Full layout with progress bar and token details

#### Q2: Information Sections
**Header**: "Show"
**Question**: "What information do you want to see?"
**multiSelect**: true
**Options**:
1. **Context usage** — Token count, percentage, progress bar
2. **Rate limits** — API usage (5h/7d for Anthropic, tokens/tools for GLM)
3. **Git branch** — Current branch name
4. **Active tools** — Running MCP servers and tool counts

#### Q3: Context Display Style
**Header**: "Context"
**Question**: "How should context usage be displayed?"
**Options**:
1. **Compact** — Just percentage: `ctx: 21%`
2. **With tokens** — Percentage + token counts: `ctx: 21% 43k/200k`
3. **Progress bar** — Visual bar + details: `██░░ 21% (43k/200k)`

#### Q4: Separator Style
**Header**: "Separator"
**Question**: "What separator style between sections?"
**Options**:
1. **Pipe** — `│` vertical bar (Recommended)
2. **Slash** — `/` forward slash
3. **Dot** — `·` middle dot
4. **Arrow** — `→` arrow

### Generate Statusline Script

Based on answers, update `~/.claude/statusline.config.json`:

```json
{
  "line_format": "2",
  "show_context": true,
  "show_rate_limits": true,
  "show_git_branch": true,
  "show_tools": true,
  "show_agents": true,
  "show_tasks": true,
  "context_style": "compact",
  "separator": "pipe",
  "color_style": "colorful"
}
```

**Context style values**: `"compact"`, `"tokens"`, `"progress_bar"`
**Separator values**: `"pipe"`, `"slash"`, `"dot"`, `"arrow"`

### Configure Claude Code Settings

Ensure `~/.claude/settings.json` has the statusLine configuration:
```json
{
  "statusLine": {
    "type": "command",
    "command": "/Users/duet/.claude/statusline-command.sh"
  }
}
```

### Show Preview

After setup, show a preview by running:
```bash
echo '{"workspace":{"current_dir":"'$(pwd)'"},"model":{"id":"claude-opus-4-5-20251101"},"version":"2.0.76","context_window":{"total_input_tokens":43000,"context_window_size":200000,"current_usage":{"input_tokens":35000,"cache_creation_input_tokens":5000,"cache_read_input_tokens":3000}},"rate_limits":{"five_hour":{"used_percentage":45},"seven_day":{"used_percentage":28}}}' | ~/.claude/statusline-command.sh
```

### Confirm Setup

Output:
```
✓ Statusline configured successfully!

Your settings:
  • Layout: 2-line
  • Showing: Context, Rate limits, Git branch, Tools
  • Context style: With tokens
  • Separator: Pipe (│)

Preview:
[show the actual statusline output]

The statusline will update automatically during your session.
Use /statusline:config to change layout anytime.
```

## Related Commands

- `/statusline:status` — View current metrics
- `/statusline:config` — Quick layout change
- `/statusline:disable` — Disable statusline
