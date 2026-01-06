#!/bin/bash
# Plugin Scanner - Read marketplace.json and return plugin list

scan_plugins() {
    local marketplace_root="$1"
    local marketplace_json="$marketplace_root/.claude-plugin/marketplace.json"

    if [[ ! -f "$marketplace_json" ]]; then
        echo "Error: marketplace.json not found at $marketplace_json" >&2
        return 1
    fi

    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed" >&2
        return 1
    fi

    # Extract plugin sources and remove leading ./
    jq -r '.plugins[].source' "$marketplace_json" 2>/dev/null | sed 's|^\./||' || return 1
}
