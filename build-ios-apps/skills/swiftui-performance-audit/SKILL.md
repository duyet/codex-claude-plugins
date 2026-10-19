---
name: swiftui-performance-audit
description: Audit SwiftUI runtime performance from code first. Use when diagnosing slow rendering, janky scrolling, expensive updates, or profiling needs.
---

# SwiftUI performance audit

Docs: <https://developer.apple.com/documentation/xcode/understanding-and-improving-swiftui-performance>.

- Review code first. Ask for an Instruments SwiftUI trace only when the code review is inconclusive.
- Look for heavy work in `body`, broad Observation fan-out, unstable identity in lists, `GeometryReader` and preference chains, and image decoding on the main thread.
- Move heavy work into derived state or the model layer. Use `@State` for view-owned state, not as a cache. Use `equatable()` only when equality is cheaper than the subtree.
- Report likely causes, evidence, fix, and how to validate.
