---
name: commit-workflow
description: Use when the user asks to create a semantic commit, commit and push, or create a pull request from local changes.
---

# Commit Workflow

Use this skill to turn local repository changes into a clean semantic commit, and optionally push or open a pull request.

## Workflow

1. Inspect the current branch, git status, unstaged/staged diff, and recent commits.
2. Decide whether the change should be one commit or split into multiple focused commits.
3. Stage only the files that belong to the requested change.
4. Use semantic commit format: `type(scope): description`.
5. When creating a pull request, create a feature branch first if the current branch is the default branch.
6. Use the repo's existing pull request templates when present.

## Safety

- Do not include unrelated dirty work in the commit.
- Do not rewrite history unless the user explicitly asks.
- Prefer `--force-with-lease` over force push when a forced update is explicitly required.
