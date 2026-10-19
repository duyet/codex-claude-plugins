---
allowed-tools: [Read, Bash, Glob, Grep, TodoWrite, Edit, Write, Task]
description: Fix failing tests or checks and open a new pull request
---

# Fix and create PR

Input: optional PR title and base branch.

1. Follow `skills/fix-workflow/SKILL.md` to fix the failures.
2. If on the default branch, create a `fix/<short-description>` branch first.
3. Push with `git push -u origin <branch>` and run `gh pr create` against the base branch. Summarize the commits as bullets in the body.
4. Print the PR URL.
