---
name: liquid-glass
description: Implement and review macOS SwiftUI Liquid Glass UI. Use when adopting system glass, removing conflicting custom chrome, or building glass surfaces.
---

# Liquid Glass (macOS)

Docs: <https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views>. The API is new, so check current docs.

- Let system sidebars, toolbars, sheets, and controls provide glass. Do not rebuild them. Add custom `glassEffect` only for app-specific surfaces.
- No opaque custom backgrounds behind `NavigationSplitView`. Keep related glass in one container.
- Tint only when color carries meaning.
- Do not port iPhone tab bar or search behavior to the Mac.
- A GUI SwiftPM app must be launched as an `.app` bundle (see `build-run-debug`).
