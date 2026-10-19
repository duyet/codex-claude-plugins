---
name: swiftui-view-refactor
description: Refactor SwiftUI view files into stable, testable structure. Use when splitting large views, tightening data flow, or cleaning Observation ownership.
---

# SwiftUI view refactor

- Default to vanilla SwiftUI: local state in the view, shared dependencies in the environment, business logic in services or models. Add a view model only if one exists or is requested.
- Extract dedicated `View` types for non-trivial sections. Keep computed `some View` helpers rare and small.
- Keep a stable view tree. Put conditions inside sections and modifiers, not as `if/else` root swaps.
- Keep business logic out of `body`, `.task`, `.onAppear`, `.onChange`, and `.refreshable`. Call small private methods.
- Pass observables explicitly. Avoid `bootstrapIfNeeded`-style delayed setup.
