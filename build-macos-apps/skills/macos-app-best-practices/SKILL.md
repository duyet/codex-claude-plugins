---
name: macos-app-best-practices
description: Best practices for macOS apps with SwiftUI, AppKit, and Mac Catalyst. Use when architecting a Mac app, choosing scene and window types, wiring menus and commands, or choosing between SwiftUI, AppKit, and Catalyst.
---

# macOS app best practices

Docs: <https://developer.apple.com/design/human-interface-guidelines/designing-for-macos> and <https://developer.apple.com/documentation/swiftui>.

- Choose scenes deliberately (`WindowGroup`, `Window`, `DocumentGroup`, `Settings`, `MenuBarExtra`). Wrap Mac-only scenes and modifiers in `#if os(macOS)` in shared code.
- Wire real menu commands and keyboard shortcuts. Add system command groups only when the scene has the matching content.
- Mac Catalyst can use only Catalyst-available APIs, so AppKit is unavailable there. Exclude incompatible frameworks with platform filters.
