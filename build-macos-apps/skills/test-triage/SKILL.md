---
name: test-triage
description: Triage macOS tests across Xcode and SwiftPM. Use when narrowing failures, explaining assertions or crashes, or separating setup from regressions.
---

# Test triage

Use `xcodebuild test` or `swift test` with a filter.

- Run the smallest scope first. No full-suite reruns without new information.
- Classify each failure: compile, assertion, crash, environment, or flake. Separate build failures from failing tests.
- Flag tests that assume iOS-only or simulator-only behavior.
