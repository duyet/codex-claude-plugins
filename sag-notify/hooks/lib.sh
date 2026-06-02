#!/usr/bin/env bash
# Shared helpers for the sag-notify hooks. Sourced by notify.sh and summary.sh.
# Config precedence: user config (~/.config/sag-notify/config.json) → plugin default.

# Plugin root: prefer the env Claude Code sets; fall back to this file's parent dir.
SAG_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SAG_USER_CFG="${SAG_NOTIFY_CONFIG:-$HOME/.config/sag-notify/config.json}"
SAG_DEFAULT_CFG="$SAG_ROOT/config.default.json"

# Expand a leading ~ to $HOME (config values are stored with ~ for portability).
sag_expand() { printf '%s' "${1/#\~/$HOME}"; }

# cfg <jq-path> [fallback] — read a value from user config, then default config.
# NOTE: we deliberately avoid jq's `//` operator — it treats a literal `false` as
# "missing" and would make boolean toggles (enabled, events.*) impossible to turn
# off. Instead we read the raw value and treat the string "null" as "not set".
cfg() {
  local v
  if [ -f "$SAG_USER_CFG" ]; then
    v=$(jq -r "$1" "$SAG_USER_CFG" 2>/dev/null)
    if [ -n "$v" ] && [ "$v" != "null" ]; then printf '%s' "$v"; return; fi
  fi
  if [ -f "$SAG_DEFAULT_CFG" ]; then
    v=$(jq -r "$1" "$SAG_DEFAULT_CFG" 2>/dev/null)
    if [ -n "$v" ] && [ "$v" != "null" ]; then printf '%s' "$v"; return; fi
  fi
  printf '%s' "${2:-}"
}

# Ensure ELEVENLABS_API_KEY is available. Prefer the environment; optionally source
# a user-configured key file (config `key_file`). No key file is assumed by default.
sag_resolve_key() {
  [ -n "${ELEVENLABS_API_KEY:-}" ] && return 0
  local kf; kf=$(sag_expand "$(cfg '.key_file' '')")
  [ -n "$kf" ] && [ -f "$kf" ] && . "$kf" 2>/dev/null || true
  [ -n "${ELEVENLABS_API_KEY:-}" ]
}

# sag_project <cwd> — speakable project name from a directory (hyphens/underscores → spaces).
sag_project() {
  local p; p=$(basename "$1"); printf '%s' "${p//[-_]/ }"
}

# sag_template <notification|summary> — resolve the message template.
# Precedence: explicit `templates.<kind>` override → `languages.<language>.<kind>`
# preset → `languages.en.<kind>` fallback. Lets users pick a language (vi, en, …)
# via the `language` setting, or fully override with their own `templates`.
sag_template() {
  local kind="$1" lang t
  t=$(cfg ".templates.$kind" '')
  [ -n "$t" ] && { printf '%s' "$t"; return; }
  lang=$(cfg '.language' 'en')
  t=$(cfg ".languages.${lang}.${kind}" '')
  [ -n "$t" ] && { printf '%s' "$t"; return; }
  cfg ".languages.en.${kind}" ''
}

# sag_speak <text> — fire-and-forget TTS; errors go to the configured log, never /dev/null.
sag_speak() {
  local voice model log
  voice=$(cfg '.voice_id' 'nPczCjzI2devNBz1zQrb')
  model=$(cfg '.model_id' 'eleven_flash_v2_5')
  log=$(sag_expand "$(cfg '.error_log' "$HOME/.claude/.sag-error.log")")
  mkdir -p "$(dirname "$log")" 2>/dev/null || true
  nohup sag speak --model-id "$model" --voice-id "$voice" "$1" >/dev/null 2>>"$log" &
}

# sag_render <template> <name> <project> [body] — substitute {name}/{project}/{body}.
sag_render() {
  local out="$1"
  out=${out//\{name\}/$2}
  out=${out//\{project\}/$3}
  out=${out//\{body\}/${4:-}}
  printf '%s' "$out"
}
