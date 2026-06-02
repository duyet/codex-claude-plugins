# /sag-notify:setup

One-time setup for spoken voice notifications via `sag` (ElevenLabs TTS).

## Action Required

Walk the user through setup, doing the work for them where possible:

1. **Check `sag` and `jq`** are installed: `command -v sag jq`. If `sag` is missing, point them at the install guide [skills/sag-voice/references/sag-cli.md](../skills/sag-voice/references/sag-cli.md) (`brew install steipete/tap/sag`) and stop.

2. **Resolve the API key.** Check `ELEVENLABS_API_KEY` in the environment. If absent, instruct the user to add it themselves (do NOT ask them to paste the secret in chat). Recommend their shell env file so non-interactive shells (where `bin/speak.sh` runs) inherit it:
   ```
   ! echo "export ELEVENLABS_API_KEY='your-key'" >> ~/.zshenv
   ```
   Or, if they keep secrets in a separate file, set `key_file` in their user config to that path.

3. **Choose a language.** Ask which built-in preset (`en`, `vi`, or another they want added). Set `language` in the user config; add a `languages.<lang>` entry if it's a new one.

4. **Pick a voice.** Run `sag voices` and show the `premade` voices (free tier). Use AskUserQuestion to let them choose, or default to Brian (`nPczCjzI2devNBz1zQrb`). Warn that `professional`/library voices need a paid plan (402 error).

5. **Write user config** to `~/.config/sag-notify/config.json` (create the dir). Start from the plugin's `config.default.json` and apply their choices with `jq`.

6. **Verify audio in the FOREGROUND** (the hooks background the call, so exit codes lie):
   ```
   ! sag speak --model-id eleven_flash_v2_5 --voice-id <ID> "<a short test line in their language>" 2>&1 | grep -iE "failed|402|payment" || echo OK
   ```
   Empty/`OK` = success. A 402 means the voice needs a paid plan — go back to step 4.

7. Confirm the **sag-voice** skill is enabled and explain the model: Claude itself runs `${CLAUDE_PLUGIN_ROOT}/bin/speak.sh` — `needs-you` right before it asks a question, and `done` once at the end of a substantive turn. There are no auto-firing hooks, so trivial turns stay silent.
