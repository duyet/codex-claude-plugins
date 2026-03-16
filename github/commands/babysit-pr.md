---
allowed-tools: Bash(git *), Bash(gh *), Read, Edit, Write, Glob, Grep, Agent
description: Babysit a PR - monitor, fix review bot suggestions, resolve conflicts, and merge when ready
---

# Babysit PR

Continuously monitor a pull request, read AI review bot comments (CodeRabbit, Sourcery, Gemini), fix suggested issues, resolve merge conflicts, and merge when ready. Reports total effort at completion.

## Usage

```bash
/github:babysit-pr
/github:babysit-pr --pr 123
/github:babysit-pr --auto-merge
/github:babysit-pr --max-iterations 10
/github:babysit-pr --dry-run
```

## Options

- `--pr <number>`: Specific PR number (default: current branch's PR)
- `--auto-merge`: Merge PR when CI passes and all review comments are resolved
- `--max-iterations <n>`: Maximum fix iterations (default: 10)
- `--dry-run`: Preview what would happen without making changes

## How It Works

### 1. Initial Setup
- Verify we're on a feature branch (not main/master)
- Find the PR for current branch (or use `--pr`)
- Record start time for effort tracking

### 2. Babysit Loop

For each iteration:

#### Step A: Wait for CI and Reviews
- Poll CI status until all checks complete (or timeout after 15 min)
- Wait for review bots to post their comments (30s grace period after CI)

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
5. Apply the fix (not blind text replacement — understand intent)
6. Track the fix in effort report

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
- CI passes AND no unresolved review comments → ready to merge
- Max iterations reached → report and stop

### 3. Merge (if `--auto-merge`)
```bash
gh pr merge $PR_NUMBER --squash --delete-branch
```

### 4. Effort Report

Print summary at completion:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PR #123: Feature title
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Effort Summary:
  Iterations:        3
  Fixes applied:     7
    CodeRabbit:      4
    Sourcery:        2
    Gemini:          1
  Conflicts resolved: 1
  Total duration:    12m 34s

Result: ✅ Merged successfully
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Exit Conditions

The loop exits when:
- ✅ CI passes AND all review suggestions (bot + human) addressed → merge (if `--auto-merge`)
- ⚠️ Max iterations reached → report status and stop
- ⚠️ Unresolvable conflict or error → report and stop
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

### Basic babysit
```bash
# On a feature branch with an open PR
git checkout feat/new-feature
/github:babysit-pr
```

### Babysit and auto-merge
```bash
/github:babysit-pr --auto-merge
```

### Babysit specific PR with limited iterations
```bash
/github:babysit-pr --pr 456 --max-iterations 3
```

### Preview mode
```bash
/github:babysit-pr --dry-run
```

## Continuous Monitoring with /loop

For long-running PRs, combine with `/loop` for periodic checks:

```bash
# Check every 10 minutes, auto-merge when ready
/loop 10m /github:babysit-pr --auto-merge

# Check every 5 minutes for a specific PR
/loop 5m /github:babysit-pr --pr 123 --auto-merge
```

## Related Commands

- `/github:watch-and-fix` - Simpler CI-focused watch loop (no bot parsing)
- `/fix:and-update-pr` - Single-iteration fix and push
- `/github:bulk-merge-prs` - Merge multiple approved PRs
