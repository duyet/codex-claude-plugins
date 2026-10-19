---
description: Change sag-notify voice, language, enabled events, spoken name, or length cap.
---

# /sag-notify:config

Follow the `sag-voice` skill (`skills/sag-voice/SKILL.md`). Ask what to change, copy `config.default.json` to `~/.config/sag-notify/config.json` if it does not exist, and edit it with `jq` through a temp file. Run the skill's foreground audio check after a voice change, then validate with `jq .`.
