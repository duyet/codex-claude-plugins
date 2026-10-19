---
name: view-refactor
description: Refactor macOS SwiftUI views and scenes into stable structure. Use when splitting large views, tightening scene state, or narrowing AppKit escapes.
---

# View refactor (macOS)

- Split a giant root view by desktop surface. Non-trivial apps do not live in one Swift file.
- Keep a stable root. No top-level branch swapping when selection changes.
- Move button logic out of `body`. Keep command routing, menu state, and layout separate.
- `@AppStorage` for durable preferences only. Contain AppKit references at the edges (see `appkit-interop`).
