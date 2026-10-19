---
allowed-tools: Bash, Read, Write
description: Clear agent-loop state after backing it up. Use to start counting from zero.
---

# Agent loop reset

Refuse while workers are active unless `--force`. Ask for confirmation unless `--force`. Back up the state file per the `agent-loop-orchestrator` skill, then delete it. Print the backup path and point to `/agent-loop:restore` for undo.
