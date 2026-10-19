---
allowed-tools: Bash, Read
description: Show agent-loop status. Use to see the current cycle, active workers, and recent results.
---

# Agent loop status

Read the state file (format in the `agent-loop-orchestrator` skill). Print the current cycle, uptime since `started_at`, active workers, the last N results from `thread_history` (`--history <n>`, default 5), and the totals. With `--json`, print the raw file. If no state file exists, say the loop has not started.
