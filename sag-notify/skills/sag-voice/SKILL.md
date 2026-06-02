---
name: sag-voice
description: Use the `sag` CLI (ElevenLabs text-to-speech) to speak text aloud, and drive sag-notify voice notifications. Use when the user asks to speak/say something out loud, install or set up sag, set up or change voice notifications, pick a TTS voice or language, announce that work is done or that you need their input by voice, or troubleshoot why sag produces no sound (e.g. 402 paid-voice errors). Triggers on "sag", "speak this", "say out loud", "voice notification", "text to speech", "ElevenLabs", "notify me when done".
---

# sag-voice

`sag` is a command-line ElevenLabs TTS tool with macOS `say`-style UX. This skill covers using it directly and driving **sag-notify** voice notifications — short spoken alerts that name the current project, spoken by Claude itself at the right moments.

**Installing / authenticating `sag` itself** → see [references/sag-cli.md](references/sag-cli.md) (`brew install steipete/tap/sag`, API key setup, env vars, models, voices).

## Speaking text directly

```bash
sag "Hello"                                             # default voice, streams to speakers
sag speak --model-id eleven_flash_v2_5 --voice-id <ID> "..."
echo 'piped text' | sag
sag voices            # list voices available to the current API key
sag prompting         # model-specific prompting tips
```

Key facts:
- **API key**: needs `ELEVENLABS_API_KEY` (or `--api-key`). The notifier reads it from the environment, or from an optional `key_file` you set in your user config. See [references/sag-cli.md](references/sag-cli.md).
- **Models**: `eleven_v3` (default, expressive, audio tags, wants 250+ chars), `eleven_multilingual_v2` (stable SSML), `eleven_flash_v2_5` (fast/cheap, multilingual — the notifier default), `eleven_turbo_v2_5`.
- **Multilingual**: `eleven_flash_v2_5` speaks non-English with any voice — a non-native voice just carries an accent.

## Proactive voice notifications (the main behavior)

This plugin is **skill-driven, not hook-driven**: *you* (Claude) call `sag` yourself
at two moments, so the spoken line reflects what you actually did or need. There is no
hook and no wrapper script — you run `sag speak …` directly via Bash.

Build the line from this shape (English default; speak in the user's `language` if set):

```bash
PROJECT=$(basename "$PWD" | tr '_-' '  ')
sag speak --model-id eleven_flash_v2_5 --voice-id nPczCjzI2devNBz1zQrb \
  "Hi, this is Claude. Project $PROJECT is done. <one-sentence summary>" \
  2>>~/.claude/.sag-error.log &
```

- Always **background the call** (`… &`) and redirect errors to the log (`2>>…`) so it
  never blocks your turn or pollutes output.
- `tr '_-' '  '` turns `claude-plugins` into the speakable `claude plugins`.
- The default voice is **Brian** (`nPczCjzI2devNBz1zQrb`, premade/free) on
  `eleven_flash_v2_5`. If the user set a different `voice_id`/`model_id` in their config,
  read and use those instead (one-liner under *Honoring the user's config* below).

### When to speak

1. **Right before you ask the user a question** — immediately *before* you call the
   `AskUserQuestion` tool (or otherwise hand control back for permission/input):
   ```bash
   PROJECT=$(basename "$PWD" | tr '_-' '  ')
   sag speak --model-id eleven_flash_v2_5 --voice-id nPczCjzI2devNBz1zQrb \
     "Hi, this is Claude. Project $PROJECT needs you. I have two questions before I continue." \
     2>>~/.claude/.sag-error.log &
   ```
   Speak first, then make the `AskUserQuestion` call.

2. **At the end of a substantive turn** — once, as the last thing you do before
   yielding, when you finished real work (code changed, task completed, build verified):
   ```bash
   PROJECT=$(basename "$PWD" | tr '_-' '  ')
   sag speak --model-id eleven_flash_v2_5 --voice-id nPczCjzI2devNBz1zQrb \
     "Hi, this is Claude. Project $PROJECT is done. Refactored the notifier to call sag directly." \
     2>>~/.claude/.sag-error.log &
   ```

### Wording rules

- Two fixed openings: **`Hi, this is Claude. Project <name> needs you. <reason>`** and
  **`Hi, this is Claude. Project <name> is done. <summary>`**. Keep that greeting + project
  frame; only the trailing sentence changes.
- The trailing sentence must be **one clear, complete clause** — say *what* happened or
  *what* you need. Good: `Created the plugin and removed the duplicate hooks.` Bad:
  `done` (the listener can't tell what's done). Keep it under ~280 chars.
- Speak in the user's **`language`** (default `en`). Vietnamese form:
  `Chào, mình là Claude. Project <name> đã xong. <summary>` /
  `… cần bạn xem qua. <reason>`.
- **Skip it for trivial/chatty turns** so they stay silent. Only speak the "done" line
  when the turn did substantive work; only speak "needs you" when you genuinely block on
  input. Speak "done" **at most once** per turn, as the final action.

### Honoring the user's config

The defaults above work with no config. If you want to respect a user's chosen voice,
model, name, or language, read them inline before speaking (each falls back to the default):

```bash
CFG=~/.config/sag-notify/config.json
[ -f "$CFG" ] || CFG="${CLAUDE_PLUGIN_ROOT}/config.default.json"
NAME=$(jq -r '.self_name // "Claude"' "$CFG" 2>/dev/null)
VOICE=$(jq -r '.voice_id // "nPczCjzI2devNBz1zQrb"' "$CFG" 2>/dev/null)
MODEL=$(jq -r '.model_id // "eleven_flash_v2_5"' "$CFG" 2>/dev/null)
PROJECT=$(basename "$PWD" | tr '_-' '  ')
sag speak --model-id "$MODEL" --voice-id "$VOICE" \
  "Hi, this is $NAME. Project $PROJECT is done. <summary>" 2>>~/.claude/.sag-error.log &
```

Skip the whole thing silently if `sag` isn't installed (`command -v sag` fails),
`enabled` is `false`, or there's no `ELEVENLABS_API_KEY` — never let it error your turn.

## Configuration

Config precedence: `~/.config/sag-notify/config.json` (user) overrides the plugin's
`config.default.json`. Keys:

| Key | Default | Meaning |
|-----|---------|---------|
| `enabled` | `true` | Master switch |
| `events.notification` / `events.summary` | `true` | Toggle the `needs-you` / `done` lines |
| `voice_id` | `nPczCjzI2devNBz1zQrb` (Brian, premade) | ElevenLabs voice |
| `model_id` | `eleven_flash_v2_5` | TTS model |
| `self_name` | `Claude` | Spoken name in the greeting |
| `language` | `en` | Default language for the spoken line (`en`/`vi` built into this skill) |
| `key_file` | `""` (env only) | If set, sourced when `ELEVENLABS_API_KEY` is unset |
| `error_log` | `~/.claude/.sag-error.log` | sag stderr sink (check this if silent) |
| `max_chars` | `280` | Keep the trailing sentence under this length |

There are **no message templates** — you (Claude) author the sentence yourself using
the fixed greeting forms in *Wording rules* above. The wording lives in this skill,
not in config, so any language works: just speak the line in the user's `language`
(or whatever language they ask for in the moment).

```bash
mkdir -p ~/.config/sag-notify
jq '.language = "vi"' ~/.config/sag-notify/config.json > /tmp/c && mv /tmp/c ~/.config/sag-notify/config.json
```

Validate after any change: `jq . ~/.config/sag-notify/config.json`.

## Voice tiers — the #1 gotcha (402)

`sag voices` shows voices in three categories: `premade`, `professional`, `cloned`/`generated`.
- **`premade`** voices work on the **free** ElevenLabs tier.
- **`professional`/library** voices return **`402 Payment Required`** on free plans
  ("Free users cannot use library voices via the API"). The call fails — and because
  you background the call (`… &`), you'd hear nothing with no clue why.

**Verify a voice in the foreground** before trusting it (a backgrounded call's exit
code is meaningless):
```bash
sag speak --model-id eleven_flash_v2_5 --voice-id <ID> "test" 2>&1 | grep -iE "failed|402|payment"
```
Empty output = success. A 402 = pick a `premade` voice or upgrade the plan.

## Troubleshooting silence

1. `cat ~/.claude/.sag-error.log` — look for `402` (paid voice) or auth errors.
2. `echo ${ELEVENLABS_API_KEY:+set}` (or check your `key_file`) — confirm the key resolves.
3. Run a foreground `sag speak …` as above to see the real error.
4. `jq . ~/.config/sag-notify/config.json` — confirm valid JSON and `enabled: true`.
5. Speak a foreground test line: `sag speak --model-id eleven_flash_v2_5 --voice-id nPczCjzI2devNBz1zQrb "audio test"`.
