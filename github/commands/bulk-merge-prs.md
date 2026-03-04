---
allowed-tools: Bash(gh *)
description: Merge multiple approved pull requests at once
---

# Bulk Merge PRs

Merge multiple pull requests that are approved and ready to merge.

## Usage

```bash
/github:bulk-merge-prs --label "ready-to-merge"
/github:bulk-merge-prs --reviewer-approved
/github:bulk-merge-prs --search "status:success"
/github:bulk-merge-prs --dry-run --label "ready-to-merge"
```

## Options

- `--label <name>`: Merge all PRs with this label
- `--reviewer-approved`: Only merge PRs with approving reviews
- `--search <query>`: Use GitHub search syntax to find PRs
- `--method <merge|squash|rebase>`: Merge method (default: squash)
- `--delete-branch`: Delete branch after merge
- `--dry-run`: Preview what would be merged without executing

## Examples

```bash
# Merge all ready-to-merge PRs
/github:bulk-merge-prs --label "ready-to-merge"

# Merge approved PRs with squash
/github:bulk-merge-prs --reviewer-approved --method squash --delete-branch

# Merge PRs with passing CI
/github:bulk-merge-prs --search "status:success review:approved"

# Preview before merging
/github:bulk-merge-prs --dry-run --label "ready-to-merge"
```

## Implementation

1. List matching PRs with `gh pr list`
2. Check CI status and review status
3. Show preview of PRs to be merged
4. Confirm with user before merging
5. Merge each PR with specified method
6. Optionally delete branches
