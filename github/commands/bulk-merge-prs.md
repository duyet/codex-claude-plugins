---
allowed-tools: Bash(gh *)
description: Merge multiple approved pull requests at once
---

# Bulk merge PRs

Usage: `/github:bulk-merge-prs [--label <name>] [--reviewer-approved] [--search <query>] [--method merge|squash|rebase] [--delete-branch] [--dry-run]`

List matches with `gh pr list`, check CI and review state, show the list, and confirm with the user before merging. Default method is squash. Skip release-please PRs. Never use `--admin`. Skip any PR with a failing required check.
