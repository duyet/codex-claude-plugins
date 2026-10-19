---
name: agent-loop-browser
description: Capture browser proof for a PR, such as screenshots of a preview deploy or a check that a UI flow works. Use when an agent-loop worker needs visual or live-page verification.
---

# Agent loop browser

Use whatever browser tool the harness provides. Prefer one attached to the user's session when the page needs login. If none is available, log it and skip. Do not fail the item for it.

Open the PR's preview URL, wait for content rather than a fixed delay, exercise the changed flow, and save a full-page screenshot to a temp directory as `agent-loop-proof-<pr>.png`. Report the path and what it shows. On a 404, report the URL. On a missing login or a failed screenshot, skip and report the page text instead.
