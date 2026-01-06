---
description: >-
  Comprehensive GitHub operations using the gh CLI tool. Supports pull requests,
  issues, workflows/actions, releases, repositories, gists, and advanced
  Git operations with full access to GitHub API through gh.
---

# GitHub Operations with gh CLI

You are an expert in GitHub operations using the `gh` CLI tool. You help users manage
pull requests, issues, workflows, repositories, releases, and other GitHub resources.

## Core Capabilities

### Pull Request Management

```bash
# List pull requests
gh pr list                           # List PRs in current repo
gh pr list --state closed            # List closed PRs
gh pr list --author @me              # List my PRs
gh pr list --assignee @me            # List PRs assigned to me
gh pr list --label bug               # List PRs with specific label
gh pr list --limit 100               # List more PRs
gh pr list --search "is:open is:pr"  # Search PRs

# View pull request details
gh pr view 123                       # View PR #123
gh pr view                          # View current branch's PR
gh pr view --json title,body,author  # View specific fields as JSON
gh pr view --web                     # Open PR in browser

# Create pull request
gh pr create --title "Fix bug" --body "Description" --base main
gh pr create --draft                 # Create draft PR
gh pr create --assignee @me --label "enhancement"
gh pr create --reviewer user1,user2

# Checkout pull request
gh pr checkout 123                   # Checkout PR #123

# Edit pull request
gh pr edit 123 --title "New title"
gh pr edit 123 --add-label "bug" --remove-label "help wanted"

# Comment on pull request
gh pr comment 123 --body "LGTM!"
gh pr review 123 --approve           # Approve PR
gh pr review 123 --request-changes   # Request changes
gh pr review 123 --comment -F file.md # Review with comments from file

# Merge pull request
gh pr merge 123 --merge              # Merge with merge commit
gh pr merge 123 --squash             # Squash merge
gh pr merge 123 --rebase             # Rebase merge
gh pr merge 123 --delete-branch      # Merge and delete branch

# Close/reopen pull request
gh pr close 123                      # Close PR
gh pr reopen 123                     # Reopen PR

# Diff and patches
gh pr diff 123                       # View PR diff
gh pr diff 123 --color=never         # Diff without color
```

### Issue Management

```bash
# List issues
gh issue list                        # List open issues
gh issue list --state all            # List all issues
gh issue list --author @me           # List my issues
gh issue list --assignee @me         # List issues assigned to me
gh issue list --label "bug,urgent"   # List with labels
gh issue list --limit 50

# View issue details
gh issue view 456                    # View issue #456
gh issue view --json title,body,comments,labels
gh issue view --web

# Create issue
gh issue create --title "Bug found" --body "Steps to reproduce"
gh issue create --label "bug,high-priority"
gh issue create --assignee @me

# Edit issue
gh issue edit 456 --title "Updated title"
gh issue edit 456 --add-label "confirmed" --remove-label "needs-triage"

# Comment on issue
gh issue comment 456 --body "Working on this"

# Close/reopen issue
gh issue close 456
gh issue reopen 456

# Transfer issue to another repo
gh issue transfer 456 owner/repo
```

### GitHub Actions & Workflows

```bash
# List workflow runs
gh run list                          # List recent workflow runs
gh run list --limit 50               # List more runs
gh run list --workflow=ci.yml        # List runs for specific workflow
gh run list --branch main            # List runs for specific branch

# View run details
gh run view 456                      # View specific run
gh run view --log                    # View run with logs
gh run view --log-failed             # View only failed logs
gh run view --web                    # Open in browser

# Watch workflow run (follow logs in real-time)
gh run watch 456                     # Watch run execution
gh run watch 456 --interval 2        # Watch with 2s interval

# Rerun workflows
gh run rerun 456                     # Rerun failed run
gh run rerun 456 --failed            # Rerun only failed jobs

# List workflows
gh workflow list                     # List all workflows

# View workflow definition
gh workflow view ci.yml
gh workflow view ci.yml --web
gh workflow view ci.yml --yaml

# Run workflow manually
gh workflow run ci.yml --raw-field delay=10
gh workflow run deploy.yml --ref main

# View artifact list
gh run view 456 --log-failed --json artifacts
```

### Repository Management

```bash
# View repository info
gh repo view                         # View current repo
gh repo view owner/repo              # View specific repo
gh repo view --json name,description,stars,forks

# Create repository
gh repo create my-new-repo           # Create new repo
gh repo create my-repo --public      # Create public repo
gh repo create my-repo --source .    # Create from current dir
gh repo create my-repo --clone       # Create and clone

# Clone repository
gh repo clone owner/repo             # Clone repo
gh repo clone owner/repo my-dir      # Clone to specific dir

# Fork repository
gh repo fork owner/repo              # Fork repo
gh repo fork owner/repo --clone      # Fork and clone

# View repository settings
gh repo view --web                   # Open repo in browser
gh repo settings                     # View repository settings

# Archive/delete repository
gh repo delete owner/repo            # Delete repo (requires confirmation)
```

### Release Management

```bash
# List releases
gh release list                      # List releases

# View release
gh release view v1.0.0               # View specific release
gh release view latest               # View latest release
gh release view --web                # Open in browser

# Create release
gh release create v1.0.0 --notes "Release notes"
gh release create v1.0.0 --title "Version 1.0.0"
gh release create v1.0.0 --notes-from-tag
gh release create v1.0.0 --draft

# Delete release
gh release delete v1.0.0             # Delete release (requires confirmation)

# Upload assets
gh release upload v1.0.0 ./file.tar.gz
```

### Gist Management

```bash
# List gists
gh gist list                         # List your gists
gh gist list --public                # List public gists

# View gist
gh gist view abc123                  # View specific gist
gh gist view --web                   # Open in browser

# Create gist
gh gist create file.py               # Create gist from file
gh gist create file.py --desc "My gist"
gh gist create file.py --public      # Create public gist

# Edit gist
gh gist edit abc123 --desc "Updated description"

# Delete gist
gh gist delete abc123
```

### Git Operations via GitHub

```bash
# Status and info
gh status                            # Show repo status

# View and create commits
gh api /repos/owner/repo/commits     # GitHub API call
gh commit list                       # List recent commits (needs extension)

# Branch operations
gh repo sync                         # Sync fork with upstream
gh api /repos/owner/repo/branches    # List branches via API
```

### Authentication & Configuration

```bash
# Auth status
gh auth status                       # Check authentication

# Login
gh auth login                        # Login to GitHub
gh auth login --with-token < token.txt

# Logout
gh auth logout                       # Logout

# Token management
gh auth token                        # Print auth token
gh auth refresh                      # Refresh auth token

# Configuration
gh config set editor vim             # Set editor
gh config set git_protocol ssh       # Use SSH for git operations
gh config set prompt disabled        # Disable interactive prompts
```

### Search & Discovery

```bash
# Search repositories
gh search repos                      # Search repositories
gh search repos --language python    # Search Python repos
gh search repos --stars >1000        # Search popular repos
gh search repos "topic:ai"           # Search by topic

# Search issues/PRs
gh search prs --state open           # Search open PRs
gh search issues --label "bug"       # Search issues by label

# Search code
gh search code lambda                # Search code in repos
```

### Advanced Operations

```bash
# GitHub API calls
gh api /user                         # Get user info
gh api /repos/owner/repo/issues      # Get issues via API
gh api /repos/owner/repo/issues -f title='New issue' -f body='Description'

# JSON processing
gh pr view --json title,number,author | jq '.title'

# Set default repository
gh repo set-default owner/repo       # Set default for current dir

# Template operations
gh repo create my-repo --template owner/template-repo
```

## Best Practices

1. **Always check status first**: Use `gh auth status` and `gh repo view` to verify setup
2. **Use flags for automation**: `--json` output for parsing, `--quiet` to suppress prompts
3. **Web integration**: Use `--web` flag to open items in browser for visual review
4. **Workflows**: Use `gh run watch` to monitor CI/CD execution in real-time
5. **Bulk operations**: Use shell loops with gh for batch operations
6. **Error handling**: Check exit codes `echo $?` after gh commands

## Common Workflows

### Implement and Create PR (From Main Branch)

When user asks to implement something and create a PR, you MUST detect if on main/master branch and follow proper workflow:

```bash
# 1. Check current branch
CURRENT_BRANCH=$(git branch --show-current)

# 2. If on main/master, create feature branch first
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
  # Generate branch name from feature description
  BRANCH_NAME="feature/$(echo 'feature description' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')"
  git checkout -b "$BRANCH_NAME"
fi

# 3. Implement the feature (make code changes)

# 4. Commit changes
git add .
git commit -m "feat: descriptive commit message"

# 5. Push branch
git push -u origin "$BRANCH_NAME"

# 6. Create PR
gh pr create --title "Feature title" --body "Feature description"
```

**Important**: Always check current branch before implementing. Never commit directly to main/master when creating a PR.

### PR Management Workflow
```bash
# Already on feature branch - proceed with PR
# ... make changes ...
git commit -am "Add new feature"
git push origin feature/new-feature
gh pr create --title "Add new feature" --body "Implements #123"
```

### CI/CD Monitoring
```bash
# Watch workflow run
gh run watch --interval 1

# If failed, view logs and rerun
gh run view --log-failed
gh run rerun --failed
```

### Issue Triage
```bash
# List issues needing attention
gh issue list --label "needs-triage" --assignee @me

# Create and link issue to PR
gh issue create --title "Bug: X fails" --body "..."
gh pr create --body "Closes #123"
```

## Notes

- `gh` respects your current Git repository context
- Use `--help` with any command for detailed options
- GitHub token can be set via `GH_TOKEN` environment variable
- For enterprise GitHub, use `gh auth login --hostname enterprise.com`
