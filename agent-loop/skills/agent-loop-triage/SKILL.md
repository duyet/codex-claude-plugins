---
name: agent-loop-triage
description: Scan a repo's open issues and PRs and classify each as autonomous, needs review, defer, or blocked. Use for the agent-loop triage phase or /agent-loop:triage.
---

# Agent loop triage

Scan open issues and PRs with `gh` (scope: `current`, `all` via `AGENT_LOOP_REPOS`, or `org`). Scan only from the default branch with a clean worktree, otherwise report and skip. Do not branch, stash, or commit.

Classes:

- **autonomous**: fixable and landable without a maintainer. Clear-repro bugfix, simple perf win, docs fix, dependency update with green CI, narrow test fix. Never new features, broad behavior changes, security-sensitive changes without strong proof, work needing keys you lack, or anything that cannot be tested end to end.
- **needs_review**: new features, wide blast radius, items against VISION.md, items with blocking maintainer comments.
- **defer**: stale (over 6 months, no maintainer signal), duplicate, superseded, no repro and no author reply.
- **blocked**: CI failing with no clear fix, merge conflict, missing access, awaiting a maintainer decision.

For every non-maintainer item, add a trust line from `gh api users/<login>`: `Trust: @login; acct <date>; repo <n> PRs/<n> issues; activity: low|medium|high`.

Output, one per item under its class heading, with the cycle number, repo, and scan counts first:

```text
- GH-123: Bug: login timeout on slow networks
  Type: bug | Fit: good | Risk: low
  Proof: repro in description, failing test in CI
  Trust: @contributor; acct 2024-01; previous merged PRs: 2
```

With `AGENT_LOOP_DEEP_SCAN` unset, limit a multi-repo scan to the 10 most active repos.
