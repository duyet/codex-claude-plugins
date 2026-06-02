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

This plugin is **skill-driven, not hook-driven**: *you* (Claude) run the notifier
yourself at two moments, so the spoken line reflects what you actually did or need.
Do not wait for a hook — there isn't one. Use the bundled helper:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/bin/speak.sh" needs-you "<one clear sentence about what you need>"
bash "${CLAUDE_PLUGIN_ROOT}/bin/speak.sh" done      "<one clear sentence about what you finished>"
```

The helper reads the user's config, names the current project from `$PWD`, renders
the configured template (`Hi, this is Claude. Project <name> needs you. <body>` /
`… is done. <body>` by default), and speaks in the background. It exits silently if
`sag`/`jq`/the API key are missing or the plugin is disabled, so it never blocks you.

### When to speak

1. **Right before you ask the user a question** — immediately *before* you call the
   `AskUserQuestion` tool (or otherwise hand control back for permission/input), run:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/bin/speak.sh" needs-you "I have two questions before I continue."
   ```
   This pings the user to come back. Speak first, then make the `AskUserQuestion` call.

2. **At the end of a substantive turn / session** — once, as the last thing you do
   before yielding, when you finished real work (code changed, task completed, build
   verified):
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/bin/speak.sh" done "Refactored the notifier into a skill; build is green."
   ```

### Rules for the body sentence

- Write **one clear, complete sentence** — say *what* happened or *what* you need, not
  a bare fragment. The template frames it as `Hi, this is Claude. Project <name> is
  done. <body>`, so the body must stand on its own. Good: `Created the plugin and
  removed the duplicate hooks.` Bad: `done` (the listener can't tell what's done).
- Write it in the **configured language** (the `language` setting; default `en`). The
  greeting/framing comes from the template — your body just continues it.
- **No prefix, no project name, no "Claude"** — the template already adds
  `Hi, this is <name>. Project <name> …`. Just supply the substance.
- Keep it short (≤ `max_chars`, default 280) — a full clause, not a keyword dump.
- **Skip it for trivial/chatty turns** so they stay silent. Only speak `done` when the
  turn did substantive work; only speak `needs-you` when you genuinely block on input.
- Speak `done` **at most once** per turn, as the final action.

## Configuration

Config precedence: `~/.config/sag-notify/config.json` (user) overrides the plugin's
`config.default.json`. Keys:

| Key | Default | Meaning |
|-----|---------|---------|
| `enabled` | `true` | Master switch |
| `events.notification` / `events.summary` | `true` | Toggle the `needs-you` / `done` lines |
| `voice_id` | `nPczCjzI2devNBz1zQrb` (Brian, premade) | ElevenLabs voice |
| `model_id` | `eleven_flash_v2_5` | TTS model |
| `self_name` | `Claude` | Substituted for `{name}` |
| `language` | `en` | Picks a built-in preset from `languages` (e.g. `en`, `vi`) |
| `key_file` | `""` (env only) | If set, sourced when `ELEVENLABS_API_KEY` is unset |
| `error_log` | `~/.claude/.sag-error.log` | sag stderr sink (check this if silent) |
| `max_chars` | `280` | Truncate the spoken body |
| `templates.{notification,summary}` | `""` | Optional override; wins over the language preset |
| `languages.<lang>.{notification,summary}` | en, vi shipped | Per-language presets |

### Choosing a language

The shipped config includes `en` and `vi` presets. Just set the language:

```bash
mkdir -p ~/.config/sag-notify
jq '.language = "vi"' ~/.config/sag-notify/config.json > /tmp/c && mv /tmp/c ~/.config/sag-notify/config.json
```

Template resolution precedence: `templates.<kind>` (explicit override) →
`languages.<language>.<kind>` → `languages.en.<kind>`. Placeholders: `{name}`,
`{project}`, and `{body}`.

**Add a new language** by adding a preset (no code change):
```bash
jq '.languages.fr = {
  "notification": "Bonjour, ici {name}. Le projet {project} a besoin de vous. {body}",
  "summary": "Bonjour, ici {name}. Le projet {project} est terminé. {body}"
} | .language = "fr"' ~/.config/sag-notify/config.json > /tmp/c && mv /tmp/c ~/.config/sag-notify/config.json
```

Validate after any change: `jq . ~/.config/sag-notify/config.json`.

## Voice tiers — the #1 gotcha (402)

`sag voices` shows voices in three categories: `premade`, `professional`, `cloned`/`generated`.
- **`premade`** voices work on the **free** ElevenLabs tier.
- **`professional`/library** voices return **`402 Payment Required`** on free plans
  ("Free users cannot use library voices via the API"). The call fails — and because
  the helper backgrounds the call, you'd hear nothing with no clue why.

**Verify a voice in the foreground** before trusting it (the helper backgrounds the
call, so its exit code is meaningless):
```bash
sag speak --model-id eleven_flash_v2_5 --voice-id <ID> "test" 2>&1 | grep -iE "failed|402|payment"
```
Empty output = success. A 402 = pick a `premade` voice or upgrade the plan.

## Troubleshooting silence

1. `cat ~/.claude/.sag-error.log` — look for `402` (paid voice) or auth errors.
2. `echo ${ELEVENLABS_API_KEY:+set}` (or check your `key_file`) — confirm the key resolves.
3. Run a foreground `sag speak …` as above to see the real error.
4. `jq . ~/.config/sag-notify/config.json` — confirm valid JSON and `enabled: true`.
5. Fire the helper directly: `bash "${CLAUDE_PLUGIN_ROOT}/bin/speak.sh" done "audio test"`.
