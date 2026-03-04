---
allowed-tools: Bash(git *), Bash(gh *)
description: Watch a PR, fix issues from AI reviews, and auto-merge when ready
---

# Watch and Fix PR

Watch a pull request, automatically fix issues identified in AI reviews, and merge when all checks pass.

## Usage

```bash
/github:watch-and-fix
/github:watch-and-fix --auto-merge
/github:watch-and-fix --max-iterations 5
/github:watch-and-fix --dry-run
```

## Options

- `--auto-merge`: Automatically merge PR when CI passes and reviews are approved
- `--max-iterations <n>`: Maximum fix iterations (default: 10)
- `--dry-run`: Preview what would happen without making changes
- `--pr <number>`: Specific PR number (default: current branch's PR)

## How It Works

### 1. Initial Check
- Verifies we're on a feature branch (not main/master)
- Finds the PR for current branch
- Checks initial CI status and review state

### 2. Watch Loop
For each iteration (max `--max-iterations`):

1. **Wait for CI**: Polls workflow run status until completion
2. **Check reviews**: Gets latest review comments from AI agents
3. **Parse issues**: Extracts fixable issues from review comments
4. **Fix issues**: Applies fixes based on review feedback
5. **Commit and push**: Commits fixes with semantic message
6. **Repeat**: Goes back to step 1

### 3. Completion
- **If CI passes AND approved**: Optionally merges (with `--auto-merge`)
- **If max iterations reached**: Reports status and stops
- **If no fixable issues found**: Reports and waits

## Review Comment Format

AI agents should format comments in a way that can be parsed:

```markdown
## Issues Found

### path/to/file.ts:45
- **Type**: type-error
- **Message**: Variable 'foo' is implicitly any
- **Fix**: Add type annotation: `const foo: string = ...`

### src/api/index.ts:123
- **Type**: lint-error
- **Message**: Missing error handling
- **Fix**: Wrap in try-catch block
```

## Exit Conditions

The loop exits when:
- ✅ CI passes AND PR is approved (merges if `--auto-merge`)
- ⚠️ Max iterations reached
- ⚠️ No fixable issues found but CI still failing
- ⚠️ Manual interrupt (Ctrl+C)

## Examples

### Basic watch and fix
```bash
# On a feature branch with an open PR
git checkout feat/new-feature
/github:watch-and-fix
```

### Watch and auto-merge when ready
```bash
# Will merge automatically when CI passes and approved
/github:watch-and-fix --auto-merge
```

### Limited iterations
```bash
# Try at most 3 times to fix issues
/github:watch-and-fix --max-iterations 3
```

### Preview mode
```bash
# See what would be fixed without making changes
/github:watch-and-fix --dry-run
```

## Implementation Notes

### CI Status Polling
```bash
# Get latest workflow run
RUN_ID=$(gh run list --workflow=ci.yml --branch $BRANCH --limit 1 --json databaseId --jq '.[0].databaseId')

# Watch the run
gh run watch "$RUN_ID"

# Check final status
STATUS=$(gh run view "$RUN_ID" --json conclusion --jq '.conclusion')
```

### Getting Review Comments
```bash
# Get all review comments
gh pr view $PR_NUMBER --json comments --jq '.comments[] | select(.author.type == "Bot")'
```

### Fix Application
```bash
# Parse comment and apply fix
# This is handled by the fix:and-push skill
```

## Permissions

Requires:
- `repo` scope for gh CLI
- Write access to push commits
- Write access to merge PRs (if using `--auto-merge`)

## Related Commands

- `/fix:and-update-pr` - Fix issues and update existing PR (single iteration)
- `/fix:and-create-pr` - Fix issues and create new PR
- `/github:bulk-merge-prs` - Merge multiple approved PRs
