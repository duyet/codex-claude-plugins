---
name: sag-voice
description: Speak aloud with the `sag` ElevenLabs CLI and drive sag-notify voice notifications. Use when the user asks to speak or say something out loud, set up or change voice notifications, pick a TTS voice or language, be told by voice when work is done or input is needed, or debug why sag makes no sound.
---

# sag-voice

Run `sag --help`, `sag voices`, and `sag prompting` for usage. Install with `brew install steipete/tap/sag`. Never ask the user to paste the key into chat. You run `sag` yourself (no hooks).

Config: `~/.config/sag-notify/config.json` overrides the plugin's `config.default.json`. Keys: `enabled`, `events.notification`, `events.summary`, `voice_id`, `model_id`, `self_name`, `language`, `key_file` (fallback for `ELEVENLABS_API_KEY`), `error_log`, `max_chars`. Edit with `jq` via a temp file and validate with `jq .`.

When to speak, in the configured `language`:

- **Needs you.** Right before asking a question or handing back for input: `Hi, this is <name>. Project <project> needs you. <reason>`.
- **Done.** Once, as the last action of a turn that did real work: `Hi, this is <name>. Project <project> is done. <summary>`.

The trailing clause says what happened or what you need, under `max_chars`. Stay silent on trivial turns, when `sag` is missing, `enabled` is false, the event flag is off, or no key resolves. A failed announcement must never break the turn.

Run `sag speak` in the background with stderr appended to the error log so it never blocks.

Free-tier ElevenLabs accounts get 402 on professional and library voices. Use premade voices, which speak any language with `eleven_flash_v2_5`. Backgrounded exit codes are meaningless, so test in the foreground and grep for `failed|402|payment`. With no sound check the error log, the key, a foreground run, then the config.
