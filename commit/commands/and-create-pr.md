---
allowed-tools: Bash(git *), Bash(gh pr *)
description: Create a git commit with semantic commit message format and create a pull request
---

# Commit and Create PR

## Context

- Current Git status: !`git status`
- Current Git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Default branch: !`git remote show origin | grep 'HEAD branch' | cut -d' ' -f5`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes:

1. Stage all changes
2. Create a semantic commit
3. Push to remote (with `-u` if needed)
4. Create a pull request using `gh pr create`

## Commit Format

Follow semantic commit format: `type(scope): description`

Types: feat, fix, docs, style, refactor, test, chore

## PR Creation

Use `gh pr create` with:
- Title derived from commit message
- Body with summary of changes
- Target the default branch (main/master)

```bash
gh pr create --title "[TITLE]" --body "$(cat <<'EOF'
## Summary
[Brief description of changes]

## Changes
[List of modified files/features]

---
Generated with Claude Code
EOF
)"
```

## Execution

Call tools in sequence:
1. `git add .`
2. `git commit -m "type(scope): description"`
3. `git push -u origin [branch]`
4. `gh pr create --title "..." --body "..."`

Do not send any other text besides tool calls.
