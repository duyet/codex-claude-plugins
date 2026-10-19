---
name: window-management
description: Customize macOS SwiftUI windows and scene behavior. Use when tuning window chrome, drag regions, placement, restoration, launch behavior, or borderless windows.
---

# Window management

Docs: <https://developer.apple.com/documentation/swiftui/windows>.

- Try SwiftUI scene and window modifiers before mutating `NSWindow` (then see `appkit-interop`).
- Do not hide the toolbar or its background without a replacement. Do not use `.toolbar(removing: .title)` to hide an unset title.
- Do not disable restoration on the main document or navigation window.
- A borderless window needs an obvious drag and close path. Do not assume one display size.
