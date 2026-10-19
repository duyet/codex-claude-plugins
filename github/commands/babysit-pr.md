---
allowed-tools: Bash(git *), Bash(gh *), Read, Edit, Write, Glob, Grep, Agent
description: Drive a PR to merge-ready by fixing CI failures, review comments, and conflicts in a loop
---

# Babysit PR

Drive a pull request until CI is green, no review comments are unresolved, and there are no merge conflicts.

## Usage

```text
/github:babysit-pr [--pr <number>] [--auto-merge] [--max-iterations <n>] [--ci-timeout <minutes>] [--dry-run]
```

Defaults: the current branch's PR, 10 iterations, 15 minute CI timeout. Without `--auto-merge`, stop at merge-ready and report.

## Loop

Refuse to run on the default branch or with uncommitted changes. Then repeat up to the iteration limit.

1. Wait for CI to finish, plus a short grace period for review bots to post.
2. For each failing check, read the failed logs (`gh run view --log-failed`), fix the root cause, and run the failing check locally before pushing.
3. Fetch every review comment: inline, issue, and review comments. See the `review-bots` skill for bot formats. Apply actionable ones. Skip a suggestion that is wrong or out of scope and say why in a reply.
4. Merge the base branch if the PR conflicts and resolve conflicts by intent, not by taking one side.
5. Commit with a semantic message and push. Never force-push to a shared branch.
6. Stop when CI is green with nothing unresolved, or when the limit is reached. On the limit, report what is still failing.

## Merge

Only with `--auto-merge`. If repo auto-merge is already queued, wait for it. Otherwise `gh pr merge --squash --delete-branch`. Never use `--admin` unless the user asks.

## Report

End with iterations used, fixes applied, conflicts resolved, elapsed time, and the final PR state.
