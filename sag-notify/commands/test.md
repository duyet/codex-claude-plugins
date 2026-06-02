# /sag-notify:test

Speak both notification lines through the current configuration to confirm audio works.

## Action Required

Fire the helper the same way Claude does during a turn, then check the error log.

1. Resolve config values:
   ```
   ! CFG=~/.config/sag-notify/config.json; [ -f "$CFG" ] || CFG="${CLAUDE_PLUGIN_ROOT}/config.default.json"; jq . "$CFG"
   ```

2. **Needs-you line** — name the current project and speak the greeting form Claude uses:
   ```
   ! V=$(jq -r '.voice_id // "nPczCjzI2devNBz1zQrb"' "$CFG"); M=$(jq -r '.model_id // "eleven_flash_v2_5"' "$CFG"); P=$(basename "$PWD" | tr '_-' '  '); sag speak --model-id "$M" --voice-id "$V" "Hi, this is Claude. Project $P needs you. This is an audio test." 2>>~/.claude/.sag-error.log &
   ```

3. **Done line** — the end-of-turn summary form:
   ```
   ! V=$(jq -r '.voice_id // "nPczCjzI2devNBz1zQrb"' "$CFG"); M=$(jq -r '.model_id // "eleven_flash_v2_5"' "$CFG"); P=$(basename "$PWD" | tr '_-' '  '); sag speak --model-id "$M" --voice-id "$V" "Hi, this is Claude. Project $P is done. This is an audio test." 2>>~/.claude/.sag-error.log &
   ```

4. **Check for silent failures** (the call is backgrounded, so a clean exit ≠ sound):
   ```
   ! sleep 6; [ -s ~/.claude/.sag-error.log ] && cat ~/.claude/.sag-error.log || echo "(no errors — audio played)"
   ```

If the log shows `402 Payment Required`, the configured voice is a paid/library voice — run `/sag-notify:config` to switch to a `premade` voice. Ask the user whether they actually heard both lines.
