---
name: commit-workflow
description: Use when creating a semantic commit, committing and pushing, or opening a pull request from local changes. The commit commands delegate here.
---

# Commit workflow

1. Read git status, the diff against HEAD, the current branch, and recent commits to match the repo's style.
2. Split unrelated changes into separate commits. Stage only files that belong to the change, never unrelated dirty work.
3. Message format is `type(scope): description` in the imperative. Types: feat, fix, docs, style, refactor, test, chore.
4. Push only when asked. Prefer `--force-with-lease` and only when a forced update is requested. Do not rewrite history otherwise.

## Pull requests

- On the default branch, first create a branch named `<type>/<short-kebab-description>`.
- Push with `git push -u origin <branch>`, then `gh pr create`. Title matches the commit message. Add `--draft` when asked.
- Body: use the repo's own PR template if it has one. Otherwise pick from `.pr-templates/` in this plugin by commit type: `fix` uses `bugfix.md`, `feat` uses `feature.md`, anything else uses `default.md`. Fill in the placeholders. If no template is found, write a short summary and change list.
- Print the PR URL when done.
