---
name: agent-loop-autoreview
description: Review a PR unattended, apply verified fixes from AI review bots (CodeRabbit, Sourcery, Gemini), validate, and merge when safe. Use for agent-loop workers or /agent-loop:autoreview.
---

# Agent loop autoreview

## Gather

```bash
gh pr view <n> --json number,title,author,isDraft,labels,reviewDecision,mergeStateStatus,statusCheckRollup
gh pr diff <n>
gh api repos/{owner}/{repo}/pulls/{n}/comments \
  --jq '.[] | select(.user.login | test("coderabbit|sourcery|gemini-code-assist")) | {path, line, body, id}'
gh api repos/{owner}/{repo}/pulls/{n}/reviews --jq '.[] | {user: .user.login, state, body}'
```

Stop and report if the PR is a draft or carries a skip label (`wip`, `do-not-merge`, `blocked`, `hold`).

## Fix

For each bot comment, extract the path, line, issue, severity, and suggested fix. CodeRabbit's "Prompt for AI Agents" block is the most precise source. Then:

1. Read the code around the line and decide whether the comment is correct. Bots file non-issues. Skip those with a one-line reason.
2. Apply the smallest change that fixes it. No drive-by refactors.
3. Run the project's own lint, typecheck, and the tests near the change. Find the commands in package.json, pyproject.toml, Makefile, or CI config.
4. If validation fails, revert that fix and record it as skipped.

Skip and escalate anything that touches auth, secrets, `.env`, or Dockerfiles, and any fix that changes files the comment did not name.

## Commit

```bash
git add <changed files>
git commit -m "fix(pr): apply review bot suggestions"
git push
```

## Merge

Merge only when asked to (`--merge`, or the loop's dispatch said so) and all hold:

- Required checks pass. Rerun a failed check once to rule out a flake.
- No human review requests changes.
- No merge conflicts.
- The author is not a first-time contributor touching security-sensitive paths.

```bash
gh pr merge <n> --squash --delete-branch
```

## Report

One block per PR: bot comments found, fixes applied, fixes skipped with reasons, validation results, and the outcome (`merged`, `pr_updated`, `blocked`, or `needs_human`).
