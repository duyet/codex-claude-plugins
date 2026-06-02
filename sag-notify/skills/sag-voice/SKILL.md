---
name: sag-voice
description: Use the `sag` CLI (ElevenLabs text-to-speech) to speak text aloud, and drive the sag-notify voice notification hooks. Use when the user asks to speak/say something out loud, install or set up sag, set up or change voice notifications, pick a TTS voice or language, write a spoken turn summary, or troubleshoot why sag produces no sound (e.g. 402 paid-voice errors). Triggers on "sag", "speak this", "say out loud", "voice notification", "text to speech", "ElevenLabs".
---

# sag-voice

`sag` is a command-line ElevenLabs TTS tool with macOS `say`-style UX. This skill covers using it directly and operating the **sag-notify** plugin hooks (spoken "needs you" alerts + per-turn summaries).

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
- **API key**: needs `ELEVENLABS_API_KEY` (or `--api-key`). The hooks read it from the environment, or from an optional `key_file` you set in your user config. See [references/sag-cli.md](references/sag-cli.md).
- **Models**: `eleven_v3` (default, expressive, audio tags, wants 250+ chars), `eleven_multilingual_v2` (stable SSML), `eleven_flash_v2_5` (fast/cheap, multilingual — the hook default), `eleven_turbo_v2_5`.
- **Multilingual**: `eleven_flash_v2_5` speaks non-English with any voice — a non-native voice just carries an accent.

## Voice tiers — the #1 gotcha (402)

`sag voices` shows voices in three categories: `premade`, `professional`, `cloned`/`generated`.
- **`premade`** voices work on the **free** ElevenLabs tier.
- **`professional`/library** voices return **`402 Payment Required`** on free plans ("Free users cannot use library voices via the API"). The call fails — and if stderr was discarded you'd hear nothing with no clue why.

**Always verify audio in the foreground**, because the hooks background the call (`nohup … &`) so their exit code is meaningless:
```bash
sag speak --model-id eleven_flash_v2_5 --voice-id <ID> "test" 2>&1 | grep -iE "failed|402|payment"
```
Empty output = success. A 402 = pick a `premade` voice or upgrade the plan.

## The sag-notify hooks

Two hooks fire automatically once the plugin is enabled (no per-session setup):

| Event | Script | Speaks |
|-------|--------|--------|
| `Notification` (Claude needs you) | `hooks/notify.sh` | An alert naming the project, in the configured language. |
| `Stop` (turn finished) | `hooks/summary.sh` | The body Claude wrote to `summary_file`, framed with name + project. Silent if no file. |

### Writing a spoken summary (the important behavior)

The `Stop` hook only speaks if a summary file exists. To make Claude speak at the end of a **substantive** turn, write a short body to the configured `summary_file` (default `~/.claude/.sag-summary`):

```bash
printf 'finished the X refactor, build is green.' > ~/.claude/.sag-summary
```

Rules for the body:
- Write a **clear, complete sentence** — say *what* happened, not a bare fragment. The template frames it as `... reporting from project <name>: <body>`, so the body must stand on its own. Good: `created the plugin and removed the duplicate hooks.` Bad: `done` (too terse — the listener can't tell what's done).
- Write it in the **configured language** (`language` setting; matches the active templates). Keep it short (≤ `max_chars`, default 280) but a full clause, not a keyword.
- **No prefix, no project name** — the template adds the `This is <name>, reporting from project <name>:` framing automatically.
- Skip it entirely for trivial/chatty turns so they stay silent.
- For a needs-input handoff, phrase the body as a clear request, e.g. `I need you to answer two questions before I continue.`

## Configuration

Config precedence: `~/.config/sag-notify/config.json` (user) overrides the plugin's `config.default.json`. Keys:

| Key | Default | Meaning |
|-----|---------|---------|
| `enabled` | `true` | Master switch |
| `events.notification` / `events.summary` | `true` | Toggle each hook |
| `voice_id` | `nPczCjzI2devNBz1zQrb` (Brian, premade) | ElevenLabs voice |
| `model_id` | `eleven_flash_v2_5` | TTS model |
| `self_name` | `Claude` | Substituted for `{name}` |
| `language` | `en` | Picks a built-in preset from `languages` (e.g. `en`, `vi`) |
| `key_file` | `""` (env only) | If set, sourced when `ELEVENLABS_API_KEY` is unset |
| `summary_file` | `~/.claude/.sag-summary` | Where Claude writes the summary body |
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

Template resolution precedence: `templates.<kind>` (explicit override) → `languages.<language>.<kind>` → `languages.en.<kind>`. Placeholders: `{name}`, `{project}`, and `{body}` (summary only).

**Add a new language** by adding a preset (no code change):
```bash
jq '.languages.fr = {
  "notification": "Ici {name}. Je travaille sur le projet {project} et j’ai besoin de vous.",
  "summary": "Ici {name}, rapport du projet {project} : {body}"
} | .language = "fr"' ~/.config/sag-notify/config.json > /tmp/c && mv /tmp/c ~/.config/sag-notify/config.json
```

Validate after any change: `jq . ~/.config/sag-notify/config.json`.

## Troubleshooting silence

1. `cat ~/.claude/.sag-error.log` — look for `402` (paid voice) or auth errors.
2. `echo ${ELEVENLABS_API_KEY:+set}` (or check your `key_file`) — confirm the key resolves.
3. Run a foreground `sag speak …` as above to see the real error.
4. `jq . ~/.config/sag-notify/config.json` — confirm valid JSON and `enabled: true`.
