---
allowed-tools: Bash, Read
description: Check agent-loop status — running state, cycle count, items processed, active threads, and recent results.
---

# Agent Loop Status

Check the current state of the agent-loop.

## Usage

```bash
/agent-loop:status
/agent-loop:status --json
/agent-loop:status --history 10
```

## Options

- `--json`: Output raw state as JSON
- `--history <n>`: Show last N cycle reports (default: 5)

## Output

```text
Agent Loop: RUNNING (PID: 42391)
  Started: 2026-06-11 00:00:00 UTC
  Uptime: 2h 14m 32s
  Current cycle: #24
  Active threads: 3
    ├─ Thread-1: GH-123 | login timeout fix | 4m 12s running
    ├─ Thread-2: GH-124 | deps update | 2m 03s running
    └─ Thread-3: GH-125 | docs fix | 30s running
  Cycle history (last 5):
    #23: 2 autonomous, 0 failed, 1 needs review | 1m 42s
    #22: 1 autonomous, 1 merged | 2m 15s
    #21: 0 items | 5m 02s (idle)
    #20: 3 autonomous, 2 merged, 1 failed | 4m 30s
    #19: 0 items | 5m 00s (idle)
  Totals: 87 processed, 34 autonomous, 15 merged PRs
```
