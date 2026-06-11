---
allowed-tools: Bash, Read, Write, Task, Agent
description: Start the agent-loop — continuous overnight/day repo maintenance cycle. Wakes every 5 minutes, triages repos, dispatches work to parallel agent threads, monitors progress, and reports results.
---

# Agent Loop Start

Start the continuous agent-loop for automated repository maintenance.

The loop runs indefinitely, cycling through:
1. **Wait** — sleep for configured interval (default: 5 min)
2. **Triage** — scan repo queues for actionable items
3. **Dispatch** — route autonomous work to parallel agent threads
4. **Monitor** — track thread progress and outcomes
5. **Report** — log cycle summary

## Usage

```bash
/agent-loop:start
/agent-loop:start --interval 300
/agent-loop:start --scope all
/agent-loop:start --interval 600 --max-concurrency 5 --scope org
```

## Options

- `--interval <seconds>`: Sleep between cycles (default: 300)
- `--scope <current|all|org>`: Triage scope (default: current)
- `--max-concurrency <n>`: Max parallel threads (default: 3)
- `--repos <owner/repo,...>`: Comma-separated repos for broad scope
- `--dry-run`: Preview what the loop would do without executing

## State File

State is persisted to `.agent-loop/state.json` in the repo root.
Use `/agent-loop:status` to inspect current state.
Use `/agent-loop:stop` to gracefully shut down.
