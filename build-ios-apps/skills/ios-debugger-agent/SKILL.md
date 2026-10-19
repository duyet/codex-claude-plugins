---
name: ios-debugger-agent
description: Build, run, and debug iOS apps on Simulator with XcodeBuildMCP. Use when launching an app, inspecting simulator UI or logs, or diagnosing runtime behavior.
---

# iOS debugger agent

Use the XcodeBuildMCP tools (<https://github.com/getsentry/XcodeBuildMCP>). Without it, fall back to `xcrun simctl` and `xcodebuild`, noting that tapping and typing then need a UI test.

- Use a booted simulator. Ask before booting one.
- Set session defaults (project or workspace, scheme, simulator id) before building.
- After a build, confirm the app launched with a UI description or screenshot before interacting.
- Describe the UI before tapping. Prefer `id` or `label` over coordinates.
