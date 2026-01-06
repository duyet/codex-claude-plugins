#!/bin/bash
# Emoji Mapper - Assign emojis to plugins based on keywords

assign_emoji() {
    local name="$1"

    case "$name" in
        *team*)  echo "👥" ;;
        *agent*) echo "🤖" ;;
        *bot*)   echo "🤖" ;;
        *design*) echo "🎨" ;;
        *commit*) echo "📝" ;;
        *status*) echo "📊" ;;
        *loop*)  echo "🔄" ;;
        *wiggum*) echo "🔄" ;;
        *interview*) echo "💬" ;;
        *orchestration*) echo "🎼" ;;
        *terminal*) echo "🖥️" ;;
        *)       echo "🎯" ;;
    esac
}
