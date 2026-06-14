---
allowed-tools: Bash, Read, Write, Task, Agent
description: Resume the agent-loop from the last persisted state in .agent-loop/state.json. Wakes every 5 minutes, triages repos, dispatches work to parallel agent threads, monitors progress, and reports results.
---

# Agent Loop Resume

Resume the continuous agent-loop from the last saved state in `.agent-loop/state.json`.

The loop will load the state file to recover statistics (cycle count, items processed, PRs merged) and continue the cycle:

1. **Load State** — parse `.agent-loop/state.json` to restore loop context
2. **Wait** — sleep for configured interval (default: 5 min)
3. **Triage** — scan repo queues for actionable items
4. **Dispatch** — route autonomous work to parallel agent threads
5. **Monitor** — track thread progress and outcomes
6. **Report** — log cycle summary

## Usage

```bash
/agent-loop:resume
/agent-loop:resume --interval 300
```

## Options

- `--interval <seconds>`: Sleep between cycles (default: 300)
- `--scope <current|all|org>`: Triage scope (default: current)
- `--max-concurrency <n>`: Max parallel threads (default: 3)
- `--repos <owner/repo,...>`: Comma-separated repos for broad scope
- `--dry-run`: Preview what the loop would do without executing

## State File

State is recovered from and persisted to `.agent-loop/state.json` in the repo root.
Use `/agent-loop:status` to inspect current state.
Use `/agent-loop:stop` to gracefully shut down.
