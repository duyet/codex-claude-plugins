---
allowed-tools: Bash(gh *)
description: Add or remove labels across multiple issues or pull requests, selected by label or GitHub search query
---

# Bulk label

Usage: `/github:bulk-label [--add <label>]... [--remove <label>]... [--label <name>] [--search <query>] [--type issue|pr] [--dry-run]`

List matches with `gh issue list` or `gh pr list`, show the planned changes, and confirm with the user before applying. `--dry-run` stops after the list.
