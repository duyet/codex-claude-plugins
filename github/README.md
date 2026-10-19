# GitHub plugin

GitHub operations with the `gh` CLI: PR babysitting, review-bot feedback, and bulk issue and PR changes.

## Install

```
/plugin install github@duyet-claude-plugins
```

## What ships

Skills:
- `github-workflow` - rules for safe `gh` use
- `review-bots` - how to read CodeRabbit, Sourcery, and Gemini comments

Commands:
- `/github:babysit-pr` - fix CI, review comments, and conflicts until the PR is merge-ready
- `/github:watch-and-fix` - alias for babysit-pr
- `/github:review-and-merge` - triage open PRs, fix review feedback, and merge
- `/github:bulk-merge-prs` - merge approved PRs with passing CI
- `/github:bulk-close-issues` - close issues by label or query
- `/github:bulk-label` - label many issues or PRs

Requires an authenticated `gh` CLI.
