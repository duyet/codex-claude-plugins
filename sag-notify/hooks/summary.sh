#!/usr/bin/env bash
# Claude Code "Stop" hook → speak a one-line turn summary via sag, naming the project.
# Claude writes the summary BODY to the configured summary_file during a substantive
# turn; this hook prepends "<name>, project <project>." per the template, speaks it,
# and deletes the file. Silent when the file is absent → trivial turns make no sound.
set -uo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

command -v sag >/dev/null 2>&1 || exit 0
command -v jq  >/dev/null 2>&1 || exit 0
[ "$(cfg '.enabled' 'true')" = "true" ] || exit 0
[ "$(cfg '.events.summary' 'true')" = "true" ] || exit 0
sag_resolve_key || exit 0

sf=$(sag_expand "$(cfg '.summary_file' "$HOME/.claude/.sag-summary")")
[ -f "$sf" ] || exit 0
body=$(cat "$sf" 2>/dev/null || true)
rm -f "$sf"
[ -n "$body" ] || exit 0

# Read the project from the hook JSON cwd; fall back to the current dir.
input=$(cat 2>/dev/null || true)
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null || true)
[ -n "$cwd" ] || cwd="$PWD"

maxlen=$(cfg '.max_chars' '280')
body=${body:0:$maxlen}
name=$(cfg '.self_name' 'Claude')
project=$(sag_project "$cwd")
tmpl=$(sag_template summary)

sag_speak "$(sag_render "$tmpl" "$name" "$project" "$body")"
exit 0
