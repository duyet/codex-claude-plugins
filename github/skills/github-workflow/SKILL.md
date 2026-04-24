---
name: github-workflow
description: Use when managing GitHub pull requests, issues, workflows, releases, or review-bot feedback with the gh CLI.
---

# GitHub Workflow

Use this skill for GitHub operations in repositories that have the `gh` CLI available.

## Workflow

1. Inspect repository remote, current branch, and GitHub authentication before mutating remote state.
2. Use `gh pr`, `gh issue`, `gh run`, `gh workflow`, and `gh api` for GitHub operations.
3. For review-bot feedback, fetch inline comments and review bodies, then fix only actionable issues.
4. For CI failures, inspect failed run logs before changing code.
5. For merges, confirm branch status, required checks, and review state.

## Safety

- Avoid admin merges unless the user explicitly permits them.
- Preserve unrelated local changes.
- Prefer non-interactive `gh` commands with explicit flags.
