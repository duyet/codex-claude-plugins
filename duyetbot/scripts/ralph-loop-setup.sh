#!/bin/bash

# Ralph Loop Setup Script
# Creates state file for in-session Ralph loop

set -euo pipefail

# State file location (matches official implementation)
RALPH_STATE_FILE=".claude/ralph-loop.local.md"
CIRCUIT_FILE=".claude/ralph-circuit.local.json"

# Parse arguments
PROMPT_PARTS=()
MAX_ITERATIONS=0
COMPLETION_PROMISE="null"
ENABLE_CIRCUIT_BREAKER="true"
RESET_CIRCUIT=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'EOF'
Ralph Loop - Self-referential development loop

USAGE:
  /ralph-loop [PROMPT] [OPTIONS]

OPTIONS:
  --max-iterations <n>          Stop after N iterations (default: unlimited)
  --completion-promise <text>   Promise phrase to signal completion
  --no-circuit-breaker          Disable stagnation detection
  --reset-circuit               Reset circuit breaker and start fresh
  -h, --help                    Show this help

EXAMPLES:
  /ralph-loop Build a todo API --completion-promise DONE --max-iterations 20
  /ralph-loop Fix the auth bug --max-iterations 10

STOP CONDITIONS:
  - --max-iterations reached
  - <promise>TEXT</promise> matches --completion-promise
  - Circuit breaker opens (3 iterations without file changes)

MONITORING:
  cat .claude/ralph-loop.local.md      # Loop state
  cat .claude/ralph-circuit.local.json # Circuit breaker
EOF
      exit 0
      ;;
    --max-iterations)
      if [[ -z "${2:-}" ]] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --max-iterations requires a number" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --completion-promise)
      if [[ -z "${2:-}" ]]; then
        echo "Error: --completion-promise requires text" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    --no-circuit-breaker)
      ENABLE_CIRCUIT_BREAKER="false"
      shift
      ;;
    --reset-circuit)
      RESET_CIRCUIT=true
      shift
      ;;
    *)
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

# Ensure .claude directory exists
mkdir -p .claude

# Reset circuit breaker if requested
if [[ "$RESET_CIRCUIT" == "true" ]]; then
  rm -f "$CIRCUIT_FILE"
  echo "Circuit breaker reset"
fi

# Join prompt parts (handle empty array)
PROMPT="${PROMPT_PARTS[*]:-}"

if [[ -z "$PROMPT" ]]; then
  echo "Error: No prompt provided" >&2
  echo "" >&2
  echo "Usage: /ralph-loop \"Your task\" [OPTIONS]" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  /ralph-loop Build a REST API" >&2
  echo "  /ralph-loop Fix auth --max-iterations 10" >&2
  echo "" >&2
  echo "For options: /ralph-loop --help" >&2
  exit 1
fi

# Format completion promise for YAML
if [[ -n "$COMPLETION_PROMISE" ]] && [[ "$COMPLETION_PROMISE" != "null" ]]; then
  COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""
else
  COMPLETION_PROMISE_YAML="null"
fi

# Create state file (markdown with YAML frontmatter)
cat > "$RALPH_STATE_FILE" <<EOF
---
active: true
iteration: 1
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
circuit_breaker: $ENABLE_CIRCUIT_BREAKER
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$PROMPT
EOF

# Output confirmation
echo "Ralph loop activated"
echo ""
echo "Iteration: 1"
echo "Max iterations: $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo $MAX_ITERATIONS; else echo 'unlimited'; fi)"
echo "Completion promise: $(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "$COMPLETION_PROMISE"; else echo 'none'; fi)"
echo "Circuit breaker: $(if [[ "$ENABLE_CIRCUIT_BREAKER" == "true" ]]; then echo 'ON'; else echo 'OFF'; fi)"
echo ""

if [[ "$COMPLETION_PROMISE" != "null" ]]; then
  echo "To complete: output <promise>$COMPLETION_PROMISE</promise>"
  echo ""
fi

echo "To monitor: cat .claude/ralph-loop.local.md"
echo "To cancel: /cancel-ralph"
echo ""
echo "$PROMPT"
