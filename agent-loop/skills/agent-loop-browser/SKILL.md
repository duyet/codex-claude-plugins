---
name: agent-loop-browser
description: Capture browser proof for a PR, such as screenshots of a preview deploy or a check that a UI flow works. Use when an agent-loop worker needs visual or live-page verification.
---

# Agent loop browser

Use whatever browser tool the harness provides: a Chrome DevTools MCP server, a browser-control extension, or a headless CLI such as Playwright. Prefer one attached to the user's existing browser session when the page needs login. If no browser tool is available, log that and skip the browser step. Do not fail the item for it.

## Proof workflow

1. Open the preview or deployed URL for the PR.
2. Wait for text that shows the page loaded, not a fixed delay.
3. Exercise the changed behavior (click, fill, navigate) if the PR changes a flow.
4. Take a full-page screenshot to a temp directory, named `agent-loop-proof-<pr>.png`.
5. Report the screenshot path and what it shows.

## Failure handling

| Case | Action |
|------|--------|
| Page 404 | Report the broken URL |
| Element missing | Retry once after the page settles, then skip |
| Login required and no logged-in session | Skip and report |
| Screenshot fails | Report the page text instead |
