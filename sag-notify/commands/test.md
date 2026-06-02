# /sag-notify:test

Speak a test line through the current configuration to confirm audio works.

## Action Required

Run both hook paths the same way Claude Code would, then check the error log.

1. Resolve config values:
   ```
   ! CFG=~/.config/sag-notify/config.json; [ -f "$CFG" ] || CFG="${CLAUDE_PLUGIN_ROOT}/config.default.json"; jq . "$CFG"
   ```

2. **Notification path** — fire the hook with a sample cwd so it names a project:
   ```
   ! echo '{"cwd":"/path/to/demo-project"}' | "${CLAUDE_PLUGIN_ROOT}/hooks/notify.sh"; echo exit=$?
   ```

3. **Summary path** — prime a body, then fire the Stop hook (use the configured language for the body):
   ```
   ! printf 'this is an audio test.' > ~/.claude/.sag-summary; echo '{"cwd":"/path/to/demo-project"}' | "${CLAUDE_PLUGIN_ROOT}/hooks/summary.sh"; echo exit=$?
   ```

4. **Check for silent failures** (the hooks background the call, so a clean exit ≠ sound):
   ```
   ! sleep 6; [ -s ~/.claude/.sag-error.log ] && cat ~/.claude/.sag-error.log || echo "(no errors — audio played)"
   ```

If the log shows `402 Payment Required`, the configured voice is a paid/library voice — run `/sag-notify:config` to switch to a `premade` voice. Ask the user whether they actually heard both lines.
