#!/bin/bash
# Example: PR automation - auto-label and auto-assign
# This script demonstrates PR triage automation

# Auto-label based on changed files
label_pr() {
  local pr_number=$1

  # Get changed files
  FILES=$(gh pr diff "$pr_number" --name-only)

  # Label based on file patterns
  if echo "$FILES" | grep -q "^src/api/"; then
    gh pr edit "$pr_number" --add-label "area:api"
  fi

  if echo "$FILES" | grep -q "^tests/"; then
    gh pr edit "$pr_number" --add-label "area:tests"
  fi

  if echo "$FILES" | grep -q "\.md$"; then
    gh pr edit "$pr_number" --add-label "documentation"
  fi

  # Check for breaking changes
  if echo "$FILES" | grep -q "BREAKING CHANGE"; then
    gh pr edit "$pr_number" --add-label "breaking"
  fi
}

# Auto-assign based on code ownership
assign_reviewers() {
  local pr_number=$1

  # Get changed files
  FILES=$(gh pr diff "$pr_number" --name-only)

  # Assign based on file ownership (simplified)
  # In practice, use CODEOWNERS file parsing
  if echo "$FILES" | grep -q "^src/frontend/"; then
    gh pr edit "$pr_number" --add-reviewer "frontend-team"
  fi

  if echo "$FILES" | grep -q "^src/backend/"; then
    gh pr edit "$pr_number" --add-reviewer "backend-team"
  fi
}

# Welcome first-time contributors
welcome_contributor() {
  local pr_number=$1

  AUTHOR=$(gh pr view "$pr_number" --json author --jq '.author.login')

  # Check if this is their first PR
  PR_COUNT=$(gh pr list --author "$AUTHOR" --limit 1 --json number --jq 'length')

  if [ "$PR_COUNT" -eq 1 ]; then
    gh pr comment "$pr_number" --body "Welcome! Thanks for your first contribution! 🎉"
    gh pr edit "$pr_number" --add-label "first-time-contributor"
  fi
}

# Main script
PR_NUMBER="${1:-}"

if [ -z "$PR_NUMBER" ]; then
  echo "Usage: $0 <pr-number>"
  exit 1
fi

echo "Processing PR #$PR_NUMBER..."
label_pr "$PR_NUMBER"
assign_reviewers "$PR_NUMBER"
welcome_contributor "$PR_NUMBER"
echo "Done!"
