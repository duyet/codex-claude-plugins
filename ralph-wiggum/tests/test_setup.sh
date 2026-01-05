#!/bin/bash

# Tests for Ralph Wiggum Setup Script
# Run with: ./tests/test_setup.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
SETUP_SCRIPT="$PLUGIN_ROOT/scripts/setup-ralph-loop.sh"

# Test utilities
TESTS_PASSED=0
TESTS_FAILED=0
TEST_TEMP_DIR=""

setup() {
  TEST_TEMP_DIR=$(mktemp -d)
  cd "$TEST_TEMP_DIR"
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

assert_file_contains() {
  local filepath=$1
  local expected=$2
  local test_name=$3
  if grep -q "$expected" "$filepath"; then
    echo "✅ PASS: $test_name"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "❌ FAIL: $test_name (expected '$expected' in $filepath)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# ============================================
# Test Cases
# ============================================

test_creates_state_file() {
  setup
  "$SETUP_SCRIPT" "Test prompt" > /dev/null 2>&1 || true
  assert_file_exists ".claude/ralph-loop.local.md" "State file created"
  teardown
}

test_state_file_contains_prompt() {
  setup
  "$SETUP_SCRIPT" "Build a REST API" > /dev/null 2>&1 || true
  assert_file_contains ".claude/ralph-loop.local.md" "Build a REST API" "Prompt in state file"
  teardown
}

test_max_iterations_option() {
  setup
  "$SETUP_SCRIPT" "Test" --max-iterations 25 > /dev/null 2>&1 || true
  assert_file_contains ".claude/ralph-loop.local.md" "max_iterations: 25" "Max iterations set"
  teardown
}

test_completion_promise_option() {
  setup
  "$SETUP_SCRIPT" "Test" --completion-promise "DONE" > /dev/null 2>&1 || true
  assert_file_contains ".claude/ralph-loop.local.md" 'completion_promise: "DONE"' "Completion promise set"
  teardown
}

test_no_circuit_breaker_option() {
  setup
  "$SETUP_SCRIPT" "Test" --no-circuit-breaker > /dev/null 2>&1 || true
  assert_file_contains ".claude/ralph-loop.local.md" "circuit_breaker: false" "Circuit breaker disabled"
  teardown
}

test_default_circuit_breaker_enabled() {
  setup
  "$SETUP_SCRIPT" "Test" > /dev/null 2>&1 || true
  assert_file_contains ".claude/ralph-loop.local.md" "circuit_breaker: true" "Circuit breaker enabled by default"
  teardown
}

test_iteration_starts_at_one() {
  setup
  "$SETUP_SCRIPT" "Test" > /dev/null 2>&1 || true
  assert_file_contains ".claude/ralph-loop.local.md" "iteration: 1" "Iteration starts at 1"
  teardown
}

test_no_prompt_shows_error() {
  setup
  local result
  local exit_code=0
  result=$("$SETUP_SCRIPT" 2>&1) || exit_code=$?
  assert_exit_code 1 $exit_code "No prompt returns error"
  assert_output_contains "No prompt provided" "$result" "Error message shown"
  teardown
}

test_help_option() {
  setup
  local result
  result=$("$SETUP_SCRIPT" --help 2>&1) || true
  assert_output_contains "USAGE" "$result" "Help shows usage"
  assert_output_contains "max-iterations" "$result" "Help mentions options"
  teardown
}

test_multi_word_prompt() {
  setup
  "$SETUP_SCRIPT" Build a REST API with tests > /dev/null 2>&1 || true
  assert_file_contains ".claude/ralph-loop.local.md" "Build a REST API with tests" "Multi-word prompt works"
  teardown
}

test_options_mixed_with_prompt() {
  setup
  "$SETUP_SCRIPT" --max-iterations 10 Fix the bug --completion-promise FIXED > /dev/null 2>&1 || true
  assert_file_contains ".claude/ralph-loop.local.md" "Fix the bug" "Prompt extracted correctly"
  assert_file_contains ".claude/ralph-loop.local.md" "max_iterations: 10" "Max iterations from mixed args"
  assert_file_contains ".claude/ralph-loop.local.md" 'completion_promise: "FIXED"' "Promise from mixed args"
  teardown
}

test_reset_circuit_removes_file() {
  setup
  mkdir -p .claude
  echo '{"test": true}' > .claude/ralph-circuit.local.json
  "$SETUP_SCRIPT" "Test" --reset-circuit > /dev/null 2>&1 || true
  if [[ ! -f ".claude/ralph-circuit.local.json" ]]; then
    echo "✅ PASS: Reset circuit removes circuit file"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    echo "❌ FAIL: Circuit file should be removed"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
  teardown
}

test_output_shows_activation() {
  setup
  local result
  result=$("$SETUP_SCRIPT" "Test" 2>&1) || true
  assert_output_contains "Ralph loop activated" "$result" "Activation message shown"
  teardown
}

# ============================================
# Run All Tests
# ============================================

echo ""
echo "Ralph Wiggum Setup Script Tests"
echo "================================"
echo ""

test_creates_state_file
test_state_file_contains_prompt
test_max_iterations_option
test_completion_promise_option
test_no_circuit_breaker_option
test_default_circuit_breaker_enabled
test_iteration_starts_at_one
test_no_prompt_shows_error
test_help_option
test_multi_word_prompt
test_options_mixed_with_prompt
test_reset_circuit_removes_file
test_output_shows_activation

echo ""
echo "================================"
echo "Results: $TESTS_PASSED passed, $TESTS_FAILED failed"
echo ""

if [[ $TESTS_FAILED -gt 0 ]]; then
  exit 1
fi
