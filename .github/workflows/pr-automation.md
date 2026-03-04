---
description: >-
  Agentic workflow for PR automation: auto-label based on changed files,
  auto-assign reviewers based on code ownership, and welcome first-time contributors.
---

# PR Automation Workflow

Automatically triages pull requests with labels, reviewers, and welcome messages.

## Triggers

- `pull_request: opened` - When a new PR is opened
- `pull_request: reopened` - When a PR is reopened

## Features

### Auto-Label
Labels PRs based on changed file paths:
- `area:api` - Changes in `src/api/` or `api/`
- `area:frontend` - Changes in `src/frontend/`, `components/`, or `ui/`
- `area:backend` - Changes in `src/backend/` or `server/`
- `area:docs` - Changes in `docs/` or `*.md` files
- `area:tests` - Changes in `tests/` or `test/`
- `type:breaking` - If commit contains "BREAKING CHANGE"
- `documentation` - If only documentation files changed

### Auto-Assign Reviewers
Assigns reviewers based on changed files:
- Frontend changes → `frontend-team` team
- Backend changes → `backend-team` team
- API changes → `api-team` team
- Infrastructure → `devops-team` team

### Welcome First-Time Contributors
For first-time contributors:
- Adds `first-time-contributor` label
- Posts welcome message with contribution guidelines

## Configuration

### Custom Labels
Edit the workflow file to add custom label patterns:

```yaml
- name: Auto-label
  run: |
    # Add custom patterns here
    if echo "$FILES" | grep -q "^path/to/files/"; then
      gh pr edit "$PR_NUMBER" --add-label "custom-label"
    fi
```

### Custom Reviewers
Edit the reviewer mapping:

```yaml
- name: Auto-assign reviewers
  run: |
    # Map file paths to reviewers/teams
    if echo "$FILES" | grep -q "^your/path/"; then
      gh pr edit "$PR_NUMBER" --add-reviewer "your-team"
    fi
```

### Custom Welcome Message
Edit the welcome comment:

```yaml
- name: Welcome first-time contributors
  run: |
    gh pr comment "$PR_NUMBER" --body "Your custom welcome message"
```

## Permissions

The workflow requires the following permissions:
- `pull-requests: write` - To add labels and comments
- `contents: read` - To read repository files

## Usage

The workflow runs automatically on PR creation. No manual invocation needed.

To test changes to the workflow:
1. Create a test branch
2. Make a small change
3. Open a PR
4. Verify labels and assignments are applied

## Example Output

For a PR changing `src/api/users.ts`:
- Labels applied: `area:api`, `area:backend`
- Reviewers assigned: `api-team`
- If first-time contributor: Welcome comment posted
