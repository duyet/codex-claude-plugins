---
name: commit-workflow
description: Use when creating a semantic commit, committing and pushing, or opening a pull request from local changes. The commit commands delegate here.
---

# Commit workflow

- Match the repo's recent commit style. Message format is `type(scope): description`, imperative.
- Split unrelated changes into separate commits. Stage only files that belong to the change.
- Push only when asked. Never rewrite history. Use `--force-with-lease` only on a requested forced update to a non-shared branch.

Pull requests:

- On the default branch, branch first as `<type>/<short-kebab-description>`.
- Title matches the commit message. Use the repo's own PR template if it has one, else `.pr-templates/` in this plugin by commit type: `fix` uses `bugfix.md`, `feat` uses `feature.md`, anything else `default.md`. Fill the placeholders.
- Print the PR URL when done.
