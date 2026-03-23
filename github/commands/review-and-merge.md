---
allowed-tools: Bash(git *), Bash(gh *), Bash(sleep *), Bash(pkill *), Bash(bun *), Read, Edit, Write, Glob, Grep, Agent
description: Review all open PRs, fix CodeRabbit/bot comments, resolve conflicts, and merge in parallel
---

# Review and Merge All PRs

Scan all open pull requests, read AI review bot comments (CodeRabbit, Sourcery, Gemini), fix issues, resolve merge conflicts, and merge when ready. Processes PRs in parallel using sub-agents.

## Usage

```bash
/github:review-and-merge
/github:review-and-merge --pr 123,456
/github:review-and-merge --skip 789
/github:review-and-merge --dry-run
```

## Options

- `--pr <numbers>`: Only process specific PRs (comma-separated)
- `--skip <numbers>`: Skip specific PRs
- `--dry-run`: Preview actions without making changes
- `--no-merge`: Fix issues but don't merge

## Process

### Phase 1: Triage All Open PRs

```bash
# List all open PRs with review status
gh pr list --state open --json number,title,headRefName,reviewDecision,mergeable,mergeStateStatus,statusCheckRollup,reviews

# Categorize each PR:
# A) CHANGES_REQUESTED by CodeRabbit → needs fixes
# B) Build/CI failures → investigate
# C) Merge conflicts → needs rebase
# D) Only known failures (Workers Builds, e2e) → can merge with --admin
# E) Clean and approved → merge immediately
```

Display a triage table:
```
| PR | Title | Review | Mergeable | Action |
|----|-------|--------|-----------|--------|
```

### Phase 2: Process PRs in Parallel

Launch sub-agents for each category. Use `run_in_background: true` for parallel execution.

#### Category A: Fix CodeRabbit Issues

For each PR with CHANGES_REQUESTED:

```bash
# Get CodeRabbit review comments
gh api repos/{owner}/{repo}/pulls/{pr}/reviews \
  --jq '.[] | select(.user.login == "coderabbitai[bot]") | {state: .state, body: .body}'

gh api repos/{owner}/{repo}/pulls/{pr}/comments \
  --jq '.[] | select(.user.login == "coderabbitai[bot]") | {path: .path, line: .line, body: .body}'
```

Spawn an agent per PR:
- Checkout the branch
- Read the CodeRabbit comments
- Read the affected files
- Fix ALL issues raised
- Run build verification (`bun run build` or project-specific)
- Commit with semantic format + co-authorship
- Push changes

#### Category B: Investigate Build Failures

For each PR with real build failures (not known CI issues):

```bash
# Get failed check logs
gh run view <run_id> --log-failed | grep -i "error\|Error\|FAIL" | head -30
```

- Identify if failure is code issue vs CI infrastructure
- If code issue: spawn fix agent
- If CI issue (missing secrets, flaky test): note and proceed to merge with --admin

#### Category C: Resolve Merge Conflicts

For PRs that are CONFLICTING:

```bash
git fetch origin
git checkout <branch>
git rebase origin/main
# Resolve conflicts: keep BOTH sides merged
git rebase --continue
bun run check:fix  # Fix lint/format
git push --force-with-lease
```

If multiple PRs conflict on the same files (cascade pattern):
- Merge non-overlapping PRs first
- Then process overlapping PRs sequentially (each merge changes the base)

#### Category D: Merge Clean PRs

PRs with only known CI failures and no review issues:

```bash
gh pr merge <number> --squash --admin \
  --subject "<semantic title> (#<number>)"
```

Known failures to ignore:
- `Workers Builds` — always fails on non-main branches
- `e2e-test` — cancelled/flaky
- `unit-tests` — known Jest hanging issue
- `claude-review` — config issues

### Phase 3: Post-Fix Verification

After agents push fixes:
1. Check if CodeRabbit re-reviewed and approved
2. Check if merge conflicts appeared (cascade from other merges)
3. Rebase if needed
4. Merge with `--admin` when ready

### Phase 4: Report

Print summary of all actions taken:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PR Review & Merge Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Merged:
  #938 feat(agents): add ask_user tool
  #939 feat(agents): add detect_anomalies tool
  ...

Fixed & Merged:
  #932 fix(explain): CodeRabbit issues resolved
  #936 feat(mcp): CodeRabbit issues resolved

Still Open:
  #123 reason: unresolvable conflict

Total: 15 merged, 2 fixed, 1 remaining
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Key Patterns

### Cascade Conflict Strategy

When multiple PRs modify the same files:
1. Identify overlapping file sets across all PRs
2. Group by conflict clusters
3. Merge non-overlapping PRs first (in parallel)
4. Process overlapping PRs sequentially (oldest first)
5. After each merge, rebase remaining PRs in the cluster

### Agent Delegation

- Use `team-agents:senior-engineer` for CodeRabbit fixes and conflict resolution
- Use `run_in_background: true` for parallel processing
- Limit to 3-4 concurrent agents to avoid OOM on builds
- Each agent: checkout → fix → build → commit → push

### Commit Convention

All fix commits must include:
```
Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>
```

### Safety

- Always use `--admin` flag for merging (bypasses known-broken checks)
- Never force-push to main
- Use `--force-with-lease` for branch pushes (prevents overwriting others' work)
- Check mergeability before attempting merge
