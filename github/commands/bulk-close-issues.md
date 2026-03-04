---
allowed-tools: Bash(gh *)
description: Close multiple GitHub issues by label or search query
---

# Bulk Close Issues

Close multiple GitHub issues based on labels, status, or search criteria.

## Usage

```bash
/github:bulk-close-issues --label "wontfix"
/github:bulk-close-issues --label "duplicate" --comment "Closing as duplicate"
/github:bulk-close-issues --search "status:stale"
/github:bulk-close-issues --dry-run --label "wontfix"
```

## Options

- `--label <name>`: Close all issues with this label
- `--search <query>`: Use GitHub search syntax to find issues
- `--comment <message>`: Add closing comment to each issue
- `--state <open|closed>`: Filter by state (default: open)
- `--dry-run`: Preview what would be closed without executing

## Examples

```bash
# Close all stale issues
/github:bulk-close-issues --label "stale"

# Close duplicates with comment
/github:bulk-close-issues --label "duplicate" --comment "Closing as duplicate of #123"

# Close issues older than 90 days
/github:bulk-close-issues --search "updated:<2025-12-01"

# Preview before closing
/github:bulk-close-issues --dry-run --label "wontfix"
```

## Implementation

1. List matching issues with `gh issue list`
2. Show preview of affected issues
3. Confirm with user before closing
4. Close each issue with optional comment
