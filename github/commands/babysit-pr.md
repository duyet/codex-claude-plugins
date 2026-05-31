---
allowed-tools: Bash(git *), Bash(gh *), Read, Edit, Write, Glob, Grep, Agent, Task(general-purpose,code-review)
description: Babysit a PR - monitor, auto-fix review comments, ensure CI is green, handle auto-merge, and merge when ready
---

# Babysit PR

Continuously monitor a pull request with intelligent automation:
- **Auto-address code review comments** from AI bots (CodeRabbit, Sourcery, Gemini) and human reviewers
- **Auto-fix CI failures** by analyzing logs, fixing issues, and retrying
- **Keep PR in green state** by monitoring CI checks and resolving blockers
- **Smart merge handling** for repos with auto-merge enabled
- **Effort tracking** — reports total fixes, conflicts, and duration at completion

## Usage

```bash
/github:babysit-pr
/github:babysit-pr --pr 123
/github:babysit-pr --auto-merge
/github:babysit-pr --fix-ci                    # Auto-fix CI failures
/github:babysit-pr --force-merge               # Force merge even if auto-merge is stuck
/github:babysit-pr --max-iterations 10
/github:babysit-pr --ci-timeout 30             # CI wait timeout in minutes
/github:babysit-pr --dry-run
```

## Options

- `--pr <number>`: Specific PR number (default: current branch's PR)
- `--auto-merge`: Merge PR when CI passes and all review comments are resolved
- `--fix-ci`: Attempt to auto-fix CI failures by analyzing error logs
- `--force-merge`: Force merge via API even if auto-merge is stuck (use with caution)
- `--max-iterations <n>`: Maximum fix iterations (default: 10)
- `--ci-timeout <n>`: Maximum minutes to wait for CI (default: 15)
- `--dry-run`: Preview what would happen without making changes

## How It Works

### 1. Initial Setup
- Verify we're on a feature branch (not main/master)
- Find the PR for current branch (or use `--pr`)
- Check if repo has auto-merge enabled (for later handling)
- Record start time for effort tracking
- Validate git state (no uncommitted changes)

### 2. Babysit Loop

For each iteration:

#### Step A: Wait for CI and Reviews
- Poll CI status until all checks complete (timeout per `--ci-timeout`, default 15 min)
- Track which checks are failing vs passing
- Wait for review bots to post their comments (30s grace period after CI completes)

**Auto-fix CI Failures (if `--fix-ci`):**
```bash
# Get CI workflow run details
gh api repos/{owner}/{repo}/actions/runs/{run_id}

# Download and analyze CI logs
gh run view $RUN_ID --log

# Parse error messages and attempt smart fixes:
# - Linting errors → run linter auto-fix (eslint --fix, prettier, etc.)
# - Type errors → analyze TS/flow errors and fix types
# - Test failures → analyze stack trace and fix tests/code
# - Build errors → fix build config or dependency issues
```

If CI check fails after analysis:
1. Attempt automatic fix using code understanding (not trial-and-error)
2. Run specific failing check locally to verify fix
3. Commit fix and push (this triggers new CI run)
4. Re-poll CI status

#### Step B: Fetch ALL Review Comments
Read all review comments — both from AI bots and human reviewers:

**Known AI Review Bots:**

| Bot | Username Pattern | Comment Style |
|-----|-----------------|---------------|
| CodeRabbit | `coderabbitai[bot]` | Structured markdown with file paths, actionable suggestions, and code blocks |
| Sourcery | `sourcery-ai[bot]` | Inline suggestions with refactoring advice and quality scores |
| Gemini | `gemini-code-assist[bot]` | Code review with inline suggestions and summary |

**Fetch all comments (bots + humans):**
```bash
# Top-level PR comments (summaries, discussion)
gh api repos/{owner}/{repo}/issues/{pr}/comments

# Inline review comments (line-specific suggestions from all reviewers)
gh api repos/{owner}/{repo}/pulls/{pr}/comments

# Review threads with verdicts
gh api repos/{owner}/{repo}/pulls/{pr}/reviews

# Human review requests with changes requested
gh pr view $PR_NUMBER --json reviews --jq '.reviews[] | select(.state == "CHANGES_REQUESTED")'
```

Both AI bot suggestions and human reviewer feedback are processed. AI bot comments are parsed for structured suggestions; human comments are read as instructions and addressed with code understanding.

#### Step C: Check for Merge Conflicts
```bash
# Fetch latest base branch
git fetch origin $(gh pr view --json baseRefName --jq '.baseRefName')

# Check if merge is possible
git merge-tree $(git merge-base HEAD origin/main) HEAD origin/main
```

If conflicts exist:
1. Attempt automatic resolution
2. If auto-resolution fails, analyze conflict markers and resolve using code understanding
3. Commit resolution

#### Step D: Apply Fixes from ALL Review Suggestions
For each unresolved review comment (bot or human):
1. Parse the file path and line number from the comment
2. Read the suggested change or instruction
3. For bot comments: extract structured suggestions (code blocks, diffs)
4. For human comments: read the instruction and apply using code understanding
5. Apply the fix intelligently (understand intent, don't blindly replace)
6. Validate fix (run tests, lint checks if applicable)
7. Track the fix in effort report

**Auto-integrate suggestions from other agents:**
- Monitor for comments from other AI agents (autofix agents, ML agents)
- Parse structured fix suggestions from agent comments
- Apply verified, safe suggestions automatically
- Flag suspicious or conflicting suggestions for manual review

#### Step E: Commit and Push
```bash
git add -A
git commit -m "fix(pr): address review bot suggestions

- Applied N fixes from CodeRabbit/Sourcery/Gemini
- Resolved merge conflicts (if any)

Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>"

git push
```

#### Step F: Check Completion
Exit loop if:
- CI passes (all green) AND no unresolved review comments → ready to merge
- Max iterations reached → report and stop
- Critical error → report and stop

### 3. Smart Merge Logic

#### Detect Auto-Merge Status
```bash
# Check if auto-merge is enabled and what merge strategy
gh api repos/{owner}/{repo}/pulls/{pr_number} --jq '.autoMerge'

# Possible states:
# - enabled: auto-merge queued (will merge when ready)
# - disabled: auto-merge off
# - conflicted: enabled but blocked by conflicts or checks
```

#### Merge Strategy (Priority Order)
1. **Auto-merge enabled & CI green** → Wait for auto-merge to complete (poll every 30s)
2. **Auto-merge enabled but stuck** → Use `--force-merge` to manually trigger API merge
3. **Auto-merge disabled** → Use direct `gh pr merge` command
4. **Merge conflicts** → Resolve conflicts, push, then retry merge

#### Force Merge (for stuck auto-merge)
```bash
# If auto-merge is enabled but not progressing, trigger via API
gh api repos/{owner}/{repo}/pulls/{pr_number}/merge \
  --input - <<EOF
{
  "commit_title": "Merge PR #{pr_number}",
  "commit_message": "Merged via babysit-pr auto-merge handler",
  "merge_method": "squash",
  "sha": "$(git rev-parse HEAD)"
}
EOF
```

#### Fallback: Simple Direct Merge
```bash
gh pr merge $PR_NUMBER --squash --delete-branch
```

### 4. Effort Report

Print summary at completion:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PR #123: Feature title
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Automation Summary:
  Iterations:           3
  Review fixes applied: 7
    CodeRabbit:         4
    Sourcery:           2
    Gemini:             1
    Other agents:       0
  CI fixes applied:     2
    Linting fixes:      1
    Type fixes:         1
  Conflicts resolved:   1
  Total duration:       12m 34s

Result: ✅ Merged successfully
  Auto-merge status: Handled via API (auto-merge was stuck)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Exit Conditions

The loop exits when:
- ✅ CI passes (all green) AND all review suggestions (bot + human) addressed → merge (if `--auto-merge`)
- ✅ Auto-merge successfully triggered or manually merged
- ⚠️ Max iterations reached → report status and stop
- ⚠️ Unresolvable conflict or critical error → report and stop
- ⚠️ Manual interrupt (Ctrl+C)

## Supported Review Bots

### CodeRabbit (`coderabbitai[bot]`)
- Posts a summary comment with overall review
- Leaves inline comments on specific lines with code suggestions
- Uses collapsible sections for detailed analysis
- Suggestions often include replacement code blocks

### Sourcery (`sourcery-ai[bot]`)
- Posts inline suggestions with refactoring advice
- Provides quality metrics (complexity, readability)
- Suggestions include "before" and "after" code
- Labels suggestions by type: bug, refactoring, style

### Gemini (`gemini-code-assist[bot]`)
- Posts review summary with severity levels
- Leaves inline comments with suggested fixes
- Groups findings by category (security, performance, style)

## Examples

### Basic babysit (watch and address reviews)
```bash
# On a feature branch with an open PR
git checkout feat/new-feature
/github:babysit-pr
```

### Babysit with auto-fix CI and merge
```bash
/github:babysit-pr --auto-merge --fix-ci
```

### Force merge stuck auto-merge
```bash
# Repo has auto-merge enabled but it's stuck/not progressing
/github:babysit-pr --auto-merge --force-merge
```

### Babysit specific PR with aggressive CI fixing
```bash
/github:babysit-pr --pr 456 --max-iterations 5 --fix-ci --auto-merge
```

### Preview mode (dry-run)
```bash
/github:babysit-pr --dry-run
```

### Long CI timeout (for slow repos)
```bash
/github:babysit-pr --auto-merge --fix-ci --ci-timeout 45
```

## Continuous Monitoring with /loop

For long-running PRs, combine with `/loop` for periodic checks:

```bash
# Check every 10 minutes, auto-fix CI and auto-merge when ready
/loop 10m /github:babysit-pr --auto-merge --fix-ci

# Check every 5 minutes for a specific PR, with force-merge for stuck auto-merge
/loop 5m /github:babysit-pr --pr 123 --auto-merge --force-merge

# Check every 3 minutes with aggressive CI fixing and extended timeout
/loop 3m /github:babysit-pr --auto-merge --fix-ci --ci-timeout 30
```

## Troubleshooting

### Auto-merge is enabled but PR won't merge
- Use `--force-merge` flag to manually trigger merge via API
- Check if all required status checks are passing
- Verify branch protection rules aren't blocking merge
- Check if there are dismissed reviews blocking merge

### CI keeps failing on same issue
- Use `--fix-ci` to enable automatic CI failure analysis and fixing
- Check CI logs: `gh run view {run_id} --log`
- Some CI failures may require manual investigation

### Conflicts keep appearing
- Ensure base branch is fully fetched: `git fetch origin main`
- Rebase before pushing fixes: `git rebase origin/main`
- Check for competing changes from other contributors

## Related Commands

- `/github:watch-and-fix` - Simpler CI-focused watch loop (no bot parsing)
- `/fix:and-update-pr` - Single-iteration fix and push
- `/github:bulk-merge-prs` - Merge multiple approved PRs
- `/github:fix-workflow-failures` - Dedicated CI failure fixing tool
