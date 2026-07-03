---
description: Interactive wizard to configure and generate a personalized statusline (layout, sections, icons, or a preset template)
---

# /statusline:setup

Interactive setup wizard that configures and generates your personalized statusline.

## Action Required

When this command is invoked, conduct an interview using AskUserQuestion, then generate the statusline script.

### Step 1: Ask 4 Questions

Use AskUserQuestion to ask these questions (up to 4 at a time):

#### Q1: Template Preset
**Header**: "Template"
**Question**: "Choose a template preset, or customize from scratch?"
**Options**:
1. **Detailed** — 3-line, progress bar, emoji icons, all sections (Recommended)
2. **Balanced** — 2-line, tokens, unicode icons, key metrics
3. **Minimal** — 1-line, compact, no icons, essentials only
4. **Custom** — Pick individual settings below

#### Q2: If Custom — Information Sections
**Header**: "Show"
**Question**: "What information do you want to see?"
**multiSelect**: true
**Options**:
1. **Context usage** — Token count, percentage, progress bar
2. **Rate limits** — API usage (5h/7d for Anthropic, tokens/tools for GLM)
3. **Cache hit rate** — Cache read vs total percentage (Anthropic Claude only)
4. **Session duration** — Time elapsed since session start

#### Q3: If Custom — Context Display Style
**Header**: "Context"
**Question**: "How should context usage be displayed?"
**Options**:
1. **Compact** — Just percentage: `21%`
2. **With tokens** — Percentage + token counts: `21% (43k/200k)`
3. **Progress bar** — Visual bar + details: `██░░ 21% (43k/200k)`

#### Q4: If Custom — Icon Style
**Header**: "Icons"
**Question**: "What icon style for section labels?"
**Options**:
1. **Emoji** — 📁 🤖 📊 🗃️ ⏱️ (colorful, easy to scan)
2. **Unicode** — ■ ◈ ▪ ◇ ◷ (minimal, terminal-friendly)
3. **None** — No icons (plain text labels)

### Step 2: Apply Configuration

**If a template was selected** (not Custom), write the template's config to `~/.claude/statusline.config.json`:

| Template | Config to write |
|----------|----------------|
| Detailed | `{"line_format":"3","separator":"arrow","context_style":"progress_bar","icon_style":"emoji","show_context":true,"show_rate_limits":true,"show_git_branch":true,"show_tools":true,"show_agents":true,"show_cache":true,"show_session":true,"show_reasoning":true,"color_style":"colorful"}` |
| Balanced | `{"line_format":"2","separator":"arrow","context_style":"tokens","icon_style":"unicode","show_context":true,"show_rate_limits":true,"show_git_branch":true,"show_tools":true,"show_agents":true,"show_cache":true,"show_session":true,"show_reasoning":true,"color_style":"colorful"}` |
| Minimal | `{"line_format":"1","separator":"dot","context_style":"compact","icon_style":"minimal","show_context":true,"show_rate_limits":true,"show_git_branch":true,"show_tools":false,"show_agents":false,"show_cache":false,"show_session":false,"show_reasoning":true,"color_style":"colorful"}` |

**If Custom**, build the config from the user's answers and write it.

Use the Write tool to save to `~/.claude/statusline.config.json`.

### Step 3: Configure Claude Code Settings

Ensure `~/.claude/settings.json` has the statusLine configuration:
```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline-command.sh"
  }
}
```

### Step 4: Show Preview

Run a preview with sample data:
```bash
echo '{"workspace":{"current_dir":"'$(pwd)'"},"model":{"id":"claude-opus-4-8"},"version":"2.0.76","context_window":{"total_input_tokens":43000,"context_window_size":200000,"current_usage":{"input_tokens":35000,"cache_creation_input_tokens":5000,"cache_read_input_tokens":3000}},"effort":{"level":"medium"},"rate_limits":{"five_hour":{"used_percentage":45},"seven_day":{"used_percentage":28}}}' | ~/.claude/statusline-command.sh
```

### Step 5: Confirm Setup

Output:
```
✓ Statusline configured successfully!

Template: Detailed (3-line)
  • Context: Progress bar ██░░░░░░░░ 21% (43k/200k)
  • Cache: 37% (3k/8k) cache hit (Anthropic only)
  • Rate limits: 5h/7d with reset timers
  • Session duration: ⏳ tracker
  • Icons: 📁 🤖 📊 🗃️ ⏱️ 🔧
  • Separator: → arrow

Preview:
[show the actual statusline output]

Config saved to ~/.claude/statusline.config.json
The statusline will update automatically during your session.
Use /statusline:config to change layout anytime.
```

## Related Commands

- `/statusline:status` — View current metrics
- `/statusline:config` — Quick layout change or apply a different template
- `/statusline:disable` — Disable statusline
