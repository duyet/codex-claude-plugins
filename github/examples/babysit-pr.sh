#!/bin/bash
# Babysit PR - Monitor, fix review bot suggestions, resolve conflicts, merge
# Usage: ./babysit-pr.sh [--auto-merge] [--max-iterations N] [--dry-run] [--pr NUMBER]

set -euo pipefail

# Default values
AUTO_MERGE=false
MAX_ITERATIONS=10
DRY_RUN=false
PR_NUMBER=""
FIXES_APPLIED=0
CONFLICTS_RESOLVED=0
CODERABBIT_FIXES=0
SOURCERY_FIXES=0
GEMINI_FIXES=0
START_TIME=$(date +%s)

# Bot username patterns
BOT_PATTERN="coderabbitai\[bot\]|sourcery-ai\[bot\]|gemini-code-assist\[bot\]"

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

# Get repository info
OWNER=$(gh repo view --json owner --jq '.owner.login')
REPO=$(gh repo view --json name --jq '.name')

# Get current branch
BRANCH=$(git branch --show-current)
DEFAULT_BRANCH=$(git remote show origin 2>/dev/null | grep 'HEAD branch' | cut -d' ' -f5 || echo "main")

# Check we're not on main/master
if [ "$BRANCH" = "$DEFAULT_BRANCH" ] || [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ]; then
  echo "Error: On default branch ($BRANCH). Switch to a feature branch first."
  exit 1
fi

# Find PR if not specified
if [ -z "$PR_NUMBER" ]; then
  PR_NUMBER=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number' 2>/dev/null || echo "")
  if [ -z "$PR_NUMBER" ]; then
    echo "Error: No PR found for branch $BRANCH"
    exit 1
  fi
fi

PR_TITLE=$(gh pr view "$PR_NUMBER" --json title --jq '.title' 2>/dev/null || echo "Unknown")

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Babysitting PR #$PR_NUMBER: $PR_TITLE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Branch: $BRANCH"
echo "Max iterations: $MAX_ITERATIONS"
echo "Auto-merge: $AUTO_MERGE"
echo "Dry run: $DRY_RUN"
echo

# Function: fetch all review comments (bots + humans)
fetch_review_comments() {
  # Inline review comments from all reviewers (line-specific suggestions)
  local inline_comments
  inline_comments=$(gh api "repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments" \
    --jq "[.[] | {
      author: .user.login,
      is_bot: (.user.type == \"Bot\"),
      path: .path,
      line: (.line // .original_line // 0),
      body: .body,
      id: .id
    }]" 2>/dev/null || echo "[]")

  echo "$inline_comments"
}

# Function: check for merge conflicts
check_conflicts() {
  local mergeable
  mergeable=$(gh pr view "$PR_NUMBER" --json mergeable --jq '.mergeable' 2>/dev/null || echo "UNKNOWN")
  echo "$mergeable"
}

# Function: count bot-specific fixes
track_fix() {
  local bot="$1"
  FIXES_APPLIED=$((FIXES_APPLIED + 1))
  case "$bot" in
    *coderabbit*) CODERABBIT_FIXES=$((CODERABBIT_FIXES + 1)) ;;
    *sourcery*) SOURCERY_FIXES=$((SOURCERY_FIXES + 1)) ;;
    *gemini*) GEMINI_FIXES=$((GEMINI_FIXES + 1)) ;;
  esac
}

# Function: print effort report
print_report() {
  local end_time result
  end_time=$(date +%s)
  local duration=$((end_time - START_TIME))
  local minutes=$((duration / 60))
  local seconds=$((duration % 60))
  result="${1:-Stopped}"

  echo
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "PR #$PR_NUMBER: $PR_TITLE"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo
  echo "Effort Summary:"
  echo "  Iterations:          $iteration"
  echo "  Fixes applied:       $FIXES_APPLIED"
  if [ "$CODERABBIT_FIXES" -gt 0 ]; then
    echo "    CodeRabbit:        $CODERABBIT_FIXES"
  fi
  if [ "$SOURCERY_FIXES" -gt 0 ]; then
    echo "    Sourcery:          $SOURCERY_FIXES"
  fi
  if [ "$GEMINI_FIXES" -gt 0 ]; then
    echo "    Gemini:            $GEMINI_FIXES"
  fi
  echo "  Conflicts resolved:  $CONFLICTS_RESOLVED"
  echo "  Total duration:      ${minutes}m ${seconds}s"
  echo
  echo "Result: $result"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Main babysit loop
for iteration in $(seq 1 "$MAX_ITERATIONS"); do
  echo "--- Iteration $iteration/$MAX_ITERATIONS ---"

  # Step A: Wait for CI to complete
  echo "Checking CI status..."
  RUN_ID=$(gh run list --branch "$BRANCH" --limit 1 --json databaseId,status --jq '.[0].databaseId' 2>/dev/null || echo "")

  if [ -n "$RUN_ID" ]; then
    RUN_STATUS=$(gh run view "$RUN_ID" --json status --jq '.status' 2>/dev/null || echo "unknown")

    if [ "$RUN_STATUS" = "in_progress" ] || [ "$RUN_STATUS" = "queued" ]; then
      echo "CI running (run #$RUN_ID), waiting..."
      gh run watch "$RUN_ID" --interval 10 2>/dev/null || true
    fi

    CONCLUSION=$(gh run view "$RUN_ID" --json conclusion --jq '.conclusion' 2>/dev/null || echo "unknown")
    echo "CI conclusion: $CONCLUSION"
  else
    CONCLUSION="unknown"
    echo "No CI run found."
  fi

  # Give review bots time to post after CI
  echo "Waiting for review bots..."
  sleep 15

  # Step B: Fetch all review comments (bots + humans)
  echo "Fetching review comments..."
  REVIEW_COMMENTS=$(fetch_review_comments)
  COMMENT_COUNT=$(echo "$REVIEW_COMMENTS" | jq 'length' 2>/dev/null || echo "0")
  BOT_COUNT=$(echo "$REVIEW_COMMENTS" | jq '[.[] | select(.is_bot)] | length' 2>/dev/null || echo "0")
  HUMAN_COUNT=$(echo "$REVIEW_COMMENTS" | jq '[.[] | select(.is_bot | not)] | length' 2>/dev/null || echo "0")
  echo "Found $COMMENT_COUNT review comments ($BOT_COUNT from bots, $HUMAN_COUNT from humans)."

  # Step C: Check for merge conflicts
  echo "Checking for merge conflicts..."
  MERGEABLE=$(check_conflicts)
  echo "Mergeable status: $MERGEABLE"

  if [ "$MERGEABLE" = "CONFLICTING" ]; then
    echo "⚠️ Merge conflicts detected."
    if [ "$DRY_RUN" = true ]; then
      echo "[DRY RUN] Would resolve merge conflicts"
    else
      echo "Fetching base branch and resolving..."
      BASE_BRANCH=$(gh pr view "$PR_NUMBER" --json baseRefName --jq '.baseRefName')
      git fetch origin "$BASE_BRANCH"

      if git merge --no-commit --no-ff "origin/$BASE_BRANCH" 2>/dev/null; then
        git commit -m "fix(pr): resolve merge conflicts with $BASE_BRANCH

Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>"
        git push
        CONFLICTS_RESOLVED=$((CONFLICTS_RESOLVED + 1))
        echo "✅ Conflicts resolved."
      else
        echo "⚠️ Auto-resolution failed. Manual intervention needed."
        git merge --abort 2>/dev/null || true
        print_report "❌ Failed - unresolvable merge conflict"
        exit 1
      fi
    fi
  fi

  # Step D: Check if PR is ready to merge
  REVIEW_STATE=$(gh pr view "$PR_NUMBER" --json reviewDecision --jq '.reviewDecision // "PENDING"' 2>/dev/null || echo "PENDING")
  echo "Review state: $REVIEW_STATE"

  if [ "$CONCLUSION" = "success" ] && [ "$COMMENT_COUNT" = "0" ]; then
    echo "✅ CI passed and no pending review bot comments!"

    if [ "$AUTO_MERGE" = true ]; then
      if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] Would merge PR #$PR_NUMBER"
        print_report "✅ Ready to merge (dry run)"
      else
        echo "Merging PR #$PR_NUMBER..."
        gh pr merge "$PR_NUMBER" --squash --delete-branch
        print_report "✅ Merged successfully"
      fi
    else
      print_report "✅ Ready to merge (use --auto-merge to merge automatically)"
    fi
    exit 0
  fi

  # Step E: Process all review suggestions (bots + humans)
  if [ "$COMMENT_COUNT" != "0" ]; then
    echo "Processing review suggestions..."

    if [ "$DRY_RUN" = true ]; then
      echo "[DRY RUN] Would process $COMMENT_COUNT suggestions:"
      echo "$REVIEW_COMMENTS" | jq -r '.[] | "  \(.author): \(.path):\(.line)"' 2>/dev/null || true
      print_report "✅ Preview complete (dry run)"
      exit 0
    fi

    # Display all suggestions for the fix skill to process
    echo "Review suggestions to address:"
    echo "$REVIEW_COMMENTS" | jq -r '.[] | "[\(.author)] \(.path):\(.line)\n\(.body)\n---"' 2>/dev/null || true
    echo
    echo "Applying fixes using /fix:and-update-pr..."
    # The Claude agent will process these suggestions and apply fixes
    # This script serves as reference — actual fix application happens via the skill
    echo "Use /github:babysit-pr command for full automation with Claude agent."
  fi

  # If CI failed with no bot comments, wait and retry
  if [ "$CONCLUSION" = "failure" ] && [ "$COMMENT_COUNT" = "0" ]; then
    echo "⚠️ CI failed but no review bot suggestions found."
    echo "Waiting 30 seconds before retry..."
    sleep 30
  fi

  echo
done

print_report "⚠️ Reached max iterations ($MAX_ITERATIONS)"
exit 1
