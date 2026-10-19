---
name: swiftui-ui-patterns
description: Build and refactor SwiftUI UI with component patterns and examples. Use when shaping navigation, state, layouts, controls, or screen composition.
---

# SwiftUI UI Patterns

## Quick start

Choose a track based on your goal:

### Existing project

- Identify the feature or screen and the primary interaction model (list, detail, editor, settings, tabbed).
- Find a nearby example in the repo with `rg "TabView\("` or similar, then read the closest SwiftUI view.
- Apply local conventions: prefer SwiftUI-native state, keep state local when possible, and use environment injection for shared dependencies.
- Build the view with small, focused subviews and SwiftUI-native data flow.

### New project scaffolding

- Wire TabView, a NavigationStack per tab, and sheets at the app root.
- Add a minimal `AppTab` enum and `RouterPath` for per-tab navigation.
- Expand the route and sheet enums as new screens are added.

## General rules to follow

- Use modern SwiftUI state (`@State`, `@Binding`, `@Observable`, `@Environment`) and avoid unnecessary view models.
- If the deployment target includes iOS 16 or earlier and cannot use the Observation API introduced in iOS 17, fall back to `ObservableObject` with `@StateObject` for root ownership, `@ObservedObject` for injected observation, and `@EnvironmentObject` only for truly shared app-level state.
- Prefer composition; keep views small and focused.
- Use async/await with `.task` and explicit loading/error states.
- Keep shared app services in `@Environment`, but prefer explicit initializer injection for feature-local dependencies and models.
- Prefer the newest SwiftUI API that fits the deployment target and call out the minimum OS whenever a pattern depends on it.
- Maintain existing legacy patterns only when editing legacy files.
- Follow the project's formatter and style guide.
- **Sheets**: Prefer `.sheet(item:)` over `.sheet(isPresented:)` when state represents a selected model. Avoid `if let` inside a sheet body. Sheets should own their actions and call `dismiss()` internally instead of forwarding `onCancel`/`onConfirm` closures.
- **Scroll-driven reveals**: Prefer deriving a normalized progress value from scroll offset and driving the visual state from that single source of truth. Avoid parallel gesture state machines unless scroll alone cannot express the interaction.

## State ownership summary

Use the narrowest state tool that matches the ownership model:

| Scenario                                                          | Preferred pattern                                           |
| ----------------------------------------------------------------- | ----------------------------------------------------------- |
| Local UI state owned by one view                                  | `@State`                                                    |
| Child mutates parent-owned value state                            | `@Binding`                                                  |
| Root-owned reference model on iOS 17+                             | `@State` with an `@Observable` type                         |
| Child reads or mutates an injected `@Observable` model on iOS 17+ | Pass it explicitly as a stored property                     |
| Shared app service or configuration                               | `@Environment(Type.self)`                                   |
| Legacy reference model on iOS 16 and earlier                      | `@StateObject` at the root, `@ObservedObject` when injected |

Choose the ownership location first, then pick the wrapper. Do not introduce a reference model when plain value state is enough.

## Further reading

For macOS windowing, menus, and settings patterns, use the `swiftui-patterns` skill from the build-macos-apps plugin when it is installed. Use web search to consult current Apple Developer documentation when SwiftUI APIs or availability may have changed.

## Anti-patterns

- Giant views that mix layout, business logic, networking, routing, and formatting in one file.
- Multiple boolean flags for mutually exclusive sheets, alerts, or navigation destinations.
- Live service calls directly inside `body`-driven code paths instead of view lifecycle hooks or injected models/services.
- Reaching for `AnyView` to work around type mismatches that should be solved with better composition.
- Defaulting every shared dependency to `@EnvironmentObject` or a global router without a clear ownership reason.

## Workflow for a new SwiftUI view

1. Define the view's state, ownership location, and minimum OS assumptions before writing UI code.
2. Identify which dependencies belong in `@Environment` and which should stay as explicit initializer inputs.
3. Sketch the view hierarchy, routing model, and presentation points; extract repeated parts into subviews. **Build and verify no compiler errors before proceeding.**
4. Implement async loading with `.task` or `.task(id:)`, plus explicit loading and error states when needed.
5. Add previews for the primary and secondary states, then add accessibility labels or identifiers when the UI is interactive.
6. Validate with a build: confirm no compiler errors, check that previews render without crashing, ensure state changes propagate correctly, and sanity-check that list identity and observation scope will not cause avoidable re-renders. For common SwiftUI compilation errors, missing `@State` annotations, ambiguous `ViewBuilder` closures, or mismatched generic types, resolve them before updating callsites. **If the build fails:** read the error message carefully, fix the identified issue, then rebuild before proceeding to the next step. If a preview crashes, isolate the offending subview, confirm its state initialisation is valid, and re-run the preview before continuing.

