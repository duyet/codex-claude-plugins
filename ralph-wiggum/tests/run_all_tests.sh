#!/bin/bash

# Run all Ralph Wiggum tests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Ralph Wiggum Plugin Test Suite     ║"
echo "╚══════════════════════════════════════╝"
echo ""

# shellcheck disable=SC2034
TOTAL_PASSED=0
# shellcheck disable=SC2034
TOTAL_FAILED=0

run_test_file() {
  local test_file=$1
  local test_name=$2

  echo "Running: $test_name"
  echo "----------------------------------------"

  if bash "$test_file"; then
    echo ""
  else
    echo "⚠️  Some tests failed in $test_name"
    echo ""
  fi
}

# Run all test files
run_test_file "$SCRIPT_DIR/test_setup.sh" "Setup Script Tests"
run_test_file "$SCRIPT_DIR/test_stop_hook.sh" "Stop Hook Tests"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║         All Tests Complete           ║"
echo "╚══════════════════════════════════════╝"
echo ""
