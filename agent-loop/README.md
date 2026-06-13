# Agent Loop Plugin

Continuous overnight/day repository maintenance with autonomous agent loops.

```text
Wake every 5m ──► Triage repos ──► Dispatch threads ──► Track & land
```

## Version

0.2.0

## Overview

The agent-loop plugin runs a persistent automation cycle that keeps repositories
healthy without human supervision. It is designed for overnight and day-long
autonomous upkeep: triaging issues, reviewing PRs, applying fixes, and landing
changes — all through parallel agent threads.

Inspired by Peter Steinberger's maintainer-orchestrator pattern: tell Codex to
maintain your repos, wake up every 5 minutes, and direct work to threads.
That makes it easy to parallelize + steer work as needed.

## Components

### Skills

| Skill                       | Purpose                                                |
| --------------------------- | ------------------------------------------------------ |
| **agent-loop-orchestrator** | Core loop: wait → triage → dispatch → monitor → report |
| **agent-loop-triage**       | GitHub issue/PR queue scanning and classification      |
| **agent-loop-autoreview**   | Autonomous PR review, fix application, and merging     |
| **agent-loop-browser**      | Browser automation for live UI proof and verification  |

### Commands

| Command                  | Description                           |
| ------------------------ | ------------------------------------- |
| `/agent-loop:start`      | Start the continuous maintenance loop |
| `/agent-loop:stop`       | Gracefully stop the loop              |
| `/agent-loop:status`     | Check loop status and history         |
| `/agent-loop:triage`     | One-shot repo queue triage            |
| `/agent-loop:autoreview` | One-shot PR review and fix            |

## Skill Sources

Sources adapted for the agent-loop plugin:

- **agent-loop-triage** — adapted from [steipete/agent-scripts github-project-triage](https://github.com/steipete/agent-scripts/tree/main/skills/github-project-triage)
- **agent-loop-browser** — adapted from [steipete/agent-scripts browser-use](https://github.com/steipete/agent-scripts/tree/main/skills/browser-use)
- **agent-loop-autoreview** — adapted from local autofix skill + CodeRabbit workflow patterns
- **agent-loop-orchestrator** — original orchestrator pattern inspired by maintainer-orchestrator concept

## Quick Start

```bash
# Start the loop (5 min interval, current repo)
/agent-loop:start

# Check status
/agent-loop:status

# One-shot triage (doesn't start loop)
/agent-loop:triage

# Review a specific PR
/agent-loop:autoreview --pr 123 --merge

# Stop the loop
/agent-loop:stop
```

## Configuration

| Env Variable                 | Default                | Description                    |
| ---------------------------- | ---------------------- | ------------------------------ |
| `AGENT_LOOP_INTERVAL`        | 300                    | Sleep between cycles (seconds) |
| `AGENT_LOOP_MAX_CONCURRENCY` | 3                      | Max parallel worker threads    |
| `AGENT_LOOP_SCOPE`           | current                | Default triage scope           |
| `AGENT_LOOP_LOG_DIR`         | .agent-loop/logs       | Log output directory           |
| `AGENT_LOOP_STATE_FILE`      | .agent-loop/state.json | Persisted loop state           |
| `AGENT_LOOP_REPOS`           | (from git remote)      | Comma-separated repo list      |

## Plugin Structure

```text
agent-loop/
├── .claude-plugin/
│   └── plugin.json          # Manifest (version 0.2.0)
├── .codex-plugin/
│   └── plugin.json          # Codex manifest
├── commands/                # Slash commands
│   ├── start.md
│   ├── stop.md
│   ├── status.md
│   ├── triage.md
│   └── autoreview.md
├── skills/                  # Reusable knowledge
│   ├── agent-loop-orchestrator/
│   │   └── SKILL.md
│   ├── agent-loop-triage/
│   │   └── SKILL.md
│   ├── agent-loop-autoreview/
│   │   └── SKILL.md
│   └── agent-loop-browser/
│       └── SKILL.md
└── README.md
```

## Versioning

Follow semantic versioning (semver):

| Change Type               | Version Bump | Example       |
| ------------------------- | ------------ | ------------- |
| Bug fix, docs             | Patch        | 0.2.0 → 0.2.1 |
| New feature, minor change | Minor        | 0.2.0 → 0.3.0 |
| Breaking change           | Major        | 0.2.0 → 1.0.0 |

## Commit Convention

Use semantic commits with plugin scope:

```text
feat(agent-loop): add new feature
fix(agent-loop): fix bug
docs(agent-loop): update documentation
```

Co-author: `Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>`

---

**Based on concepts from [steipete/agent-scripts](https://github.com/steipete/agent-scripts)**
