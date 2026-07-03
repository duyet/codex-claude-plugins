---
allowed-tools: [Read, Bash, Glob, Grep, TodoWrite, Edit, Write, Task]
description: "Fix issues/tests and update an existing pull request"
---

# /fix:and-update-pr - Fix and Update PR

## Purpose

Fix failing CI checks, tests, or requested changes on an existing pull request, commit the fixes, and push to update the PR.

## Usage

```
/fix:and-update-pr
```

```
/fix:and-update-pr 123

<optional: specific issue to address>
```

## Context Gathering

```bash
# Current branch
`git branch --show-current`

# PR information (if PR number provided as $ARGUMENTS)
`gh pr view $ARGUMENTS --json number,title,url,state,statusCheckRollup,headRefName,baseRefName 2>/dev/null || echo "No PR number provided"`

# Or find PR for current branch
`gh pr view --json number,title,url,state,statusCheckRollup 2>/dev/null || echo "No PR found for current branch"`
```

## Execution Flow

### Phase 1: PR Analysis
1. Identify the target PR (from argument or current branch)
2. Fetch PR status and CI check results:
   ```bash
   gh pr checks [PR_NUMBER]
   ```
3. Fetch review comments and requested changes:
   ```bash
   gh pr view [PR_NUMBER] --comments
   ```
4. Categorize issues:
   - CI failures (tests, lint, build)
   - Review feedback
   - Merge conflicts

### Phase 2: Issue Resolution

#### For CI Failures:
1. Fetch failure logs:
   ```bash
   gh run list --branch [BRANCH] --limit 5 --json databaseId,name,conclusion
   gh run view [RUN_ID] --log-failed
   ```
2. Analyze and fix each failure
3. Test fixes locally before pushing

#### For Review Feedback:
1. Parse review comments
2. Address each requested change
3. Reply to comments if clarification needed

#### For Merge Conflicts:
1. Fetch latest base branch
2. Resolve conflicts
3. Verify resolution doesn't break tests

### Phase 3: Fix Implementation

**Simple issues (1-2 files):**
- Fix directly in main agent

**Complex issues (3+ files):**
- Spawn parallel agents by domain:
  ```
  Main Agent (Coordinator)
  ├── Senior Agent 1: Backend fixes
  ├── Senior Agent 2: Frontend fixes
  ├── Senior Agent 3: Test fixes
  └── Main Agent: Integration & commit
  ```

### Phase 4: Push Update
1. Stage and commit with descriptive message:
   ```
   fix(pr): address CI failures and review feedback

   - Fix failing test in auth.spec.ts
   - Address review comment on error handling
   - Resolve ESLint warnings

   Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>
   ```
2. Push to PR branch
3. Report updated status

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PR #[NUMBER]: [TITLE]
Branch: [HEAD] → [BASE]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Issues Found:
❌ CI: ESLint - 3 errors
❌ CI: Unit Tests - 2 failures
📝 Review: 1 requested change

Fixes Applied:
✅ Fixed ESLint errors in src/utils.ts
✅ Fixed test assertions in auth.spec.ts
✅ Addressed review feedback on error handling

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Changes pushed to PR #[NUMBER]
Waiting for CI to complete...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Safety Limits

- **Max 3 fix attempts** per failing check
- **Never force push** unless explicitly requested
- **Always test locally** before pushing
- **Report and stop** if fix causes new failures

## Notes

- Requires GitHub CLI (`gh`) authenticated
- Will NOT merge the PR (use `/github:bulk-merge-prs` for merge)
- Preserves existing PR description and metadata
- Respects branch protection rules
