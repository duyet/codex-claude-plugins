---
allowed-tools: Bash, Read
description: Deeply inspect the agent-loop state file. View cycle history, thread details, errors, and state integrity. Useful for debugging and understanding loop status.
---

# Agent Loop Inspect

Deeply inspect the agent-loop state file and view detailed information about the loop's execution history.

Unlike `/agent-loop:status` which shows a summary, this command provides comprehensive details: thread-by-thread outcomes, error logs, corrupted state detection, and recovery hints.

## What You Get

- **State file path and size** — where state is stored and its integrity check
- **Cycle summary** — total cycles, current cycle number, last cycle time
- **Thread history** — all past threads with outcomes (passed, failed, needs_human)
- **Active threads** — threads still in progress (IDs, items, elapsed time)
- **Error log** — any errors encountered during threads or cycles
- **State validation** — checks for corruption, missing fields, inconsistencies
- **Recovery hints** — suggestions if state is corrupted or problematic

## Usage

```bash
# View full state details
/agent-loop:inspect

# View state as raw JSON
/agent-loop:inspect --json

# View only thread history
/agent-loop:inspect --threads

# View only recent errors
/agent-loop:inspect --errors --limit 10

# Validate state integrity (quick check)
/agent-loop:inspect --validate

# Inspect a backup state file
/agent-loop:inspect --backup state-2026-06-14-143022.json

# Show just the top-level metrics
/agent-loop:inspect --metrics
```

## Output Example

```text
═══════════════════════════════════════════════════════
Agent Loop State Inspection
═══════════════════════════════════════════════════════

State File: .agent-loop/state.json
Size: 4.2 KB
Last Modified: 2026-06-14 14:30:22 UTC
Integrity: ✓ VALID

─── Cycle Summary ──────────────────────────────────────
Current Cycle: #42
Started: 2026-06-11 00:00:00 UTC
Total Uptime: 3d 14h 30m
Last Cycle End: 2026-06-14 14:30:22 UTC
Total Cycles Completed: 41

─── Metrics ────────────────────────────────────────────
Items Processed: 87
  Autonomous: 34 (39%)
  Needs Review: 28 (32%)
  Deferred: 25 (29%)
PRs Merged: 15
Success Rate: 88% (30/34 autonomous succeeded)

─── Active Threads ─────────────────────────────────────
Thread-3: GH-234 | test flakiness fix | 2m 14s running
Thread-5: GH-235 | deps update | 45s running

─── Thread History (Last 5) ────────────────────────────
#41: Thread-2 GH-233 → ✓ merged (PR #456)
#41: Thread-1 GH-232 → ✗ failed (test timeout)
#40: Thread-4 GH-231 → ⚠ needs_review (manual check needed)
#39: Thread-3 GH-230 → ✓ merged (PR #455)
#38: Thread-2 GH-229 → ✓ merged (PR #454)

─── Error Log (Last 3) ─────────────────────────────────
[2026-06-14 14:25:00] Thread-1: Test timeout after 120s
[2026-06-14 14:10:00] Triage error: GitHub API rate limit
[2026-06-14 14:00:00] Thread-4: PR review blocked by CI failure

═══════════════════════════════════════════════════════
```

## Options

- `--json`: Output raw state as JSON (useful for parsing)
- `--threads`: Show thread history only
- `--metrics`: Show metrics summary only
- `--errors`: Show error log only
- `--errors --limit N`: Show last N errors (default: 10)
- `--active`: Show active threads only
- `--validate`: Check state file integrity (quick validation)
- `--backup <file>`: Inspect a backup file instead of current state
- `--deep`: Perform deep validation (checks for orphaned threads, inconsistencies)

## State Validation

When you run `--validate`, the inspector checks:
- ✓ State file exists and is readable
- ✓ Valid JSON structure
- ✓ Required fields present (cycle, started_at, items_processed, etc.)
- ✓ Field types are correct (numbers, strings, arrays, etc.)
- ✓ No orphaned threads (threads in history but marked as active)
- ✓ Timestamps are valid and chronologically ordered
- ✓ Metrics are consistent (e.g., autonomous + needs_review + deferred = total)

If validation fails, you'll see error details and recovery suggestions:
```
✗ INVALID state detected:
  Error: Missing required field 'started_at'
  Severity: CRITICAL
  Recovery: Use /agent-loop:restore to recover from backup, or /agent-loop:reset
```

## Backup Inspection

View details about any backup:
```bash
/agent-loop:inspect --backup state-2026-06-14-143022.json
```

This shows the same details as the current state, allowing you to compare before restoring.

## Related Commands

- `/agent-loop:status` — Quick summary of loop status
- `/agent-loop:restore` — Restore from a backup
- `/agent-loop:reset` — Clear state and start fresh
