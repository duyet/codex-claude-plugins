#!/usr/bin/env bash
# Agent-driven voice notification via sag. The sag-voice skill instructs Claude to
# run this itself — right before it asks you a question, and once at the end of a
# substantive turn — instead of relying on auto-firing hooks.
#
#   speak.sh needs-you "I have two questions before continuing."
#   speak.sh done      "Refactored the hooks into a skill; build is green."
#
# Resolves config from ~/.config/sag-notify/config.json (falls back to the plugin
# default), renders the configured template, names the current project from $PWD,
# and speaks in the background. Exits 0 silently on any missing prerequisite so it
# never blocks a turn.
set -uo pipefail

. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

kind="${1:-done}"
body="${2:-}"

command -v sag >/dev/null 2>&1 || exit 0
command -v jq  >/dev/null 2>&1 || exit 0
[ "$(cfg '.enabled' 'true')" = "true" ] || exit 0
sag_resolve_key || exit 0

# Map the friendly verb to a template kind + the toggle that gates it.
case "$kind" in
  notify|notification|needs-you|needsyou|input|ask) tkind=notification; event=notification ;;
  done|summary|finished|complete)                    tkind=summary;      event=summary ;;
  *)                                                 tkind=summary;      event=summary ;;
esac
[ "$(cfg ".events.$event" 'true')" = "true" ] || exit 0

name=$(cfg '.self_name' 'Claude')
project=$(sag_project "$PWD")
maxlen=$(cfg '.max_chars' '280')
body=${body:0:$maxlen}
tmpl=$(sag_template "$tkind")

sag_speak "$(sag_render "$tmpl" "$name" "$project" "$body")"
exit 0
