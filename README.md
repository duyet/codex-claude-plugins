# Claude Plugins Marketplace

> Extend Claude Code with specialized agents, commands, and skills.

A collection of production-quality plugins for Claude Code, including autonomous agents, workflow automation, and developer tools.

## Quick Install

```bash
# Add marketplace
/plugin marketplace add duyet/claude-plugins

# Install plugins
/plugin install team-agents@duyet-claude-plugins
/plugin install commit@duyet-claude-plugins
/plugin install terminal-ui-design@duyet-claude-plugins
/plugin install frontend-design@duyet-claude-plugins
/plugin install interview@duyet-claude-plugins
/plugin install statusline@duyet-claude-plugins
/plugin install orchestration@duyet-claude-plugins
/plugin install duyetbot@duyet-claude-plugins
/plugin install docs-generator@duyet-claude-plugins
/plugin install github@duyet-claude-plugins
/plugin install fix@duyet-claude-plugins
```

## Usage Examples

### Parallel Team Execution
```bash
# Delegate to team agents for parallel work
/duyetbot:spawn Implement the frontend dashboard
# Leader coordinates senior + junior engineers working in parallel
```

### Smart GitHub Workflow
```bash
# Automatically creates feature branch from main
/gh-pr create "Add user settings page"
# Detects main/master, creates feature/X branch, implements, creates PR
```

---

## Plugins at a Glance

| Plugin | Type | What it does |
|--------|------|--------------|
| [👥 team-agents](#👥-team-agents) | Skill | Leader, Senior Engineer, and Junior Engi... |
| [📝 commit](#📝-commit) | Command | Create a Git commit with semantic commit... |
| [🎨 terminal-ui-design](#🎨-terminal-ui-design) | Skill | Create distinctive, production-grade ter... |
| [🎨 frontend-design](#🎨-frontend-design) | Skill | Create distinctive, production-grade fro... |
| [💬 interview](#💬-interview) | Command | Conduct in-depth requirements interviews... |
| [📊 statusline](#📊-statusline) | Hook | Configurable status bar showing context ... |
| [🎼 orchestration](#🎼-orchestration) | Skill | Orchestrator skill for managing parallel... |
| [🤖 duyetbot](#🤖-duyetbot) | Skill | Pragmatic software development companion... |
| [🎯 docs-generator](#🎯-docs-generator) | Hook | Automatically generate and maintain plug... |
| [🐙 github](#🐙-github) | Skill | GitHub operations using gh CLI - PRs, is... |
| [🔧 fix](#🔧-fix) | Command | Fix issues, tests, and CI failures with ... |


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
  - `/commit:commit`: Create a git commit with semantic commit message format
  - `/commit:and-push`: Commit and push to remote
  - `/commit:and-create-pr`: Commit, push, and create a pull request
```

---

### 🎨 terminal-ui-design

**Create distinctive, production-grade terminal user interfaces with high design quality**

**Components:**

Skills:
  - **terminal-ui-design**

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

**Pragmatic software development companion with engineering discipline and transparent execution.**

```bash
  - `/duyetbot`: Summon duyetbot - pragmatic software development companion with transparent execution
  - `/learn`: Learn about @duyet and update knowledge base
  - `/orchestrate`: Duyetbot orchestrate - coordinate parallel agent workstreams for complex tasks
  - `/spawn`: Duyetbot spawn - delegate tasks to team agents for parallel execution
  - `/think`: Duyetbot deep thinking - structured problem analysis with visible reasoning
```

**Components:**

Agents:
  - **duyetbot**

Skills:
  - **duyet-knowledge**
  - **engineering-discipline**
  - **team-coordination**
  - **transparency**

---

### 🎯 docs-generator

**Automatically generate and maintain plugin documentation (README.md, CLAUDE.md)**

```bash
  - `/generate-docs`: Manually trigger documentation generation for all plugins
```

---

### 🐙 github

**GitHub operations using gh CLI - PRs, issues, workflows, repositories, releases, and smart branch detection for implementation workflows**

Automatically detects when you're on main/master and creates feature branches before implementing. Handles complete GitHub workflow from branch creation to PR merge.

**Components:**

Skills:
  - **github**

---

### 🔧 fix

**Fix issues, tests, and CI failures with intelligent problem detection and resolution**

Auto-detects project type and runs appropriate checks. Spawns parallel agents for complex multi-file fixes.

```bash
  - `/fix:and-push`: Fix issues, commit, and push to remote
  - `/fix:and-update-pr`: Fix issues and update existing PR
  - `/fix:and-create-pr`: Fix issues and create new PR
```

**Supported Projects:**
- Python (pytest, ruff, mypy)
- Node/TypeScript (jest, vitest, eslint, tsc)
- Rust (cargo test, clippy)
- Go (go test, golint)

**Components:**

Skills:
  - **test-detection**

---





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

## License

MIT License - See individual plugin directories for details.

## Links

- [Report Issues](https://github.com/duyet/claude-plugins/issues)
- [Request Features](https://github.com/duyet/claude-plugins/issues/new?template=feature_request.md)

---
