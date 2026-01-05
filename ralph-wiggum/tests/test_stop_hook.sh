#!/bin/bash

# Tests for Ralph Wiggum Stop Hook
# Run with: ./tests/test_stop_hook.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
STOP_HOOK="$PLUGIN_ROOT/hooks/stop-hook.sh"

# Test utilities
TESTS_PASSED=0
TESTS_FAILED=0
TEST_TEMP_DIR=""

setup() {
  TEST_TEMP_DIR=$(mktemp -d)
  cd "$TEST_TEMP_DIR" || exit 1
  mkdir -p .claude
  git init -q
}

teardown() {
  cd /
  rm -rf "$TEST_TEMP_DIR"
}

assert_exit_code() {
  local expected=$1
  local actual=$2
  local test_name=$3
  if [[ "$actual" -eq "$expected" ]]; then
    echo "✅ PASS: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "❌ FAIL: $test_name (expected exit $expected, got $actual)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_output_contains() {
  local expected=$1
  local output=$2
  local test_name=$3
  if echo "$output" | grep -q "$expected"; then
    echo "✅ PASS: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "❌ FAIL: $test_name (expected '$expected' in output)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_file_exists() {
  local filepath=$1
  local test_name=$2
  if [[ -f "$filepath" ]]; then
    echo "✅ PASS: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "❌ FAIL: $test_name (file not found: $filepath)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_file_not_exists() {
  local filepath=$1
  local test_name=$2
  if [[ ! -f "$filepath" ]]; then
    echo "✅ PASS: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "❌ FAIL: $test_name (file should not exist: $filepath)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# Create mock transcript file
create_transcript() {
  local output_text="${1:-Hello, I completed the task.}"
  cat > "$TEST_TEMP_DIR/transcript.json" << EOF
{"role":"user","message":{"content":[{"type":"text","text":"Test prompt"}]}}
{"role":"assistant","message":{"content":[{"type":"text","text":"$output_text"}]}}
EOF
}

# Create state file
create_state_file() {
  local iteration="${1:-1}"
  local max_iterations="${2:-0}"
  local promise="${3:-null}"
  local circuit_breaker="${4:-true}"

  cat > .claude/ralph-loop.local.md << EOF
---
active: true
iteration: $iteration
max_iterations: $max_iterations
completion_promise: $promise
circuit_breaker: $circuit_breaker
started_at: "2025-01-01T00:00:00Z"
---

Test prompt for ralph loop
EOF
}

# ============================================
# Test Cases
# ============================================

test_no_state_file_allows_exit() {
  setup
  # No state file - should exit 0 immediately
  local result
  result=$(echo '{}' | "$STOP_HOOK" 2>&1) || true
  local exit_code=$?
  assert_exit_code 0 $exit_code "No state file allows exit"
  teardown
}

test_max_iterations_reached() {
  setup
  create_state_file 10 10
  create_transcript "Done with work"

  local result
  result=$(echo '{"transcript_path": "'$TEST_TEMP_DIR'/transcript.json"}' | "$STOP_HOOK" 2>&1) || true

  assert_output_contains "Max iterations" "$result" "Max iterations message shown"
  assert_file_not_exists ".claude/ralph-loop.local.md" "State file removed after max iterations"
  teardown
}

test_completion_promise_matched() {
  setup
  create_state_file 1 0 '"DONE"'
  create_transcript "Task complete. <promise>DONE</promise>"

  local result
  result=$(echo '{"transcript_path": "'$TEST_TEMP_DIR'/transcript.json"}' | "$STOP_HOOK" 2>&1) || true

  assert_output_contains "Promise fulfilled" "$result" "Promise fulfilled message shown"
  assert_file_not_exists ".claude/ralph-loop.local.md" "State file removed after promise"
  teardown
}

test_completion_promise_not_matched() {
  setup
  create_state_file 1 0 '"DONE"'
  create_transcript "Still working on it..."

  local result
  result=$(echo '{"transcript_path": "'$TEST_TEMP_DIR'/transcript.json"}' | "$STOP_HOOK" 2>&1) || true

  # Should continue loop (output JSON with block decision)
  assert_output_contains '"decision": "block"' "$result" "Loop continues when promise not matched"
  assert_file_exists ".claude/ralph-loop.local.md" "State file preserved when continuing"
  teardown
}

test_iteration_increments() {
  setup
  create_state_file 5 10
  create_transcript "Working..."

  echo '{"transcript_path": "'$TEST_TEMP_DIR'/transcript.json"}' | "$STOP_HOOK" > /dev/null 2>&1 || true

  local new_iteration
  new_iteration=$(grep '^iteration:' .claude/ralph-loop.local.md | sed 's/iteration: *//')

  if [[ "$new_iteration" == "6" ]]; then
    echo "✅ PASS: Iteration increments from 5 to 6"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "❌ FAIL: Iteration should be 6, got $new_iteration"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
  teardown
}

test_invalid_iteration_cleans_up() {
  setup
  # Create state file with invalid iteration
  cat > .claude/ralph-loop.local.md << EOF
---
active: true
iteration: invalid
max_iterations: 10
completion_promise: null
---

Test prompt
EOF

  local result
  result=$(echo '{}' | "$STOP_HOOK" 2>&1) || true

  assert_output_contains "Invalid iteration" "$result" "Invalid iteration detected"
  assert_file_not_exists ".claude/ralph-loop.local.md" "State file removed on invalid state"
  teardown
}

test_circuit_breaker_disabled() {
  setup
  create_state_file 1 0 'null' 'false'
  create_transcript "Working..."

  # With circuit breaker disabled, should just continue
  local result
  result=$(echo '{"transcript_path": "'$TEST_TEMP_DIR'/transcript.json"}' | "$STOP_HOOK" 2>&1) || true

  assert_output_contains '"decision": "block"' "$result" "Loop continues with circuit breaker disabled"
  assert_file_not_exists ".claude/ralph-circuit.local.json" "No circuit file when disabled"
  teardown
}

test_prompt_preserved_in_output() {
  setup
  create_state_file 1 10
  create_transcript "Working..."

  local result
  result=$(echo '{"transcript_path": "'$TEST_TEMP_DIR'/transcript.json"}' | "$STOP_HOOK" 2>&1) || true

  assert_output_contains "Test prompt for ralph loop" "$result" "Original prompt in output"
  teardown
}

test_system_message_contains_iteration() {
  setup
  create_state_file 3 10
  create_transcript "Working..."

  local result
  result=$(echo '{"transcript_path": "'$TEST_TEMP_DIR'/transcript.json"}' | "$STOP_HOOK" 2>&1) || true

  assert_output_contains "iteration 4" "$result" "System message shows next iteration"
  teardown
}

# ============================================
# Run All Tests
# ============================================

echo ""
echo "Ralph Wiggum Stop Hook Tests"
echo "============================"
echo ""

test_no_state_file_allows_exit
test_max_iterations_reached
test_completion_promise_matched
test_completion_promise_not_matched
test_iteration_increments
test_invalid_iteration_cleans_up
test_circuit_breaker_disabled
test_prompt_preserved_in_output
test_system_message_contains_iteration

echo ""
echo "============================"
echo "Results: $TESTS_PASSED passed, $TESTS_FAILED failed"
echo ""

if [[ $TESTS_FAILED -gt 0 ]]; then
  exit 1
fi
