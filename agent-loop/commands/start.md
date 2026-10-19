---
allowed-tools: Bash, Read, Write, Task, Agent
description: Start the agent-loop repo maintenance cycle. Use to begin unattended triage, fix, and merge work on the current repo or a set of repos.
---

# Agent loop start

Flags: `--interval <seconds>`, `--scope <current|all|org>`, `--max-concurrency <n>`, `--repos <owner/repo,...>`, `--fresh`, `--resume`, `--dry-run`.

1. If `.agent-loop/state.json` exists and neither `--fresh` nor `--resume` was passed, ask the user whether to resume, start fresh, or inspect first. `--fresh` backs up the old state and starts at cycle 0. `--resume` clears `shutdown_requested` and then behaves like `/agent-loop:resume`.
2. With `--dry-run`, run triage only and print what would be dispatched.
3. Otherwise run one cycle per the `agent-loop-orchestrator` skill, then set up recurring runs per its Scheduling section.

The state file format lives in that skill's State file section.
