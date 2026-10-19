---
name: fix-workflow
description: Use when fixing failing tests, lint, type errors, build, or CI, and then committing, pushing, or opening or updating a PR. The fix commands delegate here.
---

# Fix workflow

1. Detect the project's checks from its config files (package scripts, `pyproject.toml`, `Cargo.toml`, `go.mod`, Makefile, CI workflow). Prefer the commands CI runs.
2. Reproduce the failure first. If the user pasted errors or test names, start from those.
3. Fix the root cause with the smallest change. Do not weaken or delete a test to make it pass. Mock external services unless the test is about the integration.
4. Re-run the failing check, then the wider suite when the change touches shared code.
5. For three or more independent failures in different areas, spawn one subagent per area and integrate the results yourself.
6. Stop after three failed attempts at one issue. Report what was tried and do not push broken code.
7. Commit with a semantic message per the `commit` plugin's `commit-workflow` skill, include only files you changed, then push. Never merge.
