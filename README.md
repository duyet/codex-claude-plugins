# Claude Plugins Marketplace

> Extend Claude Code with specialized agents, commands, and skills.

## Quick Install

```bash
# Add marketplace
/plugin marketplace add duyet/claude-plugins

# Install plugins
/plugin install team-agents@duyet-claude-plugins
/plugin install commit@duyet-claude-plugins
/plugin install terminal-ui-design@duyet-claude-plugins
/plugin install ralph-wiggum@duyet-claude-plugins
/plugin install frontend-design@duyet-claude-plugins
/plugin install interview@duyet-claude-plugins
/plugin install statusline@duyet-claude-plugins
/plugin install orchestration@duyet-claude-plugins
/plugin install duyetbot@duyet-claude-plugins
/plugin install docs-generator@duyet-claude-plugins
```

---

## Plugins at a Glance

| Plugin | Type | What it does |
|--------|------|--------------|
| [👥 team-agents](#👥-team-agents) | Skill | Leader, Senior Engineer, and Junior Engi... |
| [📝 commit](#📝-commit) | Command | Create a Git commit with semantic commit... |
| [🎨 terminal-ui-design](#🎨-terminal-ui-design) | Skill | Create distinctive, production-grade ter... |
| [🔄 ralph-wiggum](#🔄-ralph-wiggum) | Hook | Self-referential development loop for Cl... |
| [🎨 frontend-design](#🎨-frontend-design) | Skill | Create distinctive, production-grade fro... |
| [💬 interview](#💬-interview) | Command | Conduct in-depth requirements interviews... |
| [📊 statusline](#📊-statusline) | Hook | Configurable status bar showing context ... |
| [🎼 orchestration](#🎼-orchestration) | Skill | Orchestrator skill for managing parallel... |
| [🤖 duyetbot](#🤖-duyetbot) | Skill | Pragmatic software development companion... |
| [🎯 docs-generator](#🎯-docs-generator) | Hook | Automatically generate and maintain plug... |


---

## Plugin Details

### 👥 team-agents

**Leader, Senior Engineer, and Junior Engineer agents for coordinated parallel task execution**

```bash
  - `/leader`
```

**Components:**

Agents:
  - **junior-engineer**
  - **leader**
  - **senior-engineer**

Skills:
  - **backend-api-patterns**
  - **quality-gates**
  - **react-nextjs-patterns**
  - **task-decomposition**
  - **typescript-patterns**

---

### 📝 commit

**Create a Git commit with semantic commit message format**

```bash
  - `/commit-and-push`: Create a git commit with semantic commit message format and push to remote
  - `/commit`: Create a git commit with semantic commit message format
```

---

### 🎨 terminal-ui-design

**Create distinctive, production-grade terminal user interfaces with high design quality**

**Components:**

Skills:
  - **terminal-ui-design**

---

### 🔄 ralph-wiggum

**Self-referential development loop for Claude Code. Run iterative tasks with automatic progress detection and circuit breaker safety.**

```bash
  - `/cancel-ralph`: "Cancel active Ralph Wiggum loop"
  - `/help`: "Explain Ralph Wiggum technique and available commands"
  - `/ralph-loop`: "Start Ralph Wiggum loop in current session"
```

---

### 🎨 frontend-design

**Create distinctive, production-grade frontend interfaces avoiding AI slop aesthetics. Emphasizes shadcn/ui, Recharts, and bold design choices.**

**Components:**

Skills:
  - **frontend-design**

---

### 💬 interview

**Conduct in-depth requirements interviews using Socratic questioning to clarify implementation details before coding**

```bash
  - `/interview`: Conduct in-depth requirements interview using Socratic questioning to clarify implementation details
```

---

### 📊 statusline

**Configurable status bar showing context usage, API rate limits (5h/7d), git branch, and active tools. Supports 1/2/3 line layouts with smart hiding of empty values.**

```bash
  - `/config`
  - `/disable`
  - `/setup`
```

---

### 🎼 orchestration

**Orchestrator skill for managing parallel agent workstreams. Transform complex requests into coordinated multi-agent execution with elegant result synthesis.**

**Components:**

Skills:
  - **orchestration**

---

### 🤖 duyetbot

**Pragmatic software development companion with engineering discipline and transparent execution. Spawns team-agents and uses orchestration patterns for parallel work.**

```bash
  - `/duyetbot`: Summon duyetbot - pragmatic software development companion with transparent execution
  - `/learn`: Learn about @duyet and update knowledge base
  - `/loop`: Duyetbot loop - iterative execution until task completion
```

**Components:**

Agents:
  - **duyetbot**

Skills:
  - **duyet-knowledge**
  - **engineering-discipline**
  - **task-loop**
  - **team-coordination**
  - **transparency**

---

### 🎯 docs-generator

**Automatically generate and maintain plugin documentation (README.md, CLAUDE.md)**

```bash
  - `/generate-docs`: Manually trigger documentation generation for all plugins
```

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
