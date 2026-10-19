---
allowed-tools: Bash, Read, Write
description: Stop the agent-loop gracefully. Use when the user wants the maintenance cycle to end.
---

# Agent loop stop

1. Set `shutdown_requested: true` in the state file (format in the `agent-loop-orchestrator` skill).
2. Without `--force`, wait up to 120 seconds for active workers to finish. With `--force`, stop them now and record them as `failed` with reason `stopped`.
3. Cancel any recurring run you set up for the loop in this harness.
4. Print cycles completed, items processed, PRs merged, and total duration.
