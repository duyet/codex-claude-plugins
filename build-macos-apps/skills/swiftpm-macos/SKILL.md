---
name: swiftpm-macos
description: Build, run, and test SwiftPM macOS packages and executables. Use when the repo is package-first or has no Xcode project.
---

# SwiftPM on macOS

Docs: `swift build --help`, <https://www.swift.org/documentation/package-manager/>.

- Use release mode only when asked.
- A pure package has no app bundle. Library-only packages are not runnable, so say so.
- GUI executables need `.app` staging, see `build-run-debug`.
