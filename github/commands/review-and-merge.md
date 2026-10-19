---
allowed-tools: Bash(git *), Bash(gh *), Read, Edit, Write, Glob, Grep, Agent
description: Triage every open PR, fix review-bot comments, CI, and conflicts in parallel, then merge the ready ones
---

# Review and merge open PRs

## Usage

```
/github:review-and-merge [--pr <n,n>] [--skip <n,n>] [--no-merge] [--dry-run]
```

## Steps

1. List open PRs with `gh pr list --state open --json number,title,headRefName,reviewDecision,mergeable,mergeStateStatus,statusCheckRollup`. Skip release-bot PRs (for example `release-please--*` branches) unless the user names them. Show a triage table with the next action per PR: fix review comments, fix CI, resolve conflicts, or merge.
2. With `--dry-run`, stop after the table.
3. Spawn one subagent per PR that needs work, each in its own worktree or checkout. Give it the PR number and tell it to follow `/github:babysit-pr` without `--auto-merge`. Use the `review-bots` skill for bot comment formats.
4. Merge a PR only when its required checks pass and nothing is unresolved: `gh pr merge <n> --squash --delete-branch`. Never pass `--admin` and never merge past a failing required check unless the user says so for that PR. Skip merging with `--no-merge`.
5. Report each PR's final state: merged, fixed and waiting, or blocked with the reason.
