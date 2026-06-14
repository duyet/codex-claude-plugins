---
allowed-tools: Bash, Read, Write
description: Restore agent-loop state from a backup. List available backups, restore from a specific backup, or use the most recent backup to recover from corruption or accidents.
---

# Agent Loop Restore

Restore the agent-loop state from a backup, either the most recent or a specific timestamped backup.

Use this command to recover after state.json corruption, accidental resets, or loop crashes where state was inconsistent.

## Why Restore?

You might need to restore in these scenarios:

- **State corruption** — state.json became corrupted (bad JSON, missing fields)
- **Accidental reset** — you ran `/agent-loop:reset` by mistake
- **Loop crash** — the loop crashed and left state in an inconsistent state
- **Wrong start** — you started fresh but wanted to resume from before
- **Recovery** — the loop stopped unexpectedly and you want to pick up where it left off

## What Gets Restored

When you restore from a backup, you recover everything from that point in time:
- Cycle count, started time, uptime
- All processed items count and classification history
- Thread history and outcomes
- Active thread list and metrics
- All statistics accumulated up to that backup

## Usage

```bash
# List all available backups
/agent-loop:restore --list

# Restore from most recent backup
/agent-loop:restore

# Restore from specific backup (interactive menu)
/agent-loop:restore --select

# Restore from specific backup (by name)
/agent-loop:restore state-2026-06-14-143022.json

# Restore and verify before committing
/agent-loop:restore --preview state-2026-06-14-143022.json

# Restore and keep current state as backup
/agent-loop:restore --keep-current state-2026-06-14-143022.json
```

## Options

- `--list`: Show all available backups with timestamps and sizes
- `--select`: Interactive menu to choose from available backups
- `--preview`: Show what will be restored without actually restoring
- `--keep-current`: Backup current state.json before restoring (safety)
- `--force`: Restore without confirmation prompt
- `--verify`: Verify backup integrity before restoring

## Output Example

```
Available Backups
═════════════════════════════════════════════════════════════
1  state-2026-06-14-143022.json  (Jun 14, 2:30 PM)  4.2 KB
2  state-2026-06-14-120015.json  (Jun 14, 12:00 PM) 4.1 KB
3  state-2026-06-13-235959.json  (Jun 13, 11:59 PM) 3.9 KB

Most recent: #1 (2 hours ago)

Use: /agent-loop:restore <filename>
     /agent-loop:restore --select
```

## Restore Workflow

### Scenario 1: Quick Restore (Most Recent)

```bash
# Restore from most recent backup
/agent-loop:restore

# Loop continues from restored state
/agent-loop:start --resume
```

### Scenario 2: Previewing Before Restore

```bash
# See what will be restored
/agent-loop:restore state-2026-06-14-143022.json --preview

# Inspect the backup details
/agent-loop:inspect --backup state-2026-06-14-143022.json

# Then restore if it looks good
/agent-loop:restore state-2026-06-14-143022.json --keep-current
```

### Scenario 3: Selecting from Menu

```bash
# Interactive menu
/agent-loop:restore --select

# Choose from menu (1-3)
# 1  state-2026-06-14-143022.json
# 2  state-2026-06-14-120015.json
# 3  state-2026-06-13-235959.json

# Shows preview, ask for confirmation, then restores
```

## Backup Retention

Backups are kept in `.agent-loop/backups/`:
- **Auto-created** when you run `/agent-loop:reset` or `/agent-loop:start --fresh`
- **Named with timestamp** for easy identification: `state-YYYY-MM-DD-HHmmss.json`
- **Kept indefinitely** (you can manually clean old ones)
- **Max 50** backups automatically (oldest auto-deleted)

## Listing Backups

```bash
# Show all backups
/agent-loop:restore --list

# Show backups from last 7 days
/agent-loop:restore --list --since 7d

# Show with detailed metrics
/agent-loop:restore --list --details
```

## Safety Features

All restore operations have safeguards:
1. **Confirmation prompt** — asks before overwriting current state
2. **Backup of current** — can save current state before restoring (use `--keep-current`)
3. **Integrity check** — validates backup before using it
4. **Verification** — use `--preview` to see what will be restored
5. **Rollback** — if restore fails, current state is preserved

## After Restore

Once restored, you can:
1. Inspect the restored state: `/agent-loop:inspect`
2. Resume the loop: `/agent-loop:start --resume`
3. Or start fresh if restore revealed issues: `/agent-loop:reset`

## Related Commands

- `/agent-loop:inspect` — View details about state or backups
- `/agent-loop:reset` — Clear state (creates backup automatically)
- `/agent-loop:status` — Quick status check of current state
