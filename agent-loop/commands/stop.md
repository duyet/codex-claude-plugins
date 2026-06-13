---
allowed-tools: Bash, Read, Write
description: Stop the agent-loop gracefully. Lets active threads finish within timeout, persists final state, and reports cycle summary.
---

# Agent Loop Stop

Gracefully shut down the running agent-loop.

## Usage

```bash
/agent-loop:stop
/agent-loop:stop --force
```

## Options

- `--force`: Immediate stop without waiting for active threads

## What Happens

1. Sets `shutdown_requested: true` in state file
2. Active threads get up to 120s to finish (or 0 with `--force`)
3. Final state is persisted to `.agent-loop/state.json`
4. Prints cycle summary:

```text
Agent Loop Stopped
  Cycles completed: 24
  Items processed: 87
  PRs merged: 15
  Duration: 2h 14m
  State saved to .agent-loop/state.json
```
