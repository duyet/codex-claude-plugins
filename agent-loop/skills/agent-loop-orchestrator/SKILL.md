---
name: agent-loop-orchestrator
description: Run a repeating repo maintenance cycle that triages issues and PRs, dispatches autonomous fixes to parallel subagents, and reports results. Use when started by /agent-loop:start or when asked for unattended overnight repo upkeep.
---

# Agent loop orchestrator

Each cycle runs four steps: triage, dispatch, monitor, report. This skill runs one cycle. Repetition comes from the harness, not from you.

## Scheduling

Do not run `sleep` in a shell to wait between cycles. A sleeping shell holds the session and usually hits a tool timeout. Use the harness's own recurring-run facility instead:

- Claude Code: `/loop <interval> /agent-loop:resume` (or the `schedule` skill for runs that outlive the session).
- Codex, Cursor, and other harnesses: use their scheduled or recurring task feature, or an external cron job that invokes the agent CLI in headless mode with `/agent-loop:resume`.

If the harness has no such facility, run one cycle, report, and tell the user how to rerun it.

## Cycle

1. **Triage.** Follow `../agent-loop-triage/SKILL.md` for the configured scope. It returns items classified as `autonomous`, `needs_review`, `defer`, or `blocked`.
2. **Dispatch.** Spawn one background subagent per `autonomous` item, at most `max_concurrency` at a time. Give each one the item, the repo, and pointers to `../agent-loop-autoreview/SKILL.md` and `../agent-loop-browser/SKILL.md`. Never batch two items into one worker. Workers touching the same repo must use separate branches or worktrees.
3. **Monitor.** Collect each worker's result: `merged`, `pr_opened`, `failed` (retry at most twice), or `needs_human` (with what blocks it).
4. **Report.** Update the state file, append a cycle summary to `.agent-loop/logs/`, and print it: repo, counts per class, one line per worker result, duration.

Stop early if the state file has `shutdown_requested: true`. Let running workers finish, write final state, and print the summary.

## Configuration

Read from command flags first, then environment variables, then defaults.

| Variable | Default | Meaning |
|----------|---------|---------|
| `AGENT_LOOP_INTERVAL` | 300 | Seconds between cycles, passed to the scheduler |
| `AGENT_LOOP_MAX_CONCURRENCY` | 3 | Max parallel workers |
| `AGENT_LOOP_SCOPE` | current | Triage scope: `current`, `all`, or `org` |
| `AGENT_LOOP_REPOS` | git remote | Comma-separated repos for `all` scope |
| `AGENT_LOOP_STATE_FILE` | .agent-loop/state.json | State file path |

## State file

This is the single definition of the state file. All agent-loop commands read and write this shape.

```json
{
  "cycle": 42,
  "started_at": "2026-10-19T00:00:00Z",
  "last_cycle_end": "2026-10-19T03:30:23Z",
  "shutdown_requested": false,
  "items_processed": 87,
  "items_autonomous": 34,
  "items_needs_review": 28,
  "items_deferred": 25,
  "prs_merged": 15,
  "active_threads": [3, 4],
  "thread_history": [
    {"id": 1, "item": "GH-123", "result": "merged", "pr": "#456"},
    {"id": 2, "item": "GH-124", "result": "failed", "reason": "test flake"}
  ],
  "last_error": null
}
```

Rules:

- Write atomically. Write to a temp file in the same directory, then rename.
- A valid state file parses as JSON and has `cycle`, `started_at`, and `thread_history`. Missing counters default to 0.
- Before overwriting or clearing state, copy it to `.agent-loop/backups/state-YYYY-MM-DD-HHmmss.json`. Keep the newest 50 backups.
- On load, any `active_threads` id with no running worker is orphaned. Record it in `thread_history` as `failed` with reason `orphaned` and remove it from `active_threads`.
