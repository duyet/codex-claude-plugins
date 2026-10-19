---
allowed-tools: [Read, Bash, Glob, Grep, TodoWrite, Edit, Write, Task]
description: Fix failing CI or requested changes on an existing PR and push
---

# Fix and update PR

Input: optional PR number (default: the current branch's PR) and a specific issue to address.

1. Read the PR with `gh pr view <n> --comments` and `gh pr checks <n>`. Read failed logs with `gh run view <id> --log-failed`.
2. Follow `skills/fix-workflow/SKILL.md` for each failing check and requested change.
3. Push to the PR branch and report the PR URL.
