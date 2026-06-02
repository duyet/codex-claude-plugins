# /sag-notify:setup

One-time setup for spoken voice notifications via `sag` (ElevenLabs TTS).

## Action Required

Walk the user through setup, doing the work for them where possible:

1. **Check `sag` and `jq`** are installed: `command -v sag jq`. If `sag` is missing, tell the user to install it (it's the ElevenLabs TTS CLI) and stop.

2. **Resolve the API key.** Check `ELEVENLABS_API_KEY` in the env and in the key file (`~/.secret` by default). If absent, instruct the user to add it themselves (do NOT ask them to paste the secret in chat):
   ```
   ! echo "export ELEVENLABS_API_KEY='your-key'" >> ~/.secret
   ```

3. **Pick a voice.** Run `sag voices` and show the `premade` voices (free tier). Use AskUserQuestion to let them choose, or default to Brian (`nPczCjzI2devNBz1zQrb`). Warn that `professional`/library voices need a paid plan (402 error).

4. **Choose language + templates.** Default is Vietnamese (`Đây là {name}, project {project} …`). Offer English as an alternative.

5. **Write user config** to `~/.config/sag-notify/config.json` (create the dir). Start from the plugin's `config.default.json` and apply their choices with `jq`.

6. **Verify audio in the FOREGROUND** (the hooks background the call, so exit codes lie):
   ```
   ! source ~/.secret 2>/dev/null; sag speak --model-id eleven_flash_v2_5 --voice-id <ID> "Đây là Claude. Thiết lập hoàn tất." 2>&1 | grep -iE "failed|402|payment" || echo OK
   ```
   Empty/`OK` = success. A 402 means the voice needs a paid plan — go back to step 3.

7. Confirm the hooks are active and explain that summaries only speak when Claude writes a body to the configured `summary_file`.
