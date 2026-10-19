---
name: fix-workflow
description: Use when fixing failing tests, lint, type errors, build, or CI, and then committing, pushing, or opening or updating a PR. The fix commands delegate here.
---

# Fix workflow

- Find the project's checks from its config and CI, and reproduce the failure first.
- Fix the root cause with the smallest change. Never weaken or delete a test to pass.
- Rerun the failing check, then the wider suite if shared code changed. Use one subagent per area for three or more independent failures.
- After three failed attempts on one issue, stop and report. Never push broken code.
- Commit per the `commit` plugin's `commit-workflow` skill, only files you changed. Never merge.
