---
name: appkit-interop
description: Bridge macOS SwiftUI into AppKit narrowly. Use when implementing representables, reaching NSWindow or panels, handling menus, or using the responder chain.
---

# AppKit interop

Docs: <https://developer.apple.com/documentation/appkit>.

- Wrap one control or coordinator, not a whole screen.
- One source of truth. Do not duplicate state between SwiftUI and AppKit.
- Keep `Coordinator` focused. Do not store long-lived `NSView` or `NSWindow` instances globally.
- Do not let AppKit references spread through unrelated SwiftUI views.
