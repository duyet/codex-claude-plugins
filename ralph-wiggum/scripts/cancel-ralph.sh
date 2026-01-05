#!/bin/bash

# Cancel Ralph Loop Script

set -euo pipefail

RALPH_STATE_FILE=".claude/ralph-loop.local.md"
CIRCUIT_FILE=".claude/ralph-circuit.local.json"

if [[ -f "$RALPH_STATE_FILE" ]]; then
  # Extract iteration info
  ITERATION=$(grep '^iteration:' "$RALPH_STATE_FILE" | sed 's/iteration: *//' || echo "unknown")

  rm -f "$RALPH_STATE_FILE" "$CIRCUIT_FILE"
  echo "Ralph loop cancelled at iteration $ITERATION"
else
  echo "No active Ralph loop"
fi
