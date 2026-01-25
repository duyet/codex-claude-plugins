#!/bin/bash
# Statusline SessionStart hook
# Outputs initial status line and enables monitoring for the session

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$SCRIPT_DIR")"

# Fetch rate limits
rate_limits=$("$PLUGIN_ROOT/scripts/fetch-rate-limits.sh" 2>/dev/null)

# Parse rate limit values
if [ -n "$rate_limits" ]; then
    provider=$(echo "$rate_limits" | jq -r '.provider // "anthropic"' 2>/dev/null)
    error=$(echo "$rate_limits" | jq -r '.error // empty' 2>/dev/null)

    if [ "$error" = "scope_required" ]; then
        rate_str="5h: re-login | 7d: needed"
    elif [ -n "$error" ]; then
        rate_str=""
    elif [ "$provider" = "zai" ]; then
        # Parse z.ai data: 5-hour tokens + monthly tools
        tokens_pct=$(echo "$rate_limits" | jq -r '.zai.tokens_pct // 0' 2>/dev/null)
        token_reset=$(echo "$rate_limits" | jq -r '.zai.token_reset // empty' 2>/dev/null)
        monthly_pct=$(echo "$rate_limits" | jq -r '.zai.monthly_pct // 0' 2>/dev/null)
        monthly_remaining=$(echo "$rate_limits" | jq -r '.zai.monthly_remaining // 0' 2>/dev/null)
        monthly_reset=$(echo "$rate_limits" | jq -r '.zai.monthly_reset // empty' 2>/dev/null)
        search=$(echo "$rate_limits" | jq -r '.zai.search // 0' 2>/dev/null)
        web=$(echo "$rate_limits" | jq -r '.zai.web // 0' 2>/dev/null)
        zread=$(echo "$rate_limits" | jq -r '.zai.zread // 0' 2>/dev/null)

        # Build z.ai status string
        zai_parts=("Tokens: ${tokens_pct}%")

        if [ -n "$token_reset" ] && [ "$token_reset" != "null" ]; then
            zai_parts+=("5h reset: ${token_reset}")
        fi

        if [ "$monthly_remaining" -gt 0 ] 2>/dev/null; then
            zai_parts+=("Tools: ${monthly_pct}% (${monthly_remaining} left, ${monthly_reset})")
        fi

        # Add tool usage if non-zero
        tool_parts=""
        if [ "$search" -gt 0 ] 2>/dev/null; then
            tool_parts="Search:${search}"
        fi
        if [ "$web" -gt 0 ] 2>/dev/null; then
            if [ -n "$tool_parts" ]; then tool_parts="$tool_parts "; fi
            tool_parts="${tool_parts}Web:${web}"
        fi
        if [ "$zread" -gt 0 ] 2>/dev/null; then
            if [ -n "$tool_parts" ]; then tool_parts="$tool_parts "; fi
            tool_parts="${tool_parts}ZRead:${zread}"
        fi

        if [ -n "$tool_parts" ]; then
            zai_parts+=("$tool_parts")
        fi

        # Join with pipe separator
        rate_str="z.ai $(IFS='|'; echo "${zai_parts[*]}")"
    else
        # Anthropic shows both 5h and 7d
        u5h=$(echo "$rate_limits" | jq -r '.five_hour // 0' 2>/dev/null)
        u7d=$(echo "$rate_limits" | jq -r '.seven_day // 0' 2>/dev/null)
        u5h_rounded=$(printf "%.0f" "$u5h" 2>/dev/null || echo "0")
        u7d_rounded=$(printf "%.0f" "$u7d" 2>/dev/null || echo "0")
        rate_str="5h: ${u5h_rounded}% | 7d: ${u7d_rounded}%"
    fi
fi

# Build status line
status_parts=()

# Add rate limits if available
if [ -n "$rate_str" ]; then
    status_parts+=("$rate_str")
fi

# Output the status
if [ ${#status_parts[@]} -gt 0 ]; then
    IFS='|'
    echo "📊 ${status_parts[*]}"
fi

exit 0
