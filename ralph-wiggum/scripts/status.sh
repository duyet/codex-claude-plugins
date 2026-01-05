#!/bin/bash

# Ralph Loop Status Script

set -euo pipefail

RALPH_STATE_FILE=".claude/ralph-loop.local.md"
CIRCUIT_FILE=".claude/ralph-circuit.local.json"

if [[ ! -f "$RALPH_STATE_FILE" ]]; then
  echo "No active Ralph loop"
  exit 0
fi

# Parse state file
FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$RALPH_STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')
CIRCUIT_BREAKER=$(echo "$FRONTMATTER" | grep '^circuit_breaker:' | sed 's/circuit_breaker: *//' || echo "true")
STARTED_AT=$(echo "$FRONTMATTER" | grep '^started_at:' | sed 's/started_at: *//' | sed 's/^"\(.*\)"$/\1/')

echo "Ralph Loop Status"
echo "================="
echo ""
echo "Iteration: $ITERATION"
echo "Max iterations: $(if [[ "$MAX_ITERATIONS" == "0" ]]; then echo 'unlimited'; else echo "$MAX_ITERATIONS"; fi)"
echo "Completion promise: $(if [[ "$COMPLETION_PROMISE" == "null" ]] || [[ -z "$COMPLETION_PROMISE" ]]; then echo 'none'; else echo "$COMPLETION_PROMISE"; fi)"
echo "Circuit breaker: $(if [[ "$CIRCUIT_BREAKER" == "true" ]]; then echo 'ON'; else echo 'OFF'; fi)"
echo "Started: $STARTED_AT"

# Show circuit breaker state if enabled
if [[ "$CIRCUIT_BREAKER" == "true" ]] && [[ -f "$CIRCUIT_FILE" ]]; then
  echo ""
  echo "Circuit Breaker"
  echo "---------------"
  NO_PROGRESS=$(jq -r '.no_progress // 0' "$CIRCUIT_FILE")
  ERRORS=$(jq -r '.errors // 0' "$CIRCUIT_FILE")
  echo "No progress count: $NO_PROGRESS/3"
  echo "Error count: $ERRORS/5"
fi

echo ""
echo "To cancel: /cancel-ralph"
