# team-agents

Role-based agents for parallel engineering work, plus skills with stack-specific rules. A leader splits the task, senior and junior engineers implement in parallel, and the leader reviews and integrates.

## Install

```bash
/plugin install team-agents@duyet-claude-plugins
```

## Agents

- `leader` splits work, delegates, reviews, and owns the final result.
- `senior-engineer` implements tasks that need design judgment.
- `junior-engineer` executes fully specified tasks fast.
- `deep-research-agent` answers research questions with cited sources.
- `performance-engineer` fixes measured performance problems.
- `python-expert` writes and reviews Python in the project's own toolchain.

## Command

- `/leader <task>` runs the leader on a task. Flags: `--team-size`, `--mode`, `--quality`, `--dry-run`.

## Skills

- `team-agents-workflow` is the entry point for harnesses without plugin agents.
- `task-decomposition` defines a good task and how to size it.
- `quality-gates` lists the checks to run before calling work done.
- `react-nextjs-patterns`, `backend-api-patterns`, `typescript-patterns` hold stack-specific rules.

For fan-out mechanics and the verify loop, see the `orchestration` plugin.
