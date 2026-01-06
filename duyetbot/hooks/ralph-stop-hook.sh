#!/bin/bash

# Ralph Wiggum Stop Hook
# Intercepts exit attempts and feeds the same prompt back for iterative development
# Simplified version based on official Anthropic implementation

set -euo pipefail

# Configuration
RALPH_STATE_FILE=".claude/ralph-loop.local.md"
MAX_NO_PROGRESS=${RALPH_MAX_NO_PROGRESS:-3}
MAX_CONSECUTIVE_ERRORS=${RALPH_MAX_ERRORS:-5}

# Read hook input from stdin
HOOK_INPUT=$(cat)

# No active loop - allow exit
if [[ ! -f "$RALPH_STATE_FILE" ]]; then
  exit 0
fi

# Parse markdown frontmatter (YAML between ---)
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$RALPH_STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')
ENABLE_CIRCUIT_BREAKER=$(echo "$FRONTMATTER" | grep '^circuit_breaker:' | sed 's/circuit_breaker: *//' || echo "true")

# Validate state file
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "Ralph loop: Invalid iteration in state file" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

if [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "Ralph loop: Invalid max_iterations in state file" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Check max iterations
if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "Ralph loop: Max iterations ($MAX_ITERATIONS) reached"
  rm -f "$RALPH_STATE_FILE" ".claude/ralph-circuit.local.json"
  exit 0
fi

# Get transcript path from hook input
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty' 2>/dev/null || echo "")

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  echo "Ralph loop: Transcript not found" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Check for assistant messages
if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
  echo "Ralph loop: No assistant messages in transcript" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Extract last assistant message
LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1)
if [[ -z "$LAST_LINE" ]]; then
  echo "Ralph loop: Failed to extract assistant message" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
  .message.content |
  map(select(.type == "text")) |
  map(.text) |
  join("\n")
' 2>/dev/null || echo "")

if [[ -z "$LAST_OUTPUT" ]]; then
  echo "Ralph loop: Failed to parse assistant message" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Circuit Breaker (simple inline implementation)
CIRCUIT_FILE=".claude/ralph-circuit.local.json"

if [[ "$ENABLE_CIRCUIT_BREAKER" == "true" ]]; then
  # Initialize circuit state if needed
  if [[ ! -f "$CIRCUIT_FILE" ]]; then
    echo '{"no_progress": 0, "errors": 0, "last_hash": ""}' > "$CIRCUIT_FILE"
  fi

  # Calculate current file hash (cross-platform)
  CURRENT_HASH=""
  if command -v git &>/dev/null && git rev-parse --git-dir &>/dev/null; then
    CURRENT_HASH=$(git diff --name-only 2>/dev/null | sort | md5sum 2>/dev/null | cut -d' ' -f1 || md5 -q 2>/dev/null || echo "")
  fi

  # Read circuit state
  NO_PROGRESS=$(jq -r '.no_progress // 0' "$CIRCUIT_FILE")
  ERROR_COUNT=$(jq -r '.errors // 0' "$CIRCUIT_FILE")
  LAST_HASH=$(jq -r '.last_hash // ""' "$CIRCUIT_FILE")

  # Check for errors in output
  HAS_ERRORS=false
  echo "$LAST_OUTPUT" | grep -qiE "^error:|^ERROR:|exception|traceback|fatal" && HAS_ERRORS=true

  # Check for progress (file changes)
  HAS_PROGRESS=false
  if [[ -n "$CURRENT_HASH" ]] && [[ "$CURRENT_HASH" != "$LAST_HASH" ]]; then
    HAS_PROGRESS=true
  fi

  # Update counters
  if [[ "$HAS_PROGRESS" == "true" ]]; then
    NO_PROGRESS=0
    ERROR_COUNT=0
  else
    ((NO_PROGRESS++)) || true
  fi

  if [[ "$HAS_ERRORS" == "true" ]]; then
    ((ERROR_COUNT++)) || true
  else
    ERROR_COUNT=0
  fi

  # Check circuit breaker thresholds
  if [[ $NO_PROGRESS -ge $MAX_NO_PROGRESS ]]; then
    echo "" >&2
    echo "CIRCUIT BREAKER: No file changes for $NO_PROGRESS iterations" >&2
    echo "To resume: /ralph-loop --reset-circuit" >&2
    rm -f "$RALPH_STATE_FILE" "$CIRCUIT_FILE"
    exit 0
  fi

  if [[ $ERROR_COUNT -ge $MAX_CONSECUTIVE_ERRORS ]]; then
    echo "" >&2
    echo "CIRCUIT BREAKER: $ERROR_COUNT consecutive errors detected" >&2
    echo "To resume: /ralph-loop --reset-circuit" >&2
    rm -f "$RALPH_STATE_FILE" "$CIRCUIT_FILE"
    exit 0
  fi

  # Update circuit state
  jq -n \
    --argjson no_progress "$NO_PROGRESS" \
    --argjson errors "$ERROR_COUNT" \
    --arg hash "$CURRENT_HASH" \
    '{no_progress: $no_progress, errors: $errors, last_hash: $hash}' > "$CIRCUIT_FILE"
fi

# Check completion promise
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  # Extract text from <promise> tags
  PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g; s/\s+/ /g' 2>/dev/null || echo "")

  if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    echo "Ralph loop: Promise fulfilled <promise>$COMPLETION_PROMISE</promise>"
    rm -f "$RALPH_STATE_FILE" "$CIRCUIT_FILE"
    exit 0
  fi
fi

# Continue loop - update iteration
NEXT_ITERATION=$((ITERATION + 1))

# Extract prompt (everything after the closing ---)
PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$RALPH_STATE_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "Ralph loop: No prompt in state file" >&2
  rm "$RALPH_STATE_FILE"
  exit 0
fi

# Update iteration in state file
TEMP_FILE="${RALPH_STATE_FILE}.tmp.$$"
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$RALPH_STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$RALPH_STATE_FILE"

# Build system message
if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  SYSTEM_MSG="Ralph iteration $NEXT_ITERATION | Complete: <promise>$COMPLETION_PROMISE</promise>"
else
  SYSTEM_MSG="Ralph iteration $NEXT_ITERATION"
fi

# Add circuit breaker status if enabled
if [[ "$ENABLE_CIRCUIT_BREAKER" == "true" ]] && [[ -f "$CIRCUIT_FILE" ]]; then
  CB_NO_PROGRESS=$(jq -r '.no_progress // 0' "$CIRCUIT_FILE")
  if [[ $CB_NO_PROGRESS -gt 0 ]]; then
    SYSTEM_MSG="$SYSTEM_MSG | No progress: $CB_NO_PROGRESS/$MAX_NO_PROGRESS"
  fi
fi

# Output JSON to block exit and feed prompt back
jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
