---
name: sag-voice
description: Use the `sag` CLI (ElevenLabs text-to-speech) to speak text aloud, and drive the sag-notify voice notification hooks. Use when the user asks to speak/say something out loud, set up or change voice notifications, pick a TTS voice or language, write a spoken turn summary, or troubleshoot why sag produces no sound (e.g. 402 paid-voice errors). Triggers on "sag", "speak this", "say out loud", "voice notification", "text to speech", "ElevenLabs".
---

# sag-voice

`sag` is a command-line ElevenLabs TTS tool with macOS `say`-style UX. This skill covers using it directly and operating the **sag-notify** plugin hooks (spoken "needs you" alerts + per-turn summaries).

## Speaking text directly

```bash
sag "Hello"                                             # default voice, streams to speakers
sag speak --model-id eleven_flash_v2_5 --voice-id <ID> "..."
echo 'piped text' | sag
sag voices            # list voices available to the current API key
sag prompting         # model-specific prompting tips
```

Key facts:
- **API key**: needs `ELEVENLABS_API_KEY` (or `--api-key`). The hooks source it from the configured `key_file` (default `~/.secret`) if it's not in the env.
- **Models**: `eleven_v3` (default, expressive, audio tags, wants 250+ chars), `eleven_multilingual_v2` (stable SSML), `eleven_flash_v2_5` (fast/cheap, multilingual — the hook default), `eleven_turbo_v2_5`.
- **Multilingual**: `eleven_flash_v2_5` speaks non-English (e.g. Vietnamese) with any voice — a non-native voice just carries an accent.

## Voice tiers — the #1 gotcha (402)

`sag voices` shows voices in three categories: `premade`, `professional`, `cloned`/`generated`.
- **`premade`** voices work on the **free** ElevenLabs tier.
- **`professional`/library** voices return **`402 Payment Required`** on free plans ("Free users cannot use library voices via the API"). The call fails — and if stderr was discarded you'd hear nothing with no clue why.

**Always verify audio in the foreground**, because the hooks background the call (`nohup … &`) so their exit code is meaningless:
```bash
source ~/.secret
sag speak --model-id eleven_flash_v2_5 --voice-id <ID> "test" 2>&1 | grep -iE "failed|402|payment"
```
Empty output = success. A 402 = pick a `premade` voice or upgrade the plan.

## The sag-notify hooks

Two hooks fire automatically once the plugin is enabled (no per-session setup):

| Event | Script | Speaks |
|-------|--------|--------|
| `Notification` (Claude needs you) | `hooks/notify.sh` | A fixed alert naming the project. Harness message is English, so it's replaced by the configured template. |
| `Stop` (turn finished) | `hooks/summary.sh` | The body Claude wrote to `summary_file`, prefixed with name + project. Silent if no file. |

### Writing a spoken summary (the important behavior)

The `Stop` hook only speaks if a summary file exists. To make Claude speak at the end of a **substantive** turn, write a short body to the configured `summary_file` (default `~/.claude/.sag-summary`):

```bash
printf 'đã xong phần X, build xanh.' > ~/.claude/.sag-summary
```

Rules for the body:
- Write a **clear, complete sentence** — say *what* happened, not a bare fragment. The template frames it as `... báo cáo từ project <name>: <body>`, so the body must stand on its own. Good: `đã tạo xong plugin và gỡ các hook trùng lặp.` Bad: `xong rồi` (too terse — the listener can't tell what's done).
- Write it in the configured **language** (default Vietnamese). Keep it short (≤ `max_chars`, default 280) but a full clause, not a keyword.
- **No prefix, no project name** — the template adds the `Đây là Claude, báo cáo từ project <name>:` framing automatically.
- Skip it entirely for trivial/chatty turns so they stay silent.
- For a needs-input handoff, phrase the body as a clear request, e.g. `cần bạn trả lời hai câu hỏi trước khi mình làm tiếp.`

## Configuration

Config precedence: `~/.config/sag-notify/config.json` (user) overrides the plugin's `config.default.json`. Keys:

| Key | Default | Meaning |
|-----|---------|---------|
| `enabled` | `true` | Master switch |
| `events.notification` / `events.summary` | `true` | Toggle each hook |
| `voice_id` | `nPczCjzI2devNBz1zQrb` (Brian, premade) | ElevenLabs voice |
| `model_id` | `eleven_flash_v2_5` | TTS model |
| `self_name` | `Claude` | Substituted for `{name}` |
| `language` | `vi` | Informational; templates carry the actual wording |
| `key_file` | `~/.secret` | Sourced if `ELEVENLABS_API_KEY` is unset |
| `summary_file` | `~/.claude/.sag-summary` | Where Claude writes the summary body |
| `error_log` | `~/.claude/.sag-error.log` | sag stderr sink (check this if silent) |
| `max_chars` | `280` | Truncate the spoken body |
| `templates.notification` | `Đây là {name}. Mình đang làm ở project {project}, cần bạn xem qua một chút.` | `{name}`,`{project}` |
| `templates.summary` | `Đây là {name}, báo cáo từ project {project}: {body}` | `{name}`,`{project}`,`{body}` |

To switch to the paid native Vietnamese voice after upgrading the plan, set `voice_id` to `FTYCiQT21H9XQvhRu0ch` (Minh Trung). To switch to English, change the two templates (e.g. `This is {name} on project {project}. {body}`).

Edit config safely with jq:
```bash
mkdir -p ~/.config/sag-notify
jq '.voice_id = "JBFqnCBsd6RMkjVDRZzb"' ~/.config/sag-notify/config.json > /tmp/c && mv /tmp/c ~/.config/sag-notify/config.json
```

## Troubleshooting silence

1. `cat ~/.claude/.sag-error.log` — look for `402` (paid voice) or auth errors.
2. `source ~/.secret; echo ${ELEVENLABS_API_KEY:+set}` — confirm the key resolves.
3. Run a foreground `sag speak …` as above to see the real error.
4. `jq . ~/.config/sag-notify/config.json` — confirm valid JSON and `enabled: true`.
