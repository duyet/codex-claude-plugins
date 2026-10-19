---
name: swiftui-ui-patterns
description: Build and refactor SwiftUI UI with component patterns. Use when shaping navigation, state, layouts, controls, or screen composition.
---

# SwiftUI UI patterns

Docs: <https://developer.apple.com/documentation/swiftui>. Match the repo's existing conventions first.

- Use `@State`, `@Binding`, `@Observable`, `@Environment`. Fall back to `ObservableObject` only below iOS 17. Avoid view models that only mirror view state.
- Shared services in `@Environment`, feature-local dependencies by initializer.
- Prefer `.sheet(item:)` over `.sheet(isPresented:)` for selected models. Sheets own their actions and call `dismiss()`.
- Drive scroll-based reveals from one normalized progress value.
- State the minimum OS for any pattern that needs it.
