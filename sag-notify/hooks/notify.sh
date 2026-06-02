#!/usr/bin/env bash
# Claude Code "Notification" hook → speak a short "needs you" alert via sag,
# naming the current project. Configurable via ~/.config/sag-notify/config.json.
# Exits 0 silently on any missing prerequisite so it never blocks or errors a turn.
set -uo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

command -v sag >/dev/null 2>&1 || exit 0
command -v jq  >/dev/null 2>&1 || exit 0
[ "$(cfg '.enabled' 'true')" = "true" ] || exit 0
[ "$(cfg '.events.notification' 'true')" = "true" ] || exit 0
sag_resolve_key || exit 0

# Read the project from the hook JSON cwd; fall back to the current dir.
input=$(cat 2>/dev/null || true)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null || true)
[ -n "$cwd" ] || cwd="$PWD"

name=$(cfg '.self_name' 'Claude')
project=$(sag_project "$cwd")
tmpl=$(cfg '.templates.notification' 'Đây là {name}, project {project} cần bạn xem qua.')

sag_speak "$(sag_render "$tmpl" "$name" "$project")"
exit 0
