---
allowed-tools: Bash(git *), Bash(gh *), Read, Edit, Write, Task, Agent
description: Review one PR, apply verified fixes from AI review bots, validate, and optionally merge. Use for a single PR without starting the loop.
---

# Agent loop autoreview

Flags: `--pr <number>` (default: current branch's PR), `--repo <owner/repo>`, `--merge`, `--dry-run`, `--skip-labels <label,...>` (default `wip,do-not-merge,blocked`).

Follow the `agent-loop-autoreview` skill for that PR. Merge only with `--merge`. With `--dry-run`, report planned fixes and change nothing.
