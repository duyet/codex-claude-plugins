# GitHub plugin

Install: `/plugin install github@duyet-claude-plugins`. Requires an authenticated `gh` CLI.

- `github-workflow` skill: safety rules for `gh` use.
- `review-bots` skill: triage CodeRabbit, Sourcery, and Gemini comments.
- `/github:babysit-pr`: fix CI, comments, and conflicts until merge-ready.
- `/github:watch-and-fix`: alias for babysit-pr.
- `/github:review-and-merge`: triage open PRs, fix, and merge.
- `/github:bulk-merge-prs`, `/github:bulk-close-issues`, `/github:bulk-label`: bulk operations.
