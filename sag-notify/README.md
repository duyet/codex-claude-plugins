# sag-notify

Spoken voice notifications for Claude Code via [`sag`](https://github.com/steipete/sag) (ElevenLabs TTS).

- **Needs you** → just before Claude asks you a question, it speaks a short alert naming the project.
- **Turn done** → when Claude finishes substantive work, it speaks a one-line summary of what it did.

Both are **skill-driven**: Claude runs `sag` itself at the right moment, so the spoken line reflects what it actually did or needs. There are no auto-firing hooks and no wrapper script — the **sag-voice** skill teaches Claude when and how to speak.

## Requirements

The `sag` CLI must be installed and authenticated. Install with `brew install steipete/tap/sag` and set `ELEVENLABS_API_KEY`. Full guide: [skills/sag-voice/references/sag-cli.md](skills/sag-voice/references/sag-cli.md).

## How it works

Claude runs `sag` itself at two moments:

| Moment | Speaks (default) |
|--------|------------------|
| Right before asking you (e.g. before `AskUserQuestion`) | `Hi, this is Claude. Project <name> needs you. <reason>` |
| End of a substantive turn | `Hi, this is Claude. Project <name> is done. <summary>` |

Claude names the project from `$PWD`, authors the sentence, and backgrounds the call (`sag speak … &`) with errors logged to `~/.claude/.sag-error.log`. Trivial turns stay quiet because Claude simply doesn't call it. See the **sag-voice** skill for the exact commands.

## Setup

1. Install + authenticate `sag` (see Requirements).
2. Enable the plugin and the **sag-voice** skill.
3. Run `/sag-notify:setup` — checks `sag`/`jq`, resolves the API key, picks a voice, writes config, and tests audio.
4. Or just rely on defaults: Brian voice, English greeting, key from the `ELEVENLABS_API_KEY` environment variable.

`ELEVENLABS_API_KEY` must be resolvable — from the environment, or from an optional key file you point `key_file` at in your user config.

## Configuration

User config at `~/.config/sag-notify/config.json` overrides [`config.default.json`](config.default.json). See the **sag-voice** skill or run `/sag-notify:config`. Key settings: `enabled`, `events.{notification,summary}`, `voice_id`, `model_id`, `self_name`, `language`, `key_file`, `error_log`, `max_chars`.

### Languages

The message wording lives in the **sag-voice** skill (Claude authors the sentence), so there are no templates to edit — any language works. Set `language` to choose the default Claude speaks in (`en` and `vi` are spelled out in the skill); for a one-off, just ask Claude to speak another language.

```bash
jq '.language = "vi"' ~/.config/sag-notify/config.json > /tmp/c && mv /tmp/c ~/.config/sag-notify/config.json
```

### Voice tiers (important)

`premade` voices work on the **free** ElevenLabs tier. `professional`/library voices return **402 Payment Required** unless you upgrade your plan. The default is **Brian** (`nPczCjzI2devNBz1zQrb`, premade); `eleven_flash_v2_5` is multilingual so a premade voice can speak any language (with an accent). Run `sag voices` to list what your key can use.

## Commands

- `/sag-notify:setup` — guided first-time setup + audio test
- `/sag-notify:config` — change voice, language, name, toggles
- `/sag-notify:test` — fire both notification lines and check `~/.claude/.sag-error.log`

## Troubleshooting

Silent? Check `~/.claude/.sag-error.log` (errors are logged there, never `/dev/null`). A `402` means a paid voice; switch to a premade one. Verify real audio in the **foreground** — Claude backgrounds the call (`sag speak … &`), so its exit code can't tell you if sound played.
