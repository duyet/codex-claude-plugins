# /sag-notify:config

Change voice-notification settings.

## Action Required

The user config lives at `~/.config/sag-notify/config.json` and overrides the plugin's `config.default.json`. If the user config doesn't exist yet, create it by copying the default.

Ask the user (AskUserQuestion) what they want to change, then apply with `jq` (write to a temp file and move it back — never edit JSON in place by hand):

```
mkdir -p ~/.config/sag-notify
[ -f ~/.config/sag-notify/config.json ] || cp "${CLAUDE_PLUGIN_ROOT}/config.default.json" ~/.config/sag-notify/config.json
jq '<filter>' ~/.config/sag-notify/config.json > /tmp/sag-cfg.json && mv /tmp/sag-cfg.json ~/.config/sag-notify/config.json
```

Common changes:
- **Language**: `.language = "vi"` (the skill spells out `en`/`vi`; for other languages just ask Claude to speak them — there are no templates to edit).
- **Voice**: `.voice_id = "<ID>"` (run `sag voices`; premade = free, professional = paid/402).
- **Disable a sound**: `.events.notification = false` or `.events.summary = false`.
- **Turn everything off**: `.enabled = false`.
- **Name**: `.self_name = "..."`.
- **Length cap**: `.max_chars = 200`.
- **Key file**: `.key_file = "~/path/to/keyfile"` (sourced if `ELEVENLABS_API_KEY` is unset).

After changing the voice, verify in the FOREGROUND (the live notification backgrounds the call):
```
! V=$(jq -r .voice_id ~/.config/sag-notify/config.json); M=$(jq -r .model_id ~/.config/sag-notify/config.json); sag speak --model-id "$M" --voice-id "$V" "test" 2>&1 | grep -iE "failed|402" || echo OK
```

Always validate the result: `jq . ~/.config/sag-notify/config.json`.
