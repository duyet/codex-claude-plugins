---
allowed-tools: Bash(gh *)
description: Add or remove labels across multiple issues or pull requests, selected by label or GitHub search query
---

# Bulk Label

Add or remove labels from multiple issues or pull requests at once.

## Usage

```bash
/github:bulk-label --add "priority:high" --label "bug"
/github:bulk-label --remove "status:triage" --search "is:open"
/github:bulk-label --add "area:backend" --type pr
/github:bulk-label --dry-run --add "needs-review"
```

## Options

- `--add <label>`: Label to add (can be used multiple times)
- `--remove <label>`: Label to remove (can be used multiple times)
- `--label <name>`: Target issues/PRs with this label
- `--search <query>`: Use GitHub search syntax to find items
- `--type <issue|pr>`: Filter by type (default: both)
- `--dry-run`: Preview what would be changed without executing

## Examples

```bash
# Add priority label to all bugs
/github:bulk-label --add "priority:high" --label "bug"

# Remove triage label from reviewed items
/github:bulk-label --remove "status:triage" --search "reviewed-by:@me"

# Add area labels to backend PRs
/github:bulk-label --add "area:backend" --type pr --search "file:src/api/*"

# Apply multiple labels at once
/github:bulk-label --add "priority:urgent" --add "needs-review" --label "bug"

# Preview changes
/github:bulk-label --dry-run --add "quarter-1" --search "created:>=2025-01-01"
```

## Implementation

1. List matching items with `gh issue list` or `gh pr list`
2. Show preview of label changes
3. Confirm with user before applying
4. Add/remove labels from each item
