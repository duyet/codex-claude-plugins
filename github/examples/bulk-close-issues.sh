#!/bin/bash
# Example: Bulk close issues by label
# Usage: ./bulk-close-issues.sh <label> [dry-run]

LABEL="${1:-stale}"
DRY_RUN="${2:-}"

echo "Finding issues with label: $LABEL"

# List issues to be affected
ISSUES=$(gh issue list --label "$LABEL" --limit 100 --json number --jq '.[].number')

if [ -z "$ISSUES" ]; then
  echo "No issues found with label: $LABEL"
  exit 0
fi

ISSUE_COUNT=$(echo "$ISSUES" | wc -l)
echo "Found $ISSUE_COUNT issues"

if [ "$DRY_RUN" = "--dry-run" ]; then
  echo "DRY RUN - Would close the following issues:"
  gh issue list --label "$LABEL" --limit 100
  exit 0
fi

# Confirm
read -p "Close $ISSUE_COUNT issues? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted"
  exit 1
fi

# Close each issue
for issue in $ISSUES; do
  echo "Closing issue #$issue"
  gh issue close "$issue" --comment "Closing as $LABEL"
done

echo "Closed $ISSUE_COUNT issues"
