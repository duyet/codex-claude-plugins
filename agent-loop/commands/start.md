---
allowed-tools: Bash, Read, Write, Task, Agent
description: Start the agent-loop — continuous overnight/day repo maintenance cycle. Auto-detects existing state and prompts to resume or start fresh. Wakes every 5 minutes, triages repos, dispatches work to parallel agent threads, monitors progress, and reports results.
---

# Agent Loop Start

Start the continuous agent-loop for automated repository maintenance.

The loop runs indefinitely, cycling through:
1. **Wait** — sleep for configured interval (default: 5 min)
2. **Triage** — scan repo queues for actionable items
3. **Dispatch** — route autonomous work to parallel agent threads
4. **Monitor** — track thread progress and outcomes
5. **Report** — log cycle summary

## Startup Behavior

When you run `/agent-loop:start`, the command first **checks for existing state**:

- **If `.agent-loop/state.json` exists** → You are prompted to:
  - `resume` — Continue from saved state (preserves cycle count, items processed, thread history)
  - `fresh` — Start a new loop (creates a fresh state.json, backup of old state saved)
  - `inspect` — View the existing state before deciding

- **If no state exists** → Starts a fresh loop immediately

## Usage

```bash
# Start fresh or resume existing (auto-prompts if state exists)
/agent-loop:start

# Force start fresh (ignore existing state, create backup)
/agent-loop:start --fresh

# Force resume (error if state doesn't exist)
/agent-loop:start --resume

# Override defaults
/agent-loop:start --interval 600 --scope all --max-concurrency 5
```

## Options

- `--interval <seconds>`: Sleep between cycles (default: 300)
- `--scope <current|all|org>`: Triage scope (default: current)
- `--max-concurrency <n>`: Max parallel threads (default: 3)
- `--repos <owner/repo,...>`: Comma-separated repos for broad scope
- `--fresh`: Ignore existing state, start fresh (backs up old state)
- `--resume`: Resume from existing state (error if state missing)
- `--dry-run`: Preview what the loop would do without executing

## State Management

- Persisted to `.agent-loop/state.json` in repo root
- Backups kept in `.agent-loop/backups/` (timestamped)
- Use `/agent-loop:status` to inspect current state
- Use `/agent-loop:inspect` to view state details
- Use `/agent-loop:reset` to clear state and start fresh
- Use `/agent-loop:restore` to recover from a backup
- Use `/agent-loop:stop` to gracefully shut down
