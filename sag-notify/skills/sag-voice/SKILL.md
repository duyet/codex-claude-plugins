---
name: sag-voice
description: Speak aloud with the `sag` ElevenLabs CLI and drive sag-notify voice notifications. Use when the user asks to speak or say something out loud, set up or change voice notifications, pick a TTS voice or language, be told by voice when work is done or input is needed, or debug why sag makes no sound.
---

# sag-voice

[`sag`](https://github.com/steipete/sag) is an ElevenLabs text-to-speech CLI. Install it with `brew install steipete/tap/sag` and export `ELEVENLABS_API_KEY`. Use `sag --help`, `sag voices`, and `sag prompting` for options. Never ask the user to paste the key into chat.

This plugin is skill-driven, not hook-driven. You run `sag` yourself at the moments below, so the spoken line says what you did or need.

## Speak

Read settings from the user config, falling back to the plugin's `config.default.json`, which holds the default voice and model.

```bash
CFG=~/.config/sag-notify/config.json
[ -f "$CFG" ] || CFG="<plugin dir>/config.default.json"
NAME=$(jq -r '.self_name' "$CFG"); VOICE=$(jq -r '.voice_id' "$CFG"); MODEL=$(jq -r '.model_id' "$CFG")
PROJECT=$(basename "$PWD" | tr '_-' '  ')
sag speak --model-id "$MODEL" --voice-id "$VOICE" \
  "Hi, this is $NAME. Project $PROJECT is done. <summary>" 2>>~/.claude/.sag-error.log &
```

Always background the call and send errors to the log so it never blocks the turn. Skip silently if `sag` is missing, `enabled` is false, the matching `events.*` flag is false, or `ELEVENLABS_API_KEY` is unset (and `key_file` does not provide it). Never let a failed announcement break the turn.

## When to speak

- **Needs you.** Immediately before asking the user a question or handing control back for input: `Hi, this is <name>. Project <project> needs you. <reason>`. Speak first, then ask.
- **Done.** Once, as the last action of a turn that did real work (code changed, task finished, build verified): `Hi, this is <name>. Project <project> is done. <summary>`.

Stay silent on trivial or chatty turns. The trailing sentence is one clear clause saying what happened or what you need, under `max_chars`. "Done" alone tells the listener nothing. Speak in the configured `language`. In Vietnamese the greeting is `Chào, mình là <name>. Project <project> đã xong. <summary>`. Any other language works too because you write the sentence.

## Config

`~/.config/sag-notify/config.json` overrides `config.default.json`. Change it with `jq` through a temp file, then validate with `jq .`.

| Key                                     | Meaning                                                           |
| --------------------------------------- | ----------------------------------------------------------------- |
| `enabled`                               | Master switch                                                     |
| `events.notification`, `events.summary` | Toggle the needs-you and done lines                               |
| `voice_id`, `model_id`                  | ElevenLabs voice and model                                        |
| `self_name`                             | Name in the greeting                                              |
| `language`                              | Language of the spoken line                                       |
| `key_file`                              | File to read `ELEVENLABS_API_KEY` from when the variable is unset |
| `error_log`                             | Where sag stderr goes                                             |
| `max_chars`                             | Length cap for the trailing sentence                              |

## Voice tiers and 402

`sag voices` lists `premade`, `professional`, and `cloned` voices. Premade voices work on the free tier. Professional and library voices return 402 Payment Required on free plans, and because the call is backgrounded the failure is silent. `eleven_flash_v2_5` is multilingual, so a premade voice speaks any language with an accent.

## Verify and debug

Backgrounded exit codes mean nothing, so test in the foreground.

```bash
sag speak --model-id "$MODEL" --voice-id "$VOICE" "audio test" 2>&1 | grep -iE "failed|402|payment" || echo OK
```

If there is no sound, check in order: the error log, whether the API key resolves, a foreground run as above, and that the config is valid JSON with `enabled: true`.
