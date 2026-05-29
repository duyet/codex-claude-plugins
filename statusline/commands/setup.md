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
1. **1 line (Compact)** — Everything on one line, no icons
2. **2 lines (Balanced)** — Location/model + metrics
3. **3 lines (Detailed)** — Full layout with progress bar, cache, session

#### Q2: Information Sections
**Header**: "Show"
**Question**: "What information do you want to see?"
**multiSelect**: true
**Options**:
1. **Context usage** — Token count, percentage, progress bar
2. **Rate limits** — API usage (5h/7d for Anthropic, tokens/tools for GLM)
3. **Cache hit rate** — Cache read vs total percentage
4. **Session duration** — Time elapsed since session start

#### Q3: Context Display Style
**Header**: "Context"
**Question**: "How should context usage be displayed?"
**Options**:
1. **Compact** — Just percentage: `21%`
2. **With tokens** — Percentage + token counts: `21% (43k/200k)`
3. **Progress bar** — Visual bar + details: `██░░ 21% (43k/200k)`

#### Q4: Icon Style
**Header**: "Icons"
**Question**: "What icon style for section labels?"
**Options**:
1. **Emoji** — 📁 🤖 📊 🗃️ ⏱️ (colorful, easy to scan)
2. **Unicode** — ■ ◈ ▪ ◇ ◷ (minimal, terminal-friendly)
3. **None** — No icons (plain text labels)

### Generate Statusline Script

Based on answers, update `~/.claude/statusline.config.json`:

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

**Line format values**: `"1"`, `"2"`, `"3"`
**Context style values**: `"compact"`, `"tokens"`, `"progress_bar"`
**Icon style values**: `"emoji"`, `"unicode"`, `"minimal"`
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

### Template Presets

Available in `scripts/templates/`:
- `detailed.json` — 3-line, progress bar, emoji, all sections (default)
- `balanced.json` — 2-line, tokens, unicode, key metrics
- `minimal.json` — 1-line, compact, no icons, essentials only

### Show Preview

After setup, show a preview by running:
```bash
echo '{"workspace":{"current_dir":"'$(pwd)'"},"model":{"id":"claude-opus-4-8"},"version":"2.0.76","context_window":{"total_input_tokens":43000,"context_window_size":200000,"current_usage":{"input_tokens":35000,"cache_creation_input_tokens":5000,"cache_read_input_tokens":3000}},"effort":{"level":"medium"},"rate_limits":{"five_hour":{"used_percentage":45},"seven_day":{"used_percentage":28}}}' | ~/.claude/statusline-command.sh
```

### Confirm Setup

Output:
```
✓ Statusline configured successfully!

Your settings:
  • Layout: 3-line
  • Showing: Context, Rate limits, Cache hit, Session duration, Git branch, Tools
  • Context style: Progress bar
  • Icons: Emoji
  • Separator: Arrow (→)

Preview:
[show the actual statusline output]

The statusline will update automatically during your session.
Use /statusline:config to change layout anytime.
```

## Related Commands

- `/statusline:status` — View current metrics
- `/statusline:config` — Quick layout change
- `/statusline:disable` — Disable statusline
