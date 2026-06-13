---
name: swiftui-liquid-glass
description: Implement and review iOS 26+ SwiftUI Liquid Glass UI. Use when adopting Liquid Glass or checking its correctness, performance, and design fit.
---

# SwiftUI Liquid Glass

## Overview

Use this skill to build or review SwiftUI features that fully align with the iOS 26+ Liquid Glass API. Prioritize native APIs (`glassEffect`, `GlassEffectContainer`, glass button styles) and Apple design guidance. Keep usage consistent, interactive where needed, and performance aware.

## Adoption Guidance

Liquid Glass is a dynamic material that forms a distinct functional layer for
controls and navigation. Adopting it well is mostly about getting out of the way:

- **Prefer standard components.** Bars, sheets, popovers, and controls from SwiftUI
  (and UIKit) adopt Liquid Glass automatically when you build with the latest SDK.
  Reach for the explicit `glassEffect` API only when a standard component does not
  already give you the treatment you need.
- **Remove custom backgrounds on controls and navigation.** Custom backgrounds in
  split views, tab bars, and toolbars can overlay or interfere with Liquid Glass and
  the scroll-edge effect. Let the system determine background appearance; remove
  custom effects unless they are essential.
- **Test accessibility and display settings.** Reduce Transparency, Reduce Motion,
  and the user's preferred Liquid Glass look can remove or modify effects. Standard
  components adapt automatically; verify your custom elements, colors, and
  animations under these configurations.
- **Use glass on custom controls sparingly.** Overusing it distracts from content.
  Limit glass to the most important functional elements.
- **App icons are now layered and dynamic.** They respond to lighting and visual
  effects, and use a standardized, concentric icon grid. Provide default (light),
  dark, clear, and tinted appearances.
- **New navigation affordances.** `TabView` gains `.tabBarMinimizeBehavior(.onScrollDown)`
  and a search role via `Tab(role: .search)` (UIKit: `UISearchTab`).

## Workflow Decision Tree

Choose the path that matches the request:

### 1) Review an existing feature

- Inspect where Liquid Glass should be used and where it should not.
- Verify correct modifier order, shape usage, and container placement.
- Check for iOS 26+ availability handling and sensible fallbacks.

### 2) Improve a feature using Liquid Glass

- Identify target components for glass treatment (surfaces, chips, buttons, cards).
- Refactor to use `GlassEffectContainer` where multiple glass elements appear.
- Introduce interactive glass only for tappable or focusable elements.

### 3) Implement a new feature using Liquid Glass

- Design the glass surfaces and interactions first (shape, prominence, grouping).
- Add glass modifiers after layout/appearance modifiers.
- Add morphing transitions only when the view hierarchy changes with animation.

## Core Guidelines

- Prefer native Liquid Glass APIs over custom blurs.
- Use `GlassEffectContainer` when multiple glass elements coexist.
- Apply `.glassEffect(...)` after layout and visual modifiers.
- Use `.interactive()` for elements that respond to touch/pointer.
- Keep shapes consistent across related elements for a cohesive look.
- Gate with `#available(iOS 26, *)` and provide a non-glass fallback.

## Review Checklist

- **Availability**: `#available(iOS 26, *)` present with fallback UI.
- **Composition**: Multiple glass views wrapped in `GlassEffectContainer`.
- **Modifier order**: `glassEffect` applied after layout/appearance modifiers.
- **Interactivity**: `interactive()` only where user interaction exists.
- **Transitions**: `glassEffectID` used with `@Namespace` for morphing.
- **Consistency**: Shapes, tinting, and spacing align across the feature.

## Implementation Checklist

- Define target elements and desired glass prominence.
- Wrap grouped glass elements in `GlassEffectContainer` and tune spacing.
- Use `.glassEffect(.regular.tint(...).interactive(), in: .rect(cornerRadius: ...))` as needed.
- Use `.buttonStyle(.glass)` / `.buttonStyle(.glassProminent)` for actions.
- Add morphing transitions with `glassEffectID` when hierarchy changes.
- Provide fallback materials and visuals for earlier iOS versions.

## Quick Snippets

Use these patterns directly and tailor shapes/tints/spacing.

```swift
if #available(iOS 26, *) {
    Text("Hello")
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
} else {
    Text("Hello")
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
}
```

```swift
GlassEffectContainer(spacing: 24) {
    HStack(spacing: 24) {
        Image(systemName: "scribble.variable")
            .frame(width: 72, height: 72)
            .font(.system(size: 32))
            .glassEffect()
        Image(systemName: "eraser.fill")
            .frame(width: 72, height: 72)
            .font(.system(size: 32))
            .glassEffect()
    }
}
```

```swift
Button("Confirm") { }
    .buttonStyle(.glassProminent)
```

## Resources

- Reference guide: `references/liquid-glass.md`
- Prefer Apple docs for up-to-date API details, and use web search to consult current Apple Developer documentation in addition to the references above.
