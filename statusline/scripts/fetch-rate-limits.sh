#!/bin/bash
# Fetch rate limits from Anthropic OAuth API or z.ai API
# Outputs JSON: {"provider": "anthropic"|"zai", "five_hour": N, "seven_day": N, "resets_at": "ISO", "error": "..."}

# Determine model provider from CLAUDE_MODEL environment variable
MODEL="${CLAUDE_MODEL:-}"

# Check if using GLM model (glm-4, glm-4.7, glm-flash, glm-plus, etc.)
if [[ "$MODEL" =~ ^glm- ]]; then
    # Using z.ai / GLM model
    fetch_zai_usage
else
    # Using Anthropic model (default)
    fetch_anthropic_usage
fi

# Fetch usage from z.ai API
fetch_zai_usage() {
    local api_key=""

    # 1. macOS Keychain (primary on macOS) - z.ai may store here
    if [ "$(uname)" = "Darwin" ]; then
        # Try common keychain item names for z.ai/opencode
        local keychain_names=("z.ai" "zai" "opencode" "zai-coding-plan")
        for key_name in "${keychain_names[@]}"; do
            local keychain_data
            keychain_data=$(security find-generic-password -s "$key_name" -w 2>/dev/null)
            if [ -n "$keychain_data" ]; then
                # Try to parse as JSON first, otherwise use raw value
                api_key=$(echo "$keychain_data" | jq -r '.key // .apiKey // .token // empty' 2>/dev/null)
                if [ -z "$api_key" ] || [ "$api_key" = "null" ]; then
                    api_key="$keychain_data"
                fi
                if [ -n "$api_key" ] && [ "$api_key" != "null" ]; then
                    break
                fi
            fi
        done
    fi

    # 2. Environment variable (cross-platform fallback)
    if [ -z "$api_key" ] || [ "$api_key" = "null" ]; then
        api_key="${ZAI_API_KEY:-}"
        if [ -z "$api_key" ]; then
            api_key="${ZAI_CODING_PLAN_KEY:-}"
        fi
    fi

    # 3. File-based credentials (cross-platform)
    if [ -z "$api_key" ] || [ "$api_key" = "null" ]; then
        # Try multiple file locations in order of preference
        local auth_files=(
            "$HOME/.local/share/opencode/auth.json"           # Linux/Unix XDG standard
            "$HOME/.config/opencode/auth.json"                # Alternative XDG location
            "$HOME/.opencode/auth.json"                       # Legacy location
            "$HOME/.zai/auth.json"                            # z.ai specific
        )

        for auth_file in "${auth_files[@]}"; do
            if [ -f "$auth_file" ]; then
                # Try multiple possible key paths in the JSON
                api_key=$(jq -r '.["zai-coding-plan"].key // .zai.key // .apiKey // .key // empty' "$auth_file" 2>/dev/null)
                if [ -n "$api_key" ] && [ "$api_key" != "null" ]; then
                    break
                fi
            fi
        done
    fi

    if [ -z "$api_key" ] || [ "$api_key" = "null" ]; then
        printf '{"provider": "zai", "error": "no_credentials"}\n'
        exit 0
    fi

    # Fetch from z.ai API
    # Note: Authorization header uses API key directly, NOT "Bearer" prefix
    local api_response
    api_response=$(curl -s -m 3 \
        -H "Authorization: $api_key" \
        -H "Content-Type: application/json" \
        "https://api.z.ai/api/monitor/usage/quota/limit" 2>/dev/null)

    if [ -z "$api_response" ]; then
        printf '{"provider": "zai", "error": "api_timeout"}\n'
        exit 0
    fi

    # Check for success
    local success
    success=$(echo "$api_response" | jq -r '.success // false' 2>/dev/null)

    if [ "$success" != "true" ]; then
        printf '{"provider": "zai", "error": "api_error"}\n'
        exit 0
    fi

    # =========================================================================
    # PARSE Z.AI API RESPONSE
    # =========================================================================
    # z.ai has TWO quotas:
    # 1. TOKENS_LIMIT: 5-hour rolling window for token usage
    # 2. TIME_LIMIT: Monthly quota for tools (Search, Web, ZRead)
    # =========================================================================

    # --- 5-Hour Token Quota ---
    local tokens_pct token_reset_ts
    tokens_pct=$(echo "$api_response" | jq -r '
        .data.limits[] |
        select(.type == "TOKENS_LIMIT") |
        .percentage // 0
    ' 2>/dev/null)

    token_reset_ts=$(echo "$api_response" | jq -r '
        .data.limits[] |
        select(.type == "TOKENS_LIMIT") |
        .nextResetTime // empty
    ' 2>/dev/null)

    # --- Monthly Tool Quota (TIME_LIMIT) ---
    local monthly_pct monthly_remaining monthly_reset_ts
    monthly_pct=$(echo "$api_response" | jq -r '
        .data.limits[] |
        select(.type == "TIME_LIMIT") |
        .percentage // 0
    ' 2>/dev/null)

    monthly_remaining=$(echo "$api_response" | jq -r '
        .data.limits[] |
        select(.type == "TIME_LIMIT") |
        .remaining // 0
    ' 2>/dev/null)

    monthly_reset_ts=$(echo "$api_response" | jq -r '
        .data.limits[] |
        select(.type == "TIME_LIMIT") |
        .nextResetTime // empty
    ' 2>/dev/null)

    # --- Tool Usage Details (from TIME_LIMIT) ---
    local search=0 web=0 zread=0
    search=$(echo "$api_response" | jq -r '
        .data.limits[] |
        select(.type == "TIME_LIMIT") |
        .usageDetails[]? |
        select(.modelCode == "search-prime") |
        .usage // 0
    ' 2>/dev/null)

    web=$(echo "$api_response" | jq -r '
        .data.limits[] |
        select(.type == "TIME_LIMIT") |
        .usageDetails[]? |
        select(.modelCode == "web-reader") |
        .usage // 0
    ' 2>/dev/null)

    zread=$(echo "$api_response" | jq -r '
        .data.limits[] |
        select(.type == "TIME_LIMIT") |
        .usageDetails[]? |
        select(.modelCode == "zread") |
        .usage // 0
    ' 2>/dev/null)

    # =========================================================================
    # CALCULATE RESET TIMES
    # =========================================================================

    # 5-hour token quota: "Xh Ym" format
    local token_reset=""
    if [ -n "$token_reset_ts" ] && [ "$token_reset_ts" != "null" ]; then
        local now_s reset_s hours mins
        now_s=$(date +%s)
        reset_s=$((token_reset_ts / 1000))
        hours=$(((reset_s - now_s) / 3600))
        mins=$(((reset_s - now_s) / 60 % 60))
        [ "$hours" -lt 0 ] && hours=0
        [ "$mins" -lt 0 ] && mins=0
        token_reset="${hours}h ${mins}m"
    fi

    # Monthly tool quota: "Xd" format
    local monthly_reset=""
    if [ -n "$monthly_reset_ts" ] && [ "$monthly_reset_ts" != "null" ]; then
        local now_s reset_s days
        now_s=$(date +%s)
        reset_s=$((monthly_reset_ts / 1000))
        days=$(((reset_s - now_s) / 86400))
        [ "$days" -lt 0 ] && days=0
        monthly_reset="${days}d"
    fi

    # =========================================================================
    # OUTPUT JSON
    # =========================================================================
    printf '{
  "provider": "zai",
  "zai": {
    "tokens_pct": %s,
    "token_reset": "%s",
    "monthly_pct": %s,
    "monthly_remaining": %s,
    "monthly_reset": "%s",
    "search": %s,
    "web": %s,
    "zread": %s
  }
}\n' \
        "${tokens_pct:-0}" "${token_reset:-}" \
        "${monthly_pct:-0}" "${monthly_remaining:-0}" "${monthly_reset:-}" \
        "${search:-0}" "${web:-0}" "${zread:-0}"
}

# Fetch usage from Anthropic API
fetch_anthropic_usage() {
    local token=""

    # macOS Keychain (primary on macOS)
    if [ "$(uname)" = "Darwin" ]; then
        local keychain_data
        keychain_data=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null)
        if [ -n "$keychain_data" ]; then
            token=$(echo "$keychain_data" | jq -r '.claudeAiOauth.accessToken // empty' 2>/dev/null)
        fi
    fi

    # Fall back to file-based credentials
    if [ -z "$token" ] || [ "$token" = "null" ]; then
        for cred_path in \
            ~/.claude/.credentials.json \
            ~/.config/claude/.credentials.json \
            ~/.config/claude-code/.credentials.json
        do
            if [ -f "$cred_path" ]; then
                token=$(jq -r '.claudeAiOauth.accessToken // empty' "$cred_path" 2>/dev/null)
                if [ -n "$token" ] && [ "$token" != "null" ]; then
                    break
                fi
            fi
        done
    fi

    if [ -z "$token" ] || [ "$token" = "null" ]; then
        printf '{"provider": "anthropic", "error": "no_credentials"}\n'
        exit 0
    fi

    # Fetch from API
    local api_response
    api_response=$(curl -s -m 3 \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        "https://api.anthropic.com/api/oauth/usage" 2>/dev/null)

    if [ -z "$api_response" ]; then
        printf '{"provider": "anthropic", "error": "api_timeout"}\n'
        exit 0
    fi

    # Check for error
    if echo "$api_response" | jq -e '.error' > /dev/null 2>&1; then
        local error_msg
        error_msg=$(echo "$api_response" | jq -r '.error.message // "unknown"')
        if echo "$error_msg" | grep -qi "scope"; then
            printf '{"provider": "anthropic", "error": "scope_required"}\n'
        else
            printf '{"provider": "anthropic", "error": "api_error"}\n'
        fi
        exit 0
    fi

    # Parse and output
    local u5h u7d r5h
    u5h=$(echo "$api_response" | jq -r '.five_hour.utilization // 0')
    u7d=$(echo "$api_response" | jq -r '.seven_day.utilization // 0')
    r5h=$(echo "$api_response" | jq -r '.five_hour.resets_at // empty')

    printf '{"provider": "anthropic", "five_hour": %s, "seven_day": %s, "resets_at": "%s"}\n' \
        "${u5h:-0}" "${u7d:-0}" "${r5h:-}"
}
