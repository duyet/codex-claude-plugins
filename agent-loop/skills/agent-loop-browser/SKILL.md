---
name: agent-loop-browser
description: >-
  Browser automation and computer-use skill for the agent-loop plugin. Takes
  screenshots, validates UI behavior, fills forms, clicks elements, and
  performs live web proof. Uses existing Chrome session via DevTools MCP.
---

# Agent Loop Browser

Browser automation for the agent-loop. Use this for:

- Taking screenshots of deployed previews for visual validation
- Filling forms, clicking buttons, navigating pages
- Checking live UI behavior as part of PR verification
- Capturing before/after proof for autonomous PRs

## Prerequisites

Prefer the existing Chrome session (logged-in state, extensions, cookies).

### DevTools MCP Check

```bash
# Check if Chrome DevTools MCP is available
mcporter list chrome-devtools --schema 2>/dev/null || echo "MCP not available"
```

If MCP is unavailable, fall back to the `browser` skill's CLI:

```bash
# Check browser CLI
command -v browse >/dev/null 2>&1 || echo "browse CLI not installed"
```

## Page Navigation

```bash
# Navigate to URL
mcporter call chrome-devtools.navigate_page \
  --args '{"url":"https://github.com/owner/repo/pull/123"}' --output text

# Or with browse CLI
browse goto "https://github.com/owner/repo/pull/123"
```

## Taking Snapshots

```bash
# Text snapshot of current page (for understanding layout)
mcporter call chrome-devtools.take_snapshot --args '{}' --output text

# Screenshot for visual proof
mcporter call chrome-devtools.take_screenshot \
  --args '{"filePath":"/tmp/agent-loop-proof.png"}'
```

## Form Filling

```bash
# Fill form elements
mcporter call chrome-devtools.fill \
  --args '{"uid":"1_13","value":"text"}' --output text
```

## Click Elements

```bash
# Click a button/link
mcporter call chrome-devtools.click \
  --args '{"uid":"1_38"}' --output text
```

## Evaluate Script

```bash
# Run JavaScript in page context
mcporter call chrome-devtools.evaluate_script \
  --args '{"function":"() => document.title"}' --output text

# Check CI status from GitHub page
mcporter call chrome-devtools.evaluate_script \
  --args '{"function":"() => document.querySelectorAll('.check-run').length"}' --output text
```

## Visual Validation Workflow

For PR verification requiring UI proof:

```
1. Navigate to preview/deployed URL
2. Wait for page to load (wait_for text or timeout)
3. Take full-page screenshot → save to /tmp/agent-loop-proof-{pr}.png
4. Compare against expected state (if reference exists)
5. Report: "Visual proof captured at {path}"
```

```bash
# Capture proof
mcporter call chrome-devtools.navigate_page \
  --args '{"url":"https://preview.example.com/pr/123"}' --output text
mcporter call chrome-devtools.wait_for \
  --args '{"text":["Dashboard","Loaded"]}' --output text
mcporter call chrome-devtools.take_screenshot \
  --args '{"filePath":"/tmp/agent-loop-proof-123.png","fullPage":true}'
```

## Failure Handling

| Scenario | Action |
|----------|--------|
| MCP not available | Log warning, skip browser step |
| Page not found | Log 404, report broken link |
| Element not found | Wait 2s, retry once, then skip |
| Login required | Skip — cannot automate with isolated session |
| Screenshot fails | Report with page source instead |
