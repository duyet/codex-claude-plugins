---
description: One-time setup for spoken voice notifications via sag (ElevenLabs TTS).
---

# /sag-notify:setup

Follow the `sag-voice` skill (`skills/sag-voice/SKILL.md`).

1. Check `command -v sag jq`. If `sag` is missing, give the install line from the skill and stop.
2. Check `ELEVENLABS_API_KEY`. If unset, tell the user to export it in a shell file non-interactive shells read, or to set `key_file` in their config. Do not ask them to paste the key.
3. Ask which language to speak, and let the user pick a premade voice from `sag voices`. The default voice is in `config.default.json`.
4. Create `~/.config/sag-notify/config.json` from `config.default.json` and apply the choices with `jq`.
5. Run the foreground audio check from the skill with a short test line in their language. A 402 means a paid voice, so go back to step 3.
