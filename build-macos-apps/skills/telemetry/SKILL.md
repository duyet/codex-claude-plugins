---
name: telemetry
description: Add and verify lightweight macOS runtime telemetry. Use when wiring Logger events or inspecting logs for windows, sidebars, menus, and actions.
---

# Telemetry

Use `Logger` (os) with a subsystem and category, read via Console or `log stream --predicate`. Docs: <https://developer.apple.com/documentation/os/logger>.

- No `print` as telemetry. Never log secrets, tokens, personal data, or document contents.
- Signposts only for timing spans.
- Do not claim an event is wired until you saw it in `log stream` or captured output. Remove logs that are not useful afterward.
