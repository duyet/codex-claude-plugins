# Agent Loop Plugin

Continuous overnight/day repository maintenance with autonomous agent loops.

## Version

0.3.0

## Plugin Structure

```text
agent-loop/
├── .antigravity-plugin/
│   └── plugin.json          # Antigravity manifest (version 0.3.0)
├── .claude-plugin/
│   └── plugin.json          # Manifest (version 0.3.0)
├── commands/                # Slash commands
├── skills/                  # Reusable knowledge
│   ├── agent-loop-orchestrator/
│   ├── agent-loop-triage/
│   ├── agent-loop-autoreview/
│   └── agent-loop-browser/
└── README.md                # Documentation
```

## Components

### Commands

| Command                  | Description                           |
| ------------------------ | ------------------------------------- |
| `/agent-loop:start`      | Start the continuous maintenance loop |
| `/agent-loop:stop`       | Gracefully stop the loop              |
| `/agent-loop:status`     | Check loop status and history         |
| `/agent-loop:triage`     | One-shot repo queue triage            |
| `/agent-loop:autoreview` | One-shot PR review and fix            |

### Skills

| Skill                       | Purpose                                                |
| --------------------------- | ------------------------------------------------------ |
| **agent-loop-orchestrator** | Core loop: wait → triage → dispatch → monitor → report |
| **agent-loop-triage**       | GitHub issue/PR queue scanning and classification      |
| **agent-loop-autoreview**   | Autonomous PR review, fix application, and merging     |
| **agent-loop-browser**      | Browser automation for live UI proof and verification  |

## Versioning

Follow semantic versioning (semver):

| Change Type               | Version Bump | Example       |
| ------------------------- | ------------ | ------------- |
| Bug fix, docs             | Patch        | 0.2.0 → 0.2.1 |
| New feature, minor change | Minor        | 0.2.0 → 0.3.0 |
| Breaking change           | Major        | 0.2.0 → 1.0.0 |

Always update `plugin.json` version when making changes.

## Commit Convention

Use semantic commits with plugin scope:

```text
feat(agent-loop): add new feature
fix(agent-loop): fix bug
docs(agent-loop): update documentation
```

Co-author: `Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>`
