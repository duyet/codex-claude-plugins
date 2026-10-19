---
name: swiftui-liquid-glass
description: Implement and review iOS 26+ SwiftUI Liquid Glass UI. Use when adopting Liquid Glass or checking its correctness, performance, and design fit.
---

# SwiftUI Liquid Glass

Docs: <https://developer.apple.com/documentation/swiftui/applying-liquid-glass-to-custom-views>. Check current docs, the API is new.

- Standard bars, sheets, and controls get glass automatically. Use `glassEffect` only when no standard component fits, and never stack custom blurs.
- Group nearby glass in `GlassEffectContainer`. Use `interactive()` only on tappable elements.
- Gate with `#available(iOS 26, *)` and provide a non-glass fallback.
