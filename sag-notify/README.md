# sag-notify

Spoken notifications for Claude Code through [`sag`](https://github.com/steipete/sag) (ElevenLabs TTS).

Install: `/plugin install sag-notify@duyet-claude-plugins`, then `/sag-notify:setup`. Needs `sag` and `ELEVENLABS_API_KEY`.

- `sag-voice` skill: speaks before asking you something and once when substantive work finishes.
- `/sag-notify:setup`, `/sag-notify:config`, `/sag-notify:test`.

User config: `~/.config/sag-notify/config.json` overrides `config.default.json`. Errors go to `~/.claude/.sag-error.log`.
