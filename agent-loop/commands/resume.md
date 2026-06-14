---
allowed-tools: Bash, Read, Write, Task, Agent
description: Resume the agent-loop from the last persisted state in .agent-loop/state.json. Loads cycle context and thread history, then continues the maintenance cycle.
---

# Agent Loop Resume

Resume the continuous agent-loop from the last saved state in `.agent-loop/state.json`.

The loop will load the state file to recover everything that was saved: cycle count, items processed, PRs merged, active thread list, and thread history. This allows you to pick up exactly where you left off without losing context.

## What Gets Recovered

When you resume, these are restored from state.json:

| Field | Purpose |
|-------|---------|
| `cycle` | Current cycle number (resumes from N+1) |
| `started_at` | Original start time (maintains uptime) |
| `items_processed` | Total items seen (cumulative) |
| `items_autonomous` / `items_needs_review` / `items_deferred` | Classification counts |
| `prs_merged` | Total PRs successfully merged |
| `active_threads` | Thread IDs still in progress |
| `thread_history` | Full record of past thread outcomes |

## Resumption Flow

1. **Load State** — parse `.agent-loop/state.json`, validate integrity
2. **Validate** — check that state is not corrupted and thread IDs are sane
3. **Restore** — reconstruct loop context and metrics
4. **Wait** — sleep for configured interval (default: 5 min)
5. **Triage** — scan repo queues for new actionable items
6. **Dispatch** — route work to parallel agent threads
7. **Monitor** — track progress and outcomes
8. **Report** — append cycle summary to logs

## Usage

```bash
# Resume from saved state (error if state.json missing)
/agent-loop:resume

# Resume with custom interval
/agent-loop:resume --interval 600

# Resume with broader scope
/agent-loop:resume --scope all --max-concurrency 4

# Preview what would resume without starting loop
/agent-loop:resume --dry-run
```

## Options

- `--interval <seconds>`: Sleep between cycles (default: 300)
- `--scope <current|all|org>`: Triage scope (default: saved scope or current)
- `--max-concurrency <n>`: Max parallel threads (default: saved or 3)
- `--repos <owner/repo,...>`: Comma-separated repos (default: saved repos)
- `--dry-run`: Validate state and preview first cycle without starting loop
- `--validate-only`: Check state.json integrity and exit (no resumption)

## Error Recovery

If state.json is corrupted:
1. Use `/agent-loop:inspect` to view the corruption details
2. Use `/agent-loop:restore` to recover from a timestamped backup
3. Or use `/agent-loop:reset` to start fresh (with backup of corrupted state)

## State File Location

State is recovered from `.agent-loop/state.json` in the repo root.
Backups are kept in `.agent-loop/backups/state-YYYY-MM-DD-HHmmss.json` for recovery.

See `/agent-loop:status`, `/agent-loop:inspect`, and `/agent-loop:stop` for state management.
