---
description: >-
  Knowledge base for parsing AI code review bot comments on GitHub PRs.
  Covers CodeRabbit, Sourcery, and Gemini - bot identification, comment formats,
  extracting actionable suggestions, and marking as resolved.
---

# AI Code Review Bots

Reference for identifying and parsing comments from AI review bots on GitHub pull requests.

## Bot Identification

| Bot | Username | App URL |
|-----|----------|---------|
| CodeRabbit | `coderabbitai[bot]` | github.com/apps/coderabbitai |
| Sourcery | `sourcery-ai[bot]` | github.com/apps/sourcery-ai |
| Gemini | `gemini-code-assist[bot]` | github.com/apps/gemini-code-assist |

### Detection Pattern

```bash
# Filter comments by known bot usernames
BOT_PATTERN="coderabbitai|sourcery-ai|gemini-code-assist"

# Top-level PR comments (summaries, walkthrough)
gh api repos/{owner}/{repo}/issues/{pr_number}/comments \
  --jq "[.[] | select(.user.login | test(\"$BOT_PATTERN\"))]"

# Inline review comments (line-specific)
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq "[.[] | select(.user.login | test(\"$BOT_PATTERN\"))]"

# Full reviews with verdicts
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
  --jq "[.[] | select(.user.login | test(\"$BOT_PATTERN\"))]"
```

## CodeRabbit (`coderabbitai[bot]`)

### Comment Structure

CodeRabbit posts two types of comments:

**1. Summary Comment (top-level)**
- Posted as an issue comment on the PR
- Contains: walkthrough, changes summary, sequence diagrams
- Uses collapsible `<details>` sections
- Includes a "Tips" section (skip this)

**2. Inline Review Comments**
- Posted on specific lines via PR review
- Contains actionable suggestions with code blocks
- Format:

```markdown
[nitpick/suggestion/issue] Brief description of the problem.

The current implementation does X, but it should do Y because Z.

<!-- suggestion -->
```suggestion
replacement code here
```
<!-- end suggestion -->
```

### Extracting Actionable Items

```bash
# Get inline review comments with file/line info
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '[.[] | select(.user.login == "coderabbitai[bot]") | {
    path: .path,
    line: .line,
    body: .body,
    diff_hunk: .diff_hunk,
    id: .id
  }]'
```

**Parsing suggestions from body:**
- Look for ` ```suggestion ` blocks — these are direct replacements
- Look for ` ```diff ` blocks — these show before/after
- Text-only comments describe the issue; use code understanding to fix

### Resolving Comments

```bash
# After fixing, minimize/resolve the review thread
# (GitHub API doesn't support resolving — push a fix commit and the bot updates)
```

CodeRabbit automatically re-reviews after new commits and updates its summary.

## Sourcery (`sourcery-ai[bot]`)

### Comment Structure

**1. Summary Comment (top-level)**
- Overall code quality assessment
- Metrics: complexity, readability, test coverage
- Grouped by type: bugs, security, performance, style, refactoring

**2. Inline Review Comments**
- Posted on specific lines
- Labeled by type and severity
- Format:

```markdown
**suggestion (refactoring):** Brief title

Description of the issue and why it matters.

Suggested change:
```python
# replacement code
```
```

### Extracting Actionable Items

```bash
# Get Sourcery inline comments
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '[.[] | select(.user.login == "sourcery-ai[bot]") | {
    path: .path,
    line: .line,
    body: .body,
    id: .id
  }]'
```

**Parsing suggestions from body:**
- Look for `**suggestion**`, `**issue**`, or `**bug**` labels
- Code blocks after "Suggested change:" contain the replacement
- Severity is in the label: `(bug)`, `(refactoring)`, `(style)`, `(performance)`

### Priority Order
1. `bug` — fix immediately
2. `security` — fix immediately
3. `performance` — fix if straightforward
4. `refactoring` — apply if it improves readability
5. `style` — apply if consistent with project conventions

## Gemini Code Assist (`gemini-code-assist[bot]`)

### Comment Structure

**1. Summary Comment (top-level)**
- Review summary with overall assessment
- Grouped findings by severity: critical, high, medium, low
- May include a "Code Review" section with general feedback

**2. Inline Review Comments**
- Posted on specific lines
- Contains severity indicator and category
- Format:

```markdown
**[severity: medium]** category: description

Explanation of the issue.

**Suggested fix:**
```language
replacement code
```
```

### Extracting Actionable Items

```bash
# Get Gemini inline comments
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '[.[] | select(.user.login == "gemini-code-assist[bot]") | {
    path: .path,
    line: .line,
    body: .body,
    id: .id
  }]'
```

**Parsing suggestions from body:**
- Look for `**[severity: ...]**` tags for priority
- Code blocks after "Suggested fix:" contain replacements
- Categories: security, performance, correctness, style, documentation

### Priority Order
1. `critical` — fix immediately
2. `high` — fix immediately
3. `medium` — fix if clear
4. `low` — apply if simple

## Unified Parsing Strategy

When babysitting a PR, process review bot comments in this order:

### Step 1: Fetch All Bot Comments
```bash
OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO=$(gh repo view --json name --jq '.name')

# Inline review comments (most actionable)
REVIEW_COMMENTS=$(gh api "repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments" \
  --jq "[.[] | select(.user.login | test(\"coderabbit|sourcery|gemini\")) | {
    bot: .user.login,
    path: .path,
    line: (.line // .original_line),
    body: .body,
    id: .id,
    created: .created_at
  }]")

# Top-level comments (summaries — less actionable)
SUMMARY_COMMENTS=$(gh api "repos/$OWNER/$REPO/issues/$PR_NUMBER/comments" \
  --jq "[.[] | select(.user.login | test(\"coderabbit|sourcery|gemini\")) | {
    bot: .user.login,
    body: .body,
    id: .id,
    created: .created_at
  }]")
```

### Step 2: Prioritize by Severity
1. Bugs and security issues (all bots)
2. Correctness issues
3. Performance suggestions
4. Refactoring and style

### Step 3: Extract Fix Instructions
For each comment:
1. Check for ` ```suggestion ` blocks → direct replacement
2. Check for ` ```diff ` blocks → apply diff
3. Check for code blocks after "Suggested fix/change" → replacement
4. Text-only → read the instruction and apply using code understanding

### Step 4: Apply and Track
- Apply each fix
- Track: bot name, file, line, fix type
- Count per-bot statistics for effort report

## Conflict Resolution

### Detecting Conflicts
```bash
# Check if PR has conflicts
gh pr view $PR_NUMBER --json mergeable --jq '.mergeable'
# Returns: "MERGEABLE", "CONFLICTING", or "UNKNOWN"

# Alternative: try merge locally
git fetch origin $(gh pr view $PR_NUMBER --json baseRefName --jq '.baseRefName')
BASE_BRANCH=$(gh pr view $PR_NUMBER --json baseRefName --jq '.baseRefName')
git merge --no-commit --no-ff "origin/$BASE_BRANCH" 2>&1 || true
```

### Resolving Conflicts
1. Identify conflicting files from merge output
2. For each conflict:
   - Read both sides of the conflict
   - Use code understanding to determine correct resolution
   - Prefer the PR's changes unless they contradict the base branch's intent
3. Stage resolved files and commit

```bash
git add <resolved-files>
git merge --continue
# or if merge was aborted:
git commit -m "fix(pr): resolve merge conflicts with $BASE_BRANCH"
git push
```

## Rate Limiting

GitHub API has rate limits. To avoid hitting them:
- Use `--paginate` for large result sets
- Cache bot usernames rather than re-fetching
- Sleep 2-5 seconds between API calls in loops
- Check rate limit: `gh api /rate_limit --jq '.rate.remaining'`
