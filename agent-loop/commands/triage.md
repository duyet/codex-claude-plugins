---
allowed-tools: Bash(git *), Bash(gh *), Read
description: Run one triage pass over repo issues and PRs and print the classified queue. Use for a snapshot without starting the loop.
---

# Agent loop triage

Flags: `--scope <current|all|org>`, `--org <name>`, `--repo <owner/repo>`, `--detail`, `--json`, `--limit <n>` (default 50).

Follow the `agent-loop-triage` skill and print its report. Change nothing.
