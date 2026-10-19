---
name: github-workflow
description: Use when managing GitHub pull requests, issues, workflows, releases, or review-bot feedback with the gh CLI.
---

# GitHub workflow

Use `gh` non-interactively. Run `gh <command> --help` or read <https://cli.github.com/manual> for usage.

- Check remote, branch, and auth before mutating remote state.
- Read failed CI logs before changing code.
- Never merge with `--admin` unless the user explicitly permits it for that PR.
- Never force-push a shared branch.
- Never merge, auto-merge, update-branch, or bulk-process release-please PRs (`release-please--*` branches, `chore(main): release X.Y.Z`). Leave them to the user.
- Preserve unrelated local changes.
