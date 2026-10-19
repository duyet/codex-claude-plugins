---
description: Dispatch headless Command Code (`cmd`) workers to implement scoped tasks or GitHub issues in parallel, each in its own git worktree and branch.
---

# /command-code:dispatch

Work: **$ARGUMENTS**

Follow `skills/command-code/SKILL.md`. Split the work into independent units (one worker per issue), list the rest as follow-ups, and offer to do too-small work inline. Report each worker as slug, branch, worktree, and log. When workers finish, review each diff, note exit code 8, verify once, and report each branch as clean or needs-fix. Push and merge nothing without the user's say-so.
