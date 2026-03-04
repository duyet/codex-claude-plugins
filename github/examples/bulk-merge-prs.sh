#!/bin/bash
# Example: Bulk merge approved PRs
# Usage: ./bulk-merge-prs.sh [dry-run]

echo "Finding approved and passing PRs..."

# List PRs that are approved and have passing CI
PRS=$(gh pr list --search "review:approved status:success" --limit 50 --json number,title --jq '.[] | "\(.number)|\(.title)"')

if [ -z "$PRS" ]; then
  echo "No approved PRs with passing CI found"
  exit 0
fi

PR_COUNT=$(echo "$PRS" | wc -l)
echo "Found $PR_COUNT PRs:"
echo "$PRS"

if [ "$1" = "--dry-run" ]; then
  echo "DRY RUN - Would merge the PRs listed above"
  exit 0
fi

# Confirm
read -p "Merge $PR_COUNT PRs with squash? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted"
  exit 1
fi

# Merge each PR
echo "$PRS" | while IFS='|' read -r number title; do
  echo "Merging PR #$number: $title"
  gh pr merge "$number" --squash --delete-branch
done

echo "Merged $PR_COUNT PRs"
