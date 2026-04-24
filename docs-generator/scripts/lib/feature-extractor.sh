#!/bin/bash
# Feature Extractor - Extract commands, agents, skills from plugin directories
# shellcheck disable=SC2034,SC2155

extract_commands() {
    local plugin_dir="$1"

    if [[ ! -d "$plugin_dir/commands" ]]; then
        return
    fi

    for cmd_file in "$plugin_dir/commands"/*.md; do
        [[ -f "$cmd_file" ]] || continue

        local name=$(basename "$cmd_file" .md)
        local desc=$(grep -m1 '^description:' "$cmd_file" 2>/dev/null | sed 's/description: *//' || echo "")

        if [[ -n "$desc" ]]; then
            echo "  - \`/$name\`: $desc"
        else
            echo "  - \`/$name\`"
        fi
    done
}

extract_agents() {
    local plugin_dir="$1"

    if [[ ! -d "$plugin_dir/agents" ]]; then
        return
    fi

    for agent_file in "$plugin_dir/agents"/*.md; do
        [[ -f "$agent_file" ]] || continue

        local name=$(basename "$agent_file" .md)
        local role=$(grep -m1 '^role:' "$agent_file" 2>/dev/null | sed 's/role: *//' || echo "")
        local model=$(grep -m1 '^model:' "$agent_file" 2>/dev/null | sed 's/model: *//' || echo "")

        if [[ -n "$role" ]]; then
            if [[ -n "$model" ]]; then
                echo "  - **$name** ($model): $role"
            else
                echo "  - **$name**: $role"
            fi
        else
            echo "  - **$name**"
        fi
    done
}

extract_skills() {
    local plugin_dir="$1"

    if [[ ! -d "$plugin_dir/skills" ]]; then
        return
    fi

    for skill_dir in "$plugin_dir/skills"/*; do
        [[ -d "$skill_dir" ]] || continue

        local name=$(basename "$skill_dir")
        echo "  - **$name**"
    done
}

generate_file_tree() {
    local plugin_dir="$1"
    local plugin_name=$(basename "$plugin_dir")

    echo "├── agents/                      # Sub-agent definitions"
    echo "├── commands/                    # Slash commands"
    echo "├── skills/                      # Reusable knowledge"
    echo "└── hooks/hooks.json             # Lifecycle hooks (optional)"
}

get_plugin_description() {
    local plugin_dir="$1"
    local plugin_json="$plugin_dir/.claude-plugin/plugin.json"

    if [[ -f "$plugin_json" ]] && command -v jq &> /dev/null; then
        jq -r '.description // empty' "$plugin_json" 2>/dev/null
    fi
}
