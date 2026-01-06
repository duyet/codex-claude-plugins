#!/bin/bash
# Type Detector - Classify plugin by directory structure

detect_plugin_type() {
    local plugin_dir="$1"

    # Check for hooks first (highest priority)
    if [[ -f "$plugin_dir/hooks/hooks.json" ]]; then
        echo "Hook"
        return
    fi

    # Check for agents directory (but not if also has skills)
    if [[ -d "$plugin_dir/agents" ]] && [[ ! -d "$plugin_dir/skills" ]]; then
        echo "Agent"
        return
    fi

    # Check for skills directory
    if [[ -d "$plugin_dir/skills" ]]; then
        echo "Skill"
        return
    fi

    # Check for commands directory only
    if [[ -d "$plugin_dir/commands" ]]; then
        echo "Command"
        return
    fi

    # Default to Config for special cases
    echo "Config"
}
