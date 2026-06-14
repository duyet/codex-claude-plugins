---
allowed-tools: Bash, Read, Write
description: Clear the agent-loop state and start fresh. Creates a backup of the current state before clearing. Use this when you want to reset metrics and start a new loop session.
---

# Agent Loop Reset

Clear the agent-loop state and start a completely fresh loop.

This command backs up your current `.agent-loop/state.json` before clearing it, so you can always recover if needed.

## Use Cases

- **Clean slate** — Start a new loop session with fresh metrics
- **Corrupted state** — If state.json becomes corrupted, reset and start over (backup is preserved)
- **Cycle restart** — Reset cycle counter and reprocess items
- **Metrics cleanup** — Clear accumulated statistics and start counting fresh

## What Gets Cleared

- Current cycle count → resets to 0
- Items processed → resets to 0
- Thread history → fully cleared
- Active thread list → reset
- All metrics and statistics → fresh start

## What Gets Preserved

The current state.json is **backed up** before clearing:
- Backup location: `.agent-loop/backups/state-YYYY-MM-DD-HHmmss.json`
- Use `/agent-loop:restore` to recover the backup if needed

## Usage

```bash
# Reset with confirmation prompt
/agent-loop:reset

# Force reset without confirmation
/agent-loop:reset --force

# Reset and show backup location
/agent-loop:reset --show-backup
```

## Options

- `--force`: Skip confirmation prompt and reset immediately
- `--show-backup`: Display the backup file path after reset
- `--keep-logs`: Keep .agent-loop/logs/ (default: clears logs too)

## After Reset

Once reset completes, you can:
1. Start a fresh loop: `/agent-loop:start`
2. Inspect what was backed up: `/agent-loop:inspect --backup <backup-file>`
3. Restore if you changed your mind: `/agent-loop:restore <backup-file>`

## Backup Management

All backups are stored in `.agent-loop/backups/`:
```
.agent-loop/backups/
├── state-2026-06-14-143022.json  # Created by reset
├── state-2026-06-14-120015.json  # Created by previous reset
└── state-2026-06-13-235959.json  # Older backup
```

Use `/agent-loop:restore --list` to see all available backups.
