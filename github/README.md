# GitHub Plugin

GitHub operations using gh CLI - PRs, issues, workflows, repositories, batch operations, and smart branch detection for implementation workflows.

## Version

1.4.0

## Components

### Skills
- **github** - GitHub operations knowledge
- **review-bots** - AI code review bot parsing (CodeRabbit, Sourcery, Gemini)

### Commands
- `/github:bulk-close-issues` - Close multiple issues by label or search query
- `/github:bulk-merge-prs` - Merge multiple approved PRs
- `/github:bulk-label` - Apply labels to multiple issues/PRs
- `/github:watch-and-fix` - Watch PR, fix issues from AI reviews, and auto-merge when ready
- `/github:babysit-pr` - Babysit a PR: monitor, fix review bot suggestions (CodeRabbit, Sourcery, Gemini), resolve conflicts, and merge

## Features

### Smart Branch Detection
Automatically detects when you're on main/master and creates feature branches before implementing.

### Batch Operations
Efficiently manage multiple issues and PRs with bulk commands:
- Close issues in bulk by label or query
- Merge approved PRs with passing CI
- Apply/remove labels across multiple items

### Complete GitHub Workflow
Handles full workflow from branch creation to PR merge.

## Usage Examples

### Create PR from Feature Branch
```bash
# Make changes
git add .
git commit -m "feat: add new feature"

# Push and create PR
git push -u origin feat/new-feature
gh pr create --title "feat: add new feature" --body "Implements #123"
```

### Bulk Close Stale Issues
```bash
# Preview what will be closed
/github:bulk-close-issues --dry-run --label "stale"

# Close with comment
/github:bulk-close-issues --label "stale" --comment "Closing due to inactivity"
```

### Merge Approved PRs
```bash
# Preview before merging
/github:bulk-merge-prs --dry-run --label "ready-to-merge"

# Merge with squash and delete branches
/github:bulk-merge-prs --label "ready-to-merge" --method squash --delete-branch
```

### Apply Labels in Bulk
```bash
# Add priority label to bugs
/github:bulk-label --add "priority:high" --label "bug"

# Remove triage label from reviewed items
/github:bulk-label --remove "status:triage" --search "reviewed-by:@me"
```

### Watch and Fix PR
```bash
# Watch PR, fix issues from AI reviews, and auto-merge when ready
/github:watch-and-fix --auto-merge --max-iterations 5

# Preview what would happen
/github:watch-and-fix --dry-run
```

### Babysit PR
```bash
# Babysit current branch's PR — reads all review comments and fixes them
/github:babysit-pr --auto-merge

# Babysit specific PR with limited iterations
/github:babysit-pr --pr 123 --max-iterations 5

# Use with /loop for continuous monitoring every 10 minutes
/loop 10m /github:babysit-pr --auto-merge

# Preview mode
/github:babysit-pr --dry-run
```

## Real-World Workflows

### Automated PR Triage
```bash
# Label first-time contributor PRs
for pr in $(gh pr list --author . --json number --jq '.[].number'); do
  count=$(gh api users/$(gh pr view $pr --json author --jq '.author.login')/repos --jq 'length' 2>/dev/null || echo 0)
  if [ "$count" -lt 5 ]; then
    gh pr edit $pr --add-label "first-time-contributor"
  fi
done
```

### Watch and Fix Loop
```bash
# Continuous fix loop for a PR
./examples/watch-and-fix.sh --auto-merge --max-iterations 10

# Or use the slash command
/github:watch-and-fix --auto-merge
```

### CI Failure Analysis
```bash
# Find all PRs with failed CI
gh pr list --search "status:failure" --limit 50 --json number,title

# Watch specific run in real-time
gh run watch $(gh run list --workflow=ci.yml --limit 1 --json databaseId --jq '.[0].databaseId')
```

### Repository Cleanup
```bash
# Close stale draft PRs
gh pr list --search "draft:yes updated:<30 days ago" --json number --jq '.[].number' | \
  while read pr; do gh pr close $pr --comment "Closing stale draft PR"; done
```

## Troubleshooting

### "Not logged in" Error
```bash
gh auth login
```

### Token Expired
```bash
gh auth refresh
```

### Branch Detection Not Working
```bash
# Set remote head explicitly
git remote set-head origin -a

# Explicitly specify base branch
gh pr create --base main --title "Fix"
```

### CI Status Not Showing
```bash
# Check workflow name
gh workflow list

# View specific workflow status
gh run list --workflow=ci.yml
```

### Rate Limiting
```bash
# Check rate limit status
gh api /rate_limit

# Use pagination for large result sets
gh pr list --limit 100 --json number,title --jq '.[]'
```

## Examples

See the `examples/` directory for complete automation scripts:
- `babysit-pr.sh` - Babysit PR with review bot integration and effort reporting
- `bulk-close-issues.sh` - Close issues by label with confirmation
- `bulk-merge-prs.sh` - Merge approved PRs with passing CI
- `pr-automation.sh` - Auto-label, auto-assign, and welcome contributors
- `watch-and-fix.sh` - Watch PR, fix issues from AI reviews, auto-merge when ready

## Plugin Structure

```
github/
├── .claude-plugin/
│   └── plugin.json          # Manifest (version 1.4.0)
├── commands/                # Slash commands
│   ├── babysit-pr.md
│   ├── bulk-close-issues.md
│   ├── bulk-merge-prs.md
│   ├── bulk-label.md
│   └── watch-and-fix.md
├── skills/                  # Reusable knowledge
│   ├── github.md
│   └── review-bots.md
└── examples/                # Example scripts
    ├── babysit-pr.sh
    ├── bulk-close-issues.sh
    ├── bulk-merge-prs.sh
    ├── pr-automation.sh
    └── watch-and-fix.sh
```

## Versioning

Follow semantic versioning (semver):

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Bug fix, docs | Patch | 1.2.0 → 1.2.1 |
| New feature, minor change | Minor | 1.2.0 → 1.4.0 |
| Breaking change | Major | 1.2.0 → 2.0.0 |

**When to bump:**
- Adding new commands → **Minor**
- Modifying existing behavior → **Minor** (or Major if breaking)
- Updating documentation only → **Patch**
- Bug fixes → **Patch**

Always update `plugin.json` version when making changes.

## Commit Convention

Use semantic commits with plugin scope:

```
feat(github): add new batch command
fix(github): fix issue listing pagination
docs(github): update examples
```

Co-author: `Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>`

---

**Generated by docs-generator v1.0.0**
