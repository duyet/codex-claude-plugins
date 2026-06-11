---
name: agent-loop-autoreview
description: >-
  Autonomous code review and fix skill for the agent-loop plugin. Reviews PRs,
  applies fixes from AI review bots (CodeRabbit, Sourcery, Gemini), validates
  changes, and lands them. Designed for unattended overnight operation.
---

# Agent Loop Autoreview

Autonomously review and fix pull requests. This skill:

1. Identifies PRs needing review (new, updated, or with review comments)
2. Reads review bot suggestions from CodeRabbit/Sourcery/Gemini
3. Applies verified fixes
4. Runs validation (lint, test, build)
5. Commits and pushes fixes, or merges when green

## PR Discovery

Find PRs that need attention:

```bash
# PRs with review comments from bots
gh pr list --state open --json number,title,author,updatedAt --limit 20

# Check for unresolved review threads (bot-originated)
gh api repos/{owner}/{repo}/pulls/{pr}/reviews \
  --jq '.[] | select(.state == "CHANGES_REQUESTED") | {user: .user.login, body: .body}'
```

## Fetch Review Comments

### CodeRabbit Comments

```bash
# All review threads
gh api repos/{owner}/{repo}/pulls/{pr}/reviews \
  --jq '.[] | select(.user.login | test("coderabbit")) | {id, body, state}'
```

### Inline Comments

```bash
gh api repos/{owner}/{repo}/pulls/{pr}/comments \
  --jq '.[] | select(.user.login | test("coderabbit|sourcery|gemini-code-assist")) | {path, line, body, id}'
```

## Apply Fixes

### Extraction

From each review comment, extract:
- **File path** and **line number**
- **Issue description** and **severity** (critical, high, medium, low)
- **Suggested fix** or **agent prompt** (from `🤖 Prompt for AI Agents` section)
- **Type** (bug, security, performance, style, docs)

### Fix Application Workflow

```
1. Read file at specified path+line
2. Understand the issue context
3. Apply fix (minimal change, no refactoring)
4. Validate:
   - Edit tool → file changed
   - LSP diagnostics clean
   - Run project linter: npm run lint / ruff / etc
   - Run relevant tests
5. If validation fails → log error, skip, report
```

### Validation Commands

```bash
# TypeScript/JS
npx tsc --noEmit 2>&1 | head -50
npm run lint 2>&1 | head -50
npm run test -- --run 2>&1 | tail -50

# Python
ruff check . 2>&1 | head -30
pytest -x --timeout=60 2>&1 | tail -50

# General
git diff --stat
```

## Commit and Push

After applying all fixes for a PR:

```bash
git add -A
git commit -m "fix(pr): apply review bot suggestions

- Applied N fixes from CodeRabbit/Sourcery/Gemini

Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>"
git push
```

## Merge When Ready

Check merge readiness:

```bash
gh pr view <n> --json mergeStateStatus,reviewDecision,statusCheckRollup
```

Conditions for auto-merge:
1. All required status checks passing
2. No unresolved review threads requesting changes
3. No merge conflicts

```bash
# Merge
gh pr merge <n> --squash --delete-branch
```

## Safety Gating

**Never auto-merge when:**
- PR is a draft
- PR has `WIP`, `do-not-merge`, `blocked`, or `hold` label
- PR has unresolved human review requesting changes
- CI has failing required checks (flake retry 1x first)
- PR changes security-sensitive paths (`Dockerfile`, `.env`, secrets, auth)
- PR is from an untrusted first-time contributor (check trust)

**Log every decision:**
```
Autoreview: PR #123
  Bot comments: 3 (CodeRabbit: 2, Sourcery: 1)
  Fixes applied: 2
  Skipped: 1 (suggestion only, not actionable)
  Validation: lint ✅, test ✅, build ✅
  Result: merged as abc1234
```

## Failure Handling

| Scenario | Action |
|----------|--------|
| Fix fails validation | Revert, log error, skip |
| CI flake | Retry once after 60s |
| Merge conflict | Report as blocked |
| Unknown file changed by fix | Skip, flag for review |
| Critical security issue | Skip, escalate in report |
