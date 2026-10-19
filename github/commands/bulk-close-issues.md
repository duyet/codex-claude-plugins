---
allowed-tools: Bash(gh *)
description: Close multiple GitHub issues by label or search query
---

# Bulk close issues

Usage: `/github:bulk-close-issues [--label <name>] [--search <query>] [--comment <msg>] [--dry-run]`

List matches with `gh issue list`, show them, and confirm with the user before closing. `--dry-run` stops after the list.
