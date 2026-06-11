---
name: agent-loop-triage
description: >-
  GitHub project triage for the agent-loop plugin. Scans open issues, PRs, CI
  queues, and blockers. Classifies items by fit, risk, proof, and autonomy.
  Adapted from github-project-triage for autonomous loop integration.
---

# Agent Loop Triage

Scan open issues and PRs for the current repo (or a configured set of repos).
Classify each item and return a structured queue summary suitable for the
orchestrator loop's dispatch phase.

## Setup

### GitHub CLI Check

```bash
gh auth status 2>/dev/null || { echo "gh not authenticated"; exit 1; }
```

### Current Repo Detection

```bash
repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true)
if [ -z "$repo" ]; then
  url=$(git remote get-url origin 2>/dev/null || true)
  repo=$(printf '%s\n' "$url" |
    sed -E 's#^git@github.com:##; s#^https://github.com/##; s#\.git$##')
fi
printf '%s\n' "$repo"
```

### Repo Readiness

```bash
git status --short --branch
git branch --show-current
git pull --ff-only
git status --short --branch
```

Proceed only on `main` with clean worktree. If dirty or non-main, report and
skip — do not branch/stash/commit without instruction.

## Triage Pass (Issue Queue)

```bash
gh issue list --repo "$repo" --state open --limit 50 \
  --json number,title,author,labels,createdAt,updatedAt,url
```

## Triage Pass (PR Queue)

```bash
gh pr list --repo "$repo" --state open --limit 50 \
  --json number,title,author,isDraft,reviewDecision,mergeStateStatus,createdAt,updatedAt,url
```

## Detail Pass

For items that look actionable:

```bash
# Issue detail
gh issue view <n> --repo "$repo" \
  --json number,title,author,body,comments,labels,createdAt,updatedAt,url

# PR detail
gh pr view <n> --repo "$repo" \
  --json number,title,author,body,comments,files,commits,isDraft,reviewDecision,mergeStateStatus,statusCheckRollup,createdAt,updatedAt,url

# PR diff for small changes
gh pr diff <n> --repo "$repo" --patch
```

## Classification

Classify each item into one of:

### Autonomous — can fix/land without maintainer

Qualifies when:
- Bugfix with clear repro, known root cause, and verification path
- Performance improvement that doesn't increase complexity
- Documentation fix
- Dependency update with passing CI
- Small UI tweak that follows existing patterns
- Narrow test/internal fix

Does NOT qualify when:
- New feature or product/vision choice
- Broad behavior change
- Security-sensitive change without strong proof
- Anything needing live API keys you don't have
- Anything that can't be end-to-end tested

### Needs Review — requires maintainer judgment

- New features
- Risk changes (broad blast radius)
- Items not matching VISION.md
- Items with blocking maintainer comments

### Defer/Close

- Stale (>6mo no activity, no maintainer signal)
- Duplicate
- Superseded by another PR/issue
- No repro for bug, no response from author

### Blocked

- CI failing with no clear fix
- Merge conflict
- Missing required credentials/access
- Awaiting maintainer decision

## Trust Signals

Include author trust for every non-maintainer item:

```bash
# Quick trust check
gh api users/<login> --jq '{login, created_at, public_repos}'
```

Output format:
```
Trust: @login; acct 2023-04-03; repo 2 PRs/1 issue; activity: low/medium/high
```

## Output Format

Return structured triage output suitable for the orchestrator:

```text
Cycle #42 — Triage Report
Repo: owner/name
Scanned: 12 issues, 5 PRs

Autonomous (3):
- GH-123: Bug — login timeout on slow networks
  Type: bug | Fit: good | Risk: low
  Proof: repro in description, failing test in CI
  Trust: @contributor; acct 2024-01; previous merged PRs: 2
  → Dispatch to thread

- GH-124: Deps — update lodash to 4.17.21
  Type: dependency | Fit: good | Risk: low
  Proof: green CI
  → Dispatch to thread

Needs Review (1):
- GH-125: Feature — dark mode toggle
  Type: feature | Fit: mixed | Risk: medium
  → Flag for maintainer

Defer/Close (2):
- GH-126: Stale (8mo no activity)
- GH-127: Duplicate of GH-120
```

## Scope Rule

- `current` (default): triage only the current repo
- `all`: triage all repos in AGENT_LOOP_REPOS or detected from gh
- `org`: triage all repos under the current org

## Broad Scan (all/org scope)

```bash
# Find repos with open issues/PRs
gh search repos --owner <org> --sort updated \
  --json nameWithOwner,openIssuesCount,openPullRequestsCount
```

For each repo with open items, run the standard triage pass.
Limit to top 10 repos by activity unless `AGENT_LOOP_DEEP_SCAN` is set.
