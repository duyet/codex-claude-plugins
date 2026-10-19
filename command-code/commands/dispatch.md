---
description: Dispatch headless Command Code (`cmd`) workers to implement scoped tasks or GitHub issues in parallel, each in its own git worktree and branch.
---

# /command-code:dispatch

Work: **$ARGUMENTS**

Follow the dispatch workflow in `skills/command-code/SKILL.md`.

1. Turn `$ARGUMENTS` into independent units: one worker per issue number, or a larger task split into separately committable pieces. Dispatch only independent pieces now and list the rest as follow-ups. If the work is too small or not separable, offer to do it inline.
2. Check preconditions and get consent, then write a spec, create a worktree, and launch each worker as the skill describes.
3. Report each worker as slug, branch, worktree, and log path.
4. As workers finish, review each diff, note any that exited with code 8, run one consolidated verification, and report each branch as clean or needs-fix. Push and merge nothing without the user's say-so.
