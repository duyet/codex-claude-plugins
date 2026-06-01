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
3. **Style** — Context display, icons, separator
4. **Template** — Apply a preset template

### If Layout selected:

**Header**: "Layout"
**Question**: "How many lines should the statusline display?"
**Options**:
1. **1 line (Compact)** — Everything on one line, no icons
2. **2 lines (Balanced)** — Location/model + metrics
3. **3 lines (Detailed)** — Full layout with progress bar, cache, session

### If Sections selected:

**Header**: "Sections"
**Question**: "Which sections should be visible?"
**multiSelect**: true
**Options**:
1. **Context usage** — Token count, percentage, progress bar
2. **Rate limits** — API usage (5h/7d for Anthropic, tokens/tools for GLM)
3. **Cache hit rate** — Cache read vs total (Anthropic Claude only)
4. **Session duration** — Time elapsed since session start
5. **Git branch** — Current branch name
6. **Active tools** — Running MCP servers and agent count
7. **Reasoning level** — Effort level next to model name

### If Style selected:

**Header**: "Style"
**Question**: "What display style preferences?"
**multiSelect**: true
**Options**:
1. **Context style** — How context usage is displayed
2. **Icon theme** — Emoji, unicode, or none
3. **Separator** — Arrow, pipe, dot, slash

### If Template selected:

**Header**: "Template"
**Question**: "Apply a preset template?"
**Options**:
1. **Detailed** — 3-line, progress bar, emoji, all sections
2. **Balanced** — 2-line, tokens, unicode, key metrics
3. **Minimal** — 1-line, compact, no icons
4. **Monitor** — 2-line, rate-limit focused, no tools
5. **Developer** — 2-line, tools + agents + git focused
6. **Performance** — 3-line, cache + context optimization focused

### Save Configuration

Update `~/.claude/statusline.config.json` with the new values. Keep existing values for any settings not changed.

## Example Outputs by Provider

**Anthropic Claude** (3-line, detailed):
```
📁 monorepo (master) → 🤖 opus-4.8[200k] (medium) → ⏳ 23m
📊 ██░░░░░░░░ 21% (43k/200k) → 🗃️ 98% (42k/43k) cache hit → ⏱️ 5h: 45% | 7d: 28%
🔧 Seq Ctx7
```

**z.ai GLM** (3-line, detailed):
```
📁 monorepo (master) → 🤖 glm-5.1[1m] (max) → ⏳ 45m
📊 █░░░░░░░░░ 12% (120k/1.0M) → ⏱️ rate-limits: n/a
🔧 Seq Ctx7
```

**Anthropic Claude** (1-line, minimal):
```
monorepo (master) · opus-4.8[200k] (medium) · 21% · 5h: 45% | 7d: 28%
```

## Related Commands

- `/statusline:setup` — Full interactive setup wizard
- `/statusline:status` — View current metrics
- `/statusline:disable` — Disable monitoring
