---
name: agent-loop-autoreview
description: Review a PR unattended, apply verified fixes from AI review bots (CodeRabbit, Sourcery, Gemini), validate, and merge when safe. Use for agent-loop workers or /agent-loop:autoreview.
---

# Agent loop autoreview

Stop and report if the PR is a draft or has a skip label (`wip`, `do-not-merge`, `blocked`, `hold`).

Use the `review-bots` skill of the github plugin to read bot comments, or fetch them with `gh api`. CodeRabbit's "Prompt for AI Agents" block is the most precise source.

- Verify each comment against the code. Bots file non-issues. Skip those with a one-line reason.
- Apply the smallest fix. No drive-by refactors.
- Run the project's own lint, typecheck, and nearby tests. Revert a fix that fails validation and record it as skipped.
- Skip and escalate anything touching auth, secrets, `.env`, or Dockerfiles, and any fix outside the files the comment named.
- Commit as `fix(pr): apply review bot suggestions` and push.

Merge only when asked (`--merge` or loop dispatch) and all hold: required checks pass (rerun a failure once to rule out a flake), no human requested changes, no conflicts, and the author is not a first-time contributor touching security-sensitive paths. Never use `--admin`. Never merge release-please PRs.

Report per PR: comments found, fixes applied, fixes skipped with reasons, validation results, and an outcome of `merged`, `pr_updated`, `blocked`, or `needs_human`.
