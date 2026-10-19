# sag-notify

Spoken voice notifications for Claude Code through [`sag`](https://github.com/steipete/sag) (ElevenLabs TTS).

```bash
/plugin install sag-notify@duyet-claude-plugins
/sag-notify:setup
```

## What ships

- `sag-voice` skill. Claude speaks a short line naming the project right before it asks you something, and once when it finishes substantive work. It runs `sag` itself, so there are no hooks and no wrapper script. Trivial turns stay silent.
- `/sag-notify:setup` for first-time setup, `/sag-notify:config` to change settings, and `/sag-notify:test` to hear both lines.

## Requirements

Install `sag` with `brew install steipete/tap/sag` and export `ELEVENLABS_API_KEY`. Premade voices work on the free ElevenLabs tier. Professional voices return 402 Payment Required.

## Config

`~/.config/sag-notify/config.json` overrides `config.default.json`, which holds the default voice, model, name, and language. Keys are listed in the skill. Errors go to `~/.claude/.sag-error.log`, so check it if the notifications are silent.
