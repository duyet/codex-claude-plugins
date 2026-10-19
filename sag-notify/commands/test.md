---
description: Speak both sag-notify lines to confirm voice, model, and audio work.
---

# /sag-notify:test

Speak the needs-you line and the done line using the snippet in `skills/sag-voice/SKILL.md`, each ending in "This is an audio test." Wait a few seconds, then print `~/.claude/.sag-error.log` if it is non-empty. A 402 means the voice is paid, so suggest `/sag-notify:config`. Ask the user whether they heard both lines.
