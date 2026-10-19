---
allowed-tools: Bash, Read, Write
description: Restore agent-loop state from a backup. Use after corruption, a crash, or an accidental reset.
---

# Agent loop restore

- `--list`: list files in `.agent-loop/backups/`, newest first, with cycle and timestamp.
- No argument: restore the newest valid backup.
- `<file>`: restore that backup.

Validate the backup against the State file section of the `agent-loop-orchestrator` skill before restoring. Back up the current state file first, then copy the backup into place. Print the restored cycle and suggest `/agent-loop:resume`.
