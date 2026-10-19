---
name: swiftui-patterns
description: Build macOS SwiftUI scenes and components with desktop patterns. Use when shaping windows, commands, toolbars, settings, split views, or inspectors.
---

# SwiftUI patterns (macOS)

Docs: <https://developer.apple.com/documentation/swiftui> and the macOS HIG.

- Use system-adaptive colors and materials. Do not fill `NavigationSplitView` sidebars or root panes with opaque custom colors.
- Use `WindowGroup(..., id:)` for the primary launch window. A `Window` scene alone will not appear at launch in a menu-bar-plus-window app.
- Keep sidebars simple. Put metadata-heavy content in detail or inspector panes.
- Do not add a view model by reflex. Pick the state owner first.
- For a new app scaffold, split into files and add one `script/build_and_run.sh` (see `build-run-debug`). A single file is only for snippets under about 50 lines.
