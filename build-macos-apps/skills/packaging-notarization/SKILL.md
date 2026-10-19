---
name: packaging-notarization
description: Prepare macOS packaging and notarization workflows. Use when archiving apps, validating bundles, or explaining distribution-only failures.
---

# Packaging and notarization

Docs: <https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution> (`xcrun notarytool --help`).

- Notarization is a distribution step. Do not present it as required for local debug runs.
- Validate the bundle (`codesign`, `spctl`) before submitting. Keep distribution failures separate from local signing failures.
