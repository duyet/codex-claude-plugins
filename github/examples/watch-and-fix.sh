#!/bin/bash
# Watch and Fix PR - Automated fix loop for GitHub PRs
# Usage: ./watch-and-fix.sh [--auto-merge] [--max-iterations N] [--dry-run] [--pr NUMBER]

set -euo pipefail

# Default values
AUTO_MERGE=false
MAX_ITERATIONS=10
DRY_RUN=false
PR_NUMBER=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --auto-merge) AUTO_MERGE=true ;;
    --max-iterations) MAX_ITERATIONS="$2"; shift ;;
    --dry-run) DRY_RUN=true ;;
    --pr) PR_NUMBER="$2"; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

# Get current branch
BRANCH=$(git branch --show-current)
DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)

# Check we're not on main/master
if [ "$BRANCH" = "$DEFAULT_BRANCH" ] || [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ]; then
  echo "Error: On default branch ($BRANCH). Switch to a feature branch first."
  exit 1
fi

# Find PR if not specified
if [ -z "$PR_NUMBER" ]; then
  PR_NUMBER=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number')
  if [ -z "$PR_NUMBER" ]; then
    echo "Error: No PR found for branch $BRANCH"
    exit 1
  fi
fi

echo "=== Watch and Fix PR #$PR_NUMBER ==="
echo "Branch: $BRANCH"
echo "Max iterations: $MAX_ITERATIONS"
echo "Auto-merge: $AUTO_MERGE"
echo "Dry run: $DRY_RUN"
echo

# Main fix loop
for iteration in $(seq 1 "$MAX_ITERATIONS"); do
  echo "--- Iteration $iteration/$MAX_ITERATIONS ---"

  # Get latest CI run
  echo "Waiting for CI to complete..."
  RUN_ID=$(gh run list --workflow=ci.yml --branch "$BRANCH" --limit 1 --json databaseId --jq '.[0].databaseId' 2>/dev/null || echo "")

  if [ -n "$RUN_ID" ]; then
    echo "Watching CI run #$RUN_ID..."
    gh run watch "$RUN_ID" --interval 10 || true

    # Check CI status
    CONCLUSION=$(gh run view "$RUN_ID" --json conclusion --jq '.conclusion' 2>/dev/null || echo "unknown")
    STATUS=$(gh run view "$RUN_ID" --json status --jq '.status' 2>/dev/null || echo "unknown")

    echo "CI Status: $STATUS"
    echo "CI Conclusion: $CONCLUSION"
  else
    echo "No CI run found, checking PR status..."
  fi

  # Get PR review status
  REVIEW_STATE=$(gh pr view "$PR_NUMBER" --json reviewDecision --jq '.reviewDecision // "PENDING"')
  echo "Review State: $REVIEW_STATE"

  # Check if we can merge
  if [ "$CONCLUSION" = "success" ] && { [ "$REVIEW_STATE" = "APPROVED" ] || [ "$REVIEW_STATE" = "NULL" ]; }; then
    echo "✅ CI passed and reviews approved!"
    if [ "$AUTO_MERGE" = true ]; then
      if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would merge PR #$PR_NUMBER"
      else
        echo "Merging PR #$PR_NUMBER..."
        gh pr merge "$PR_NUMBER" --squash --delete-branch
        echo "✅ PR merged successfully!"
      fi
    else
      echo "PR is ready to merge. Use '--auto-merge' to merge automatically."
    fi
    exit 0
  fi

  # Get review comments
  echo "Fetching review comments..."
  COMMENTS=$(gh pr view "$PR_NUMBER" --json comments -q '.comments[] | select(.author.type == "Bot" or .authorAssociation == "OWNER") | [.path, .line, .body] | @tsv' 2>/dev/null || echo "")

  if [ -z "$COMMENTS" ]; then
    echo "No review comments found."

    # If CI is still failing but no comments, we can't fix
    if [ "$CONCLUSION" = "failure" ]; then
      echo "⚠️ CI failed but no fixable issues found in comments."
      echo "Waiting 30 seconds before retry..."
      sleep 30
      continue
    fi

    # If just waiting for review, wait longer
    echo "Waiting for reviews..."
    sleep 60
    continue
  fi

  echo "Found review comments:"
  echo "$COMMENTS"
  echo

  # In dry-run mode, just show what we would do
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would fix issues based on comments above"
    exit 0
  fi

  # Apply fixes using the fix skill
  echo "Applying fixes..."
  # Invoke fix:and-update-pr to address review comments
  # For full review-bot-aware automation, use /github:babysit-pr instead
  echo "Use '/fix:and-update-pr' to apply fixes, or '/github:babysit-pr' for full automation."

  # After fixes, the loop continues
  echo "Waiting for CI to restart..."
  sleep 10
done

echo "⚠️ Reached max iterations ($MAX_ITERATIONS) without completion."
echo "Current status:"
gh pr view "$PR_NUMBER" --json statusCheckRollup,reviewDecision --jq '.'
