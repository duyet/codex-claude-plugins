# AppKit Overview

AppKit provides the objects to build a macOS app's user interface and to manage
interaction between the app, the person, and macOS: windows, panels, buttons, text
fields, event handling, drawing, printing, animation, documents, drag and drop,
menus, accessibility, and localization. It interops with SwiftUI in both directions
— AppKit views and view controllers embed into SwiftUI via representables, and
SwiftUI views can be hosted inside AppKit.

## When to reach for AppKit

Prefer SwiftUI for new macOS UI. Reach for AppKit directly only when SwiftUI lacks a
capability (window behavior, responder-chain control, a specific control, text-system
behavior, menus). See the parent `appkit-interop` skill for the smallest-bridge
approach.

## Topic map

- **App and Environment** — app lifecycle, run loop, environment, appearance.
- **Windows, Panels, and Screens** — `NSWindow`, panels, full-screen, restoration.
- **Views and Controls** — buttons, fields, sliders, segmented controls, toolbars.
- **Text System** — text storage, selection, layout, attachments, view providers.
- **Documents, Data, and Pasteboard** — document architecture, pasteboard, undo.
- **Drawing** — `NSBezierPath`, graphics contexts, images and PDF.
- **Color and Fonts** — color management, font descriptors, typography.
- **Menus, Cursors, and the Dock** — menu bars, menu items, dock tiles.
- **Mouse, Keyboard, and Trackpad** — event handling, gestures, responders.
- **Drag and Drop** — pasteboard-based dragging sessions.
- **Animation** — `NSAnimationContext`, animator proxies, layer-backed views.
- **Accessibility** — accessibility elements, traits, and actions.
- **Cocoa Bindings** — KVO/bindings to connect UI to models.
- **Appearance Customization** — light/dark, accent, vibrancy.
- **Mac Catalyst** — bring iPad apps to the Mac.

## Notable symbols from the AppKit reference

These appear in the current AppKit reference; confirm availability and semantics in
the Apple Developer docs before relying on them.

- `NSRefreshController` — a refresh control for AppKit scroll views.
- `NSTextSelectionManager` (plus `.Delegate`, `.Mode`) — unified text selection.
- `NSMenuItem.ImageVisibility` — control menu-item icon visibility.
- `NSSegmentedControl.Role` — per-segment roles.
- `NSStatusItemExpandedInterfaceDelegate` / `NSStatusItemExpandedInterfaceSession` —
  expanded status items.
- `NSTextViewportRenderingSurface` / `NSTextViewportRenderingSurfaceKey` — text
  viewport rendering hooks.
