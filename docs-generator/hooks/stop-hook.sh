#!/bin/bash
# Documentation Generator Stop Hook
# Automatically regenerates plugin documentation when implementation changes are detected

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"
MARKETPLACE_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

# Check if docs generator is enabled (default: enabled)
if [[ "${DOCS_GENERATOR_ENABLED:-1}" != "1" ]]; then
    exit 0
fi

# Check for implementation changes (skip doc-only changes to avoid infinite loops)
CHANGED_FILES=$(git -C "$MARKETPLACE_ROOT" diff --name-only HEAD 2>/dev/null || true)

if [[ -n "$CHANGED_FILES" ]]; then
    # Filter out README.md and CLAUDE.md changes
    IMPLEMENTATION_CHANGES=$(echo "$CHANGED_FILES" | grep -vE '^(README\.md|.*/CLAUDE\.md)$' || true)

    if [[ -n "$IMPLEMENTATION_CHANGES" ]]; then
        echo "[docs-generator] Detected implementation changes, regenerating documentation..." >&2

        # Run generation script
        if "$PLUGIN_ROOT/scripts/generate-docs.sh" "$MARKETPLACE_ROOT" 2>&1; then
            echo "[docs-generator] Documentation regenerated successfully" >&2
        else
            echo "[docs-generator] Warning: Documentation generation failed (non-blocking)" >&2
        fi
    fi
fi

# Always exit 0 to allow normal Claude termination
exit 0
