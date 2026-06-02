# /sag-notify:test

Speak both notification lines through the current configuration to confirm audio works.

## Action Required

Fire the helper the same way Claude does during a turn, then check the error log.

1. Resolve config values:
   ```
   ! CFG=~/.config/sag-notify/config.json; [ -f "$CFG" ] || CFG="${CLAUDE_PLUGIN_ROOT}/config.default.json"; jq . "$CFG"
   ```

2. **Needs-you line** — names the current project:
   ```
   ! "${CLAUDE_PLUGIN_ROOT}/bin/speak.sh" needs-you "this is an audio test."; echo exit=$?
   ```

3. **Done line** — the end-of-turn summary:
   ```
   ! "${CLAUDE_PLUGIN_ROOT}/bin/speak.sh" done "this is an audio test."; echo exit=$?
   ```

4. **Check for silent failures** (the helper backgrounds the call, so a clean exit ≠ sound):
   ```
   ! sleep 6; [ -s ~/.claude/.sag-error.log ] && cat ~/.claude/.sag-error.log || echo "(no errors — audio played)"
   ```

If the log shows `402 Payment Required`, the configured voice is a paid/library voice — run `/sag-notify:config` to switch to a `premade` voice. Ask the user whether they actually heard both lines.
