---
name: statusline
description: Use when configuring, previewing, troubleshooting, or disabling the Claude Code statusline plugin.
---

# Statusline

Use this skill to help configure and troubleshoot the statusline plugin.

## Workflow

1. Inspect the existing statusline config and scripts before changing settings.
2. For setup, choose layout, visible sections, context display style, separator, and color style.
3. Update the user's Claude settings only when requested or clearly part of setup.
4. Preview the generated statusline command with representative session input.
5. For troubleshooting, check provider detection, rate-limit fields, and empty-section hiding.

## Files

- Commands live in `commands/`.
- Hook configuration lives in `hooks/hooks.json`.
- Runtime scripts live in `scripts/`.
