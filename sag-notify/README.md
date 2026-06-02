# sag-notify

Spoken voice notifications for Claude Code via [`sag`](https://github.com/) (ElevenLabs TTS).

- **Needs you** → when Claude waits for permission/input, it speaks a short alert naming the project.
- **Turn done** → when Claude finishes substantive work, it speaks a one-line summary you author.

Both are driven by **auto-injected hooks** — once the plugin is enabled, every session gets them, no per-session setup.

## How it works

| Event | Hook | Behavior |
|-------|------|----------|
| `Notification` | `hooks/notify.sh` | Speaks `templates.notification` with the project name. The harness message is English, so it's replaced by your (Vietnamese by default) template. |
| `Stop` | `hooks/summary.sh` | Reads the body Claude wrote to `summary_file`, speaks it via `templates.summary`, deletes the file. **Silent when no file exists**, so trivial turns are quiet. |

To make Claude speak a summary, it writes a short body to `~/.claude/.sag-summary` during a substantive turn. The hook adds the `Đây là Claude, project <name>.` prefix.

## Setup

1. Enable the plugin (it ships `hooks/hooks.json`).
2. Run `/sag-notify:setup` — checks `sag`/`jq`, resolves the API key, picks a voice, writes config, and tests audio.
3. Or just rely on defaults: Brian voice, Vietnamese, key from `~/.secret`.

`ELEVENLABS_API_KEY` must be resolvable — from the env or the configured `key_file` (default `~/.secret`).

## Configuration

User config at `~/.config/sag-notify/config.json` overrides [`config.default.json`](config.default.json). See the **sag-voice** skill or run `/sag-notify:config`. Key settings: `enabled`, `events.{notification,summary}`, `voice_id`, `model_id`, `self_name`, `language`, `key_file`, `summary_file`, `error_log`, `max_chars`, `templates.{notification,summary}`.

### Voice tiers (important)

`premade` voices work on the **free** ElevenLabs tier. `professional`/library voices (e.g. the native Vietnamese "Minh Trung" `FTYCiQT21H9XQvhRu0ch`) return **402 Payment Required** unless you upgrade. Default is **Brian** (`nPczCjzI2devNBz1zQrb`, premade) speaking Vietnamese via the multilingual `eleven_flash_v2_5` model.

## Commands

- `/sag-notify:setup` — guided first-time setup + audio test
- `/sag-notify:config` — change voice, language, templates, toggles
- `/sag-notify:test` — fire both hooks and check `~/.claude/.sag-error.log`

## Troubleshooting

Silent? Check `~/.claude/.sag-error.log` (the hooks log stderr there, never `/dev/null`). A `402` means a paid voice; switch to a premade one. Verify real audio in the **foreground** — the hooks background the call so their exit code can't tell you if sound played.
