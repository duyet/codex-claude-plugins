#!/bin/bash
# Statusline SessionStart hook
# Outputs initial status line and enables monitoring for the session
# shellcheck disable=SC2034

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# Detect model provider from environment
model="${CLAUDE_MODEL:-${ANTHROPIC_MODEL:-}}"
provider="anthropic"
if [[ "$model" == glm* ]]; then
    provider="zai"
fi

# Fetch rate limits using TypeScript CLI (pass model as arg for provider detection)
rate_limits=$(node --no-warnings "$PLUGIN_ROOT/scripts/format-status.ts" "$model" 2>/dev/null)

# Parse rate limit values
if [ -n "$rate_limits" ]; then
    detected_provider=$(echo "$rate_limits" | jq -r '.provider // "anthropic"' 2>/dev/null)
    error=$(echo "$rate_limits" | jq -r '.error // empty' 2>/dev/null)

    if [ "$error" = "scope_required" ]; then
        rate_str="5h: re-login | 7d: needed"
    elif [ -n "$error" ]; then
        rate_str=""
    elif [ "$detected_provider" = "zai" ]; then
        # Parse z.ai data
        tokens_pct=$(echo "$rate_limits" | jq -r '.zai.tokens_pct // 0' 2>/dev/null)
        token_reset=$(echo "$rate_limits" | jq -r '.zai.token_reset // empty' 2>/dev/null)
        monthly_pct=$(echo "$rate_limits" | jq -r '.zai.monthly_pct // 0' 2>/dev/null)
        monthly_remaining=$(echo "$rate_limits" | jq -r '.zai.monthly_remaining // 0' 2>/dev/null)
        monthly_reset=$(echo "$rate_limits" | jq -r '.zai.monthly_reset // empty' 2>/dev/null)
        search=$(echo "$rate_limits" | jq -r '.zai.search // 0' 2>/dev/null)
        web=$(echo "$rate_limits" | jq -r '.zai.web // 0' 2>/dev/null)
        zread=$(echo "$rate_limits" | jq -r '.zai.zread // 0' 2>/dev/null)

        zai_parts=("Tokens: ${tokens_pct}%")
        [ -n "$token_reset" ] && [ "$token_reset" != "null" ] && zai_parts+=("5h reset: ${token_reset}")
        [ "$monthly_remaining" -gt 0 ] 2>/dev/null && zai_parts+=("Tools: ${monthly_pct}% (${monthly_remaining} left, ${monthly_reset})")

        tool_parts=""
        [ "$search" -gt 0 ] 2>/dev/null && tool_parts="Search:${search}"
        [ "$web" -gt 0 ] 2>/dev/null && tool_parts="${tool_parts:+$tool_parts }Web:${web}"
        [ "$zread" -gt 0 ] 2>/dev/null && tool_parts="${tool_parts:+$tool_parts }ZRead:${zread}"
        [ -n "$tool_parts" ] && zai_parts+=("$tool_parts")

        rate_str="z.ai $(IFS='|'; echo "${zai_parts[*]}")"
    else
        # Anthropic
        u5h=$(echo "$rate_limits" | jq -r '.five_hour // 0' 2>/dev/null)
        u7d=$(echo "$rate_limits" | jq -r '.seven_day // 0' 2>/dev/null)
        u5h_rounded=$(printf "%.0f" "$u5h" 2>/dev/null || echo "0")
        u7d_rounded=$(printf "%.0f" "$u7d" 2>/dev/null || echo "0")
        rate_str="5h: ${u5h_rounded}% | 7d: ${u7d_rounded}%"
    fi
fi

# Build status line
status_parts=()
[ -n "$rate_str" ] && status_parts+=("$rate_str")

if [ ${#status_parts[@]} -gt 0 ]; then
    IFS='|'
    echo "📊 ${status_parts[*]}"
fi

exit 0
