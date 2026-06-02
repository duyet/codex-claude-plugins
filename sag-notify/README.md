# sag-notify

Spoken voice notifications for Claude Code via [`sag`](https://github.com/steipete/sag) (ElevenLabs TTS).

- **Needs you** → when Claude waits for permission/input, it speaks a short alert naming the project.
- **Turn done** → when Claude finishes substantive work, it speaks a one-line summary you author.

Both are driven by **auto-injected hooks** — once the plugin is enabled, every session gets them, no per-session setup.

## Requirements

The `sag` CLI must be installed and authenticated. Install with `brew install steipete/tap/sag` and set `ELEVENLABS_API_KEY`. Full guide: [skills/sag-voice/references/sag-cli.md](skills/sag-voice/references/sag-cli.md).

## How it works

| Event | Hook | Behavior |
|-------|------|----------|
| `Notification` | `hooks/notify.sh` | Speaks the notification template, naming the project, in the configured language. (The harness message is English, so it is replaced by the template.) |
| `Stop` | `hooks/summary.sh` | Reads the body Claude wrote to `summary_file`, speaks it via the summary template, deletes the file. **Silent when no file exists**, so trivial turns are quiet. |

To make Claude speak a summary, it writes a short body to `~/.claude/.sag-summary` during a substantive turn. The hook adds the `This is <name>, reporting from project <name>:` framing automatically.

## Setup

1. Install + authenticate `sag` (see Requirements).
2. Enable the plugin (it ships `hooks/hooks.json`).
3. Run `/sag-notify:setup` — checks `sag`/`jq`, resolves the API key, picks a voice, writes config, and tests audio.
4. Or just rely on defaults: Brian voice, English templates, key from the `ELEVENLABS_API_KEY` environment variable.

`ELEVENLABS_API_KEY` must be resolvable — from the environment, or from an optional key file you point `key_file` at in your user config.

## Configuration

User config at `~/.config/sag-notify/config.json` overrides [`config.default.json`](config.default.json). See the **sag-voice** skill or run `/sag-notify:config`. Key settings: `enabled`, `events.{notification,summary}`, `voice_id`, `model_id`, `self_name`, `language`, `key_file`, `summary_file`, `error_log`, `max_chars`, `templates.{notification,summary}`, `languages.<lang>.{notification,summary}`.

### Languages

Set `language` to pick a built-in preset. `en` and `vi` ship by default; add more under `languages.<lang>` (placeholders `{name}`, `{project}`, `{body}`). Resolution: explicit `templates.<kind>` override → `languages.<language>.<kind>` → `languages.en.<kind>`.

```bash
jq '.language = "vi"' ~/.config/sag-notify/config.json > /tmp/c && mv /tmp/c ~/.config/sag-notify/config.json
```

### Voice tiers (important)

`premade` voices work on the **free** ElevenLabs tier. `professional`/library voices return **402 Payment Required** unless you upgrade your plan. The default is **Brian** (`nPczCjzI2devNBz1zQrb`, premade); `eleven_flash_v2_5` is multilingual so a premade voice can speak any language (with an accent). Run `sag voices` to list what your key can use.

## Commands

- `/sag-notify:setup` — guided first-time setup + audio test
- `/sag-notify:config` — change voice, language, templates, toggles
- `/sag-notify:test` — fire both hooks and check `~/.claude/.sag-error.log`

## Troubleshooting

Silent? Check `~/.claude/.sag-error.log` (the hooks log stderr there, never `/dev/null`). A `402` means a paid voice; switch to a premade one. Verify real audio in the **foreground** — the hooks background the call so their exit code can't tell you if sound played.
