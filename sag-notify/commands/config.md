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
- **Voice**: `.voice_id = "<ID>"` (run `sag voices`; premade = free, professional = paid/402).
- **Disable a sound**: `.events.notification = false` or `.events.summary = false`.
- **Turn everything off**: `.enabled = false`.
- **Language → English**: set both templates, e.g. `.templates.notification = "This is {name}, project {project} needs your input."` and `.templates.summary = "This is {name} on project {project}. {body}"`.
- **Name**: `.self_name = "..."`.
- **Length cap**: `.max_chars = 200`.

After changing the voice or templates, verify in the FOREGROUND (hooks background the call):
```
! source ~/.secret 2>/dev/null; sag speak --model-id "$(jq -r .model_id ~/.config/sag-notify/config.json)" --voice-id "$(jq -r .voice_id ~/.config/sag-notify/config.json)" "$(jq -r .templates.summary ~/.config/sag-notify/config.json | sed 's/{name}/Claude/;s/{project}/test/;s/{body}/kiểm tra/')" 2>&1 | grep -iE "failed|402" || echo OK
```

Always validate the result: `jq . ~/.config/sag-notify/config.json`.
