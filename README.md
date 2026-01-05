# Claude Plugins Marketplace

> Extend Claude Code with specialized agents, commands, and skills.

## Quick Install

```bash
# Add marketplace
/plugin marketplace add duyet/claude-plugins

# Install plugins
/plugin install team-agents@duyet-claude-plugins
/plugin install frontend-design@duyet-claude-plugins
/plugin install ralph-wiggum@duyet-claude-plugins
/plugin install interview@duyet-claude-plugins
/plugin install commit@duyet-claude-plugins
/plugin install statusline@duyet-claude-plugins
/plugin install terminal-ui-design@duyet-claude-plugins
```

---

## Plugins at a Glance

| Plugin | Type | What it does |
|--------|------|--------------|
| [team-agents](#-team-agents) | Agent | Leader → parallel senior engineers |
| [frontend-design](#-frontend-design) | Skill | Beautiful UIs, not AI slop |
| [ralph-wiggum](#-ralph-wiggum) | Hook | "Run until done" loop |
| [interview](#-interview) | Skill | Socratic requirements discovery |
| [commit](#-commit) | Command | Semantic git commits |
| [statusline](#-statusline) | Config | Live metrics in your terminal |
| [terminal-ui-design](#-terminal-ui-design) | Skill | Stunning CLI/TUI aesthetics |

---

## Plugin Details

### 🎯 Team Agents
**Parallel execution with coordination**

```
You:     "Implement auth with OAuth2, JWT, and RBAC"
Leader:  Analyzes → Splits into 3 parallel tasks
         ├── Senior 1: OAuth flow
         ├── Senior 2: JWT middleware
         └── Senior 3: Role permissions
         Reviews → Ensures quality
```

**When:** Multi-file features, complex refactoring, anything parallelizable

---

### 🎨 Frontend Design
**UI that doesn't look like AI made it**

```
/frontend-design

You:     "Create a dashboard"
Claude:  Bold aesthetic → shadcn/ui → Recharts → Framer Motion
         Result: Distinctive, not generic
```

**Stack:** shadcn/ui · Recharts · Tailwind · Framer Motion

---

### 🔄 Ralph Wiggum
**Self-healing development loop**

```bash
/ralph-loop "Build a REST API for todos. <promise>COMPLETE</promise> when done."

# Claude works → exits → hook restarts → sees previous work → continues
# Repeats until COMPLETE or max iterations
```

**Philosophy:** Iteration > perfection · Failures = data · Persistence wins

**When:** TDD, greenfield projects, tasks with clear success criteria

---

### 💬 Interview
**Ask before you build**

```bash
/interview "user authentication with OAuth"
/interview ./docs/feature-spec.md
```

Uncovers: edge cases · tradeoffs · hidden complexity · constraints

**When:** Requirements unclear, before writing any code

---

### 📝 Commit
**Semantic commits, auto-generated**

```bash
/commit           # Analyze changes → generate message → commit
/commit-and-push  # + push to remote
```

---

### 📊 Statusline
**Live metrics in your terminal**

```
┌─────────────────────────────────────────────────────────┐
│ opus-4.5 │ Context: 43% │ 5h: 67% │ 7d: 23% │ main     │
└─────────────────────────────────────────────────────────┘
```

```bash
/statusline:setup   # Interactive configuration
```

Formats: 1-line compact · 2-line detailed · 3-line full

---

### 🖥️ Terminal UI Design
**Beautiful CLIs and TUIs**

```
You:     "Create a CLI dashboard"
Claude:  Aesthetic direction (cyberpunk? minimalist? retro?)
         → Custom borders → Color palette → Animation patterns
```

**Libraries:** Rich/Textual (Python) · Bubbletea (Go) · Ratatui (Rust) · Ink (Node)

---

## Manual Installation

Add to `~/.claude/settings.json`:

```json
{
  "extraKnownMarketplaces": {
    "duyet-claude-plugins": {
      "source": { "source": "github", "repo": "duyet/claude-plugins" }
    }
  },
  "enabledPlugins": {
    "team-agents@duyet-claude-plugins": true
  }
}
```

---

## Contributing

```
your-plugin/
├── .claude-plugin/plugin.json   # name, version, description
├── agents/                      # .md with YAML frontmatter
├── commands/                    # slash commands
├── skills/                      # reusable knowledge
└── hooks/hooks.json             # lifecycle hooks
```

Update `marketplace.json` → PR → Done

---

MIT License
