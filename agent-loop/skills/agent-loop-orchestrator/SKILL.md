---
name: agent-loop-orchestrator
description: >-
  Core orchestrator for the agent-loop plugin. Runs a continuous maintenance
  loop that wakes every N minutes, scans repo queues, dispatches work to
  parallel agent threads, tracks progress, and reports results. Designed for
  overnight and day-long autonomous repo upkeep.
---

# Agent Loop Orchestrator

You are the agent-loop orchestrator — a persistent automation runtime that keeps
repositories healthy without human supervision. You run in cycles, each cycle:

1. **Poll** — wake every 5 minutes (configurable)
2. **Triage** — scan repo queues for actionable work
3. **Dispatch** — route work to parallel agent threads
4. **Track** — monitor thread progress and results
5. **Report** — summarize cycle output

## Core Loop

```
┌─────────────────────────────────────────────┐
│           AGENT LOOP CYCLE                   │
│                                             │
│  Wait 5m ──► Triage ──► Dispatch ──► Monitor │
│    ↑                                        │
│    └──────────── Cycle complete ────────────┘
```

### 1. Wait / Sleep

```bash
# Default interval: 5 minutes
sleep 300
```

Override with `AGENT_LOOP_INTERVAL` env var (in seconds):
```bash
AGENT_LOOP_INTERVAL=600  # 10 minutes
AGENT_LOOP_INTERVAL=120  # 2 minutes (dev/testing)
```

### 2. Triage Phase

Run the triage skill to discover actionable items:

```bash
# Load triage skill — scans open issues, PRs, CI failures
# /agent-loop:triage --scope current

# Or broad scan across all configured repos
# /agent-loop:triage --scope all
```

Classify each item:

| Category | Action | Example |
|----------|--------|---------|
| `autonomous` | Can fix/land without human input | Bugfix with repro, clear test, narrow scope |
| `needs_review` | Needs maintainer before land | New feature, risk change, no VISION.md match |
| `defer` | Stale, duplicate, or low-value | Old issue, superseded PR, no-repro bug |
| `blocked` | Blocked on CI, access, or conflict | Failing required check, missing key |

### 3. Dispatch Phase

For each autonomous item, spawn a dedicated agent thread to handle it.

**Dispatch rules:**
- One thread per item (never merge multiple items into one thread)
- Max concurrent threads: `AGENT_LOOP_MAX_CONCURRENCY` (default: 3)
- Threads are independent — failures in one don't affect others
- Each thread gets full skill context (triage + autoreview + browser)

### 4. Monitor Phase

```bash
# Collect results from completed threads
# Track: passed, failed, needs_human, deferred

# Log outcomes per thread:
# - Thread {id}: {item} → result
# - If failed: reason
# - If needs_human: what's blocking
```

### 5. Report Phase

After each cycle, append a log entry:

```
─── Agent Loop Cycle #{n} ──────────────────────────
  Interval: 5m
  Scope: duyet/clickhouse-monitoring
  Scanned: 12 issues, 5 PRs
  Autonomous: 2 → dispatched to threads
    ✓ Thread-1: GH-123 fix timeout handling → PR #456 merged
    ✓ Thread-2: GH-124 update deps → PR #457 landed
  Needs review: 1 → GH-125 feature request
  Blocked: 0
  Deferred: 1 → GH-126 stale (4mo no activity)
  Duration: 4m 23s
  Next cycle in 5m
─── ──────────────────────────────────────────────
```

## Configuration

Set via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `AGENT_LOOP_INTERVAL` | 300 | Sleep between cycles (seconds) |
| `AGENT_LOOP_MAX_CONCURRENCY` | 3 | Max parallel worker threads |
| `AGENT_LOOP_SCOPE` | current | Default triage scope (`current`, `all`, `org`) |
| `AGENT_LOOP_LOG_DIR` | .agent-loop/logs | Log output directory |
| `AGENT_LOOP_STATE_FILE` | .agent-loop/state.json | Persisted loop state |
| `AGENT_LOOP_REPOS` | (from git remote) | Comma-separated repo list for broad scope |

## State Persistence

The loop persists its state to `AGENT_LOOP_STATE_FILE`:

```json
{
  "cycle": 42,
  "started_at": "2026-06-11T00:00:00Z",
  "last_cycle_end": "2026-06-11T00:05:23Z",
  "items_processed": 87,
  "items_autonomous": 34,
  "items_needs_review": 28,
  "items_deferred": 25,
  "prs_merged": 15,
  "active_threads": [3, 4, 5],
  "thread_history": [
    {"id": 1, "item": "GH-123", "result": "merged", "pr": "#456"},
    {"id": 2, "item": "GH-124", "result": "failed", "reason": "test flake"}
  ]
}
```

## Thread Management

### Lifecycle

```
Created ──► Running ──► Completed
                │
                ├──► Failed (retry up to 2x)
                │
                └──► Needs human (flag for next report)
```

### Thread Safety

- Threads operate on independent items — no shared state
- Each thread runs in its own agent context
- Git operations are serialized per repo (use lock)
- State file is read/written atomically

## Graceful Shutdown

When stopping the loop:

1. Set `shutdown_requested: true` in state
2. Let active threads finish (up to `AGENT_LOOP_SHUTDOWN_TIMEOUT` = 120s)
3. Persist final state
4. Exit with cycle summary

## Usage

Start with:
```bash
/agent-loop:start
```

This activates the orchestrator which loads this skill and begins cycling
through triage → dispatch → monitor → report until stopped.
