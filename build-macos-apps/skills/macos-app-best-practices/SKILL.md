---
name: macos-app-best-practices
description: Best practices for building macOS apps with SwiftUI, AppKit, and Mac Catalyst. Use when architecting a Mac app, choosing scene and window types, wiring menus and commands, or deciding between native SwiftUI, AppKit, and Mac Catalyst.
---

# macOS App Best Practices

## Overview

macOS apps are organized around scenes the system manages: windows, document groups,
settings, and menu-bar extras. Pick the right scene types for SwiftUI, gate Mac-only
behavior behind `#if os(macOS)`, and reserve Mac Catalyst for bringing an existing iPad
app to the Mac rather than starting new Mac apps on it. The guidance below is grounded
in Apple's SwiftUI, AppKit, and Mac Catalyst docs.

## App Architecture: Scenes

A `Scene` is a root of a view hierarchy with a system-managed life cycle; an `App`
presents its scenes. The system shows scenes differently per type and platform, and may
display several instances of one `WindowGroup` at once (for example, multiple windows).

- Default to `WindowGroup` for the main window.
- Use `DocumentGroup` for document-based apps (it adds Save/Duplicate to the menu bar
  automatically).
- Use `Settings` (macOS only) for the app-menu Settings window.
- Use `MenuBarExtra` for utility apps or a persistent status item.

```swift
@main
struct Mail: App {
    var body: some Scene {
        WindowGroup {
            MailViewer()
        }
        // A typed window group keyed by a model id.
        WindowGroup(for: Message.ID.self) { $messageID in
            MessageDetail(messageID: messageID)
        }
    }
}
```

## Opening and Identifying Windows

Give a `WindowGroup` an `id` and open instances via the `openWindow` environment action,
matching the group id. This is how a Mac app supports multiple windows from one
declaration.

```swift
WindowGroup(id: "mail-viewer") {
    MailViewer()
}

struct NewViewerButton: View {
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        Button("Open new mail viewer") { openWindow(id: "mail-viewer") }
    }
}
```

## Settings Window (macOS only)

`Settings` presents the App-menu > Settings window. Gate it with `#if os(macOS)`.
`@AppStorage` persists the bound values.

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
        #if os(macOS)
        Settings { GeneralSettingsView() }
        #endif
    }
}

struct GeneralSettingsView: View {
    @AppStorage("showPreview") private var showPreview = true
    @AppStorage("fontSize") private var fontSize = 12.0
    var body: some View {
        Form {
            Toggle("Show Previews", isOn: $showPreview)
            Slider(value: $fontSize, in: 9...96) { Text("Font Size") }
        }
    }
}
```

## Menu Bar Extra

`MenuBarExtra` renders a persistent control in the system menu bar. A utility app can
use it as the sole scene. `.menuBarExtraStyle(.window)` shows a panel with arbitrary
SwiftUI content.

```swift
@main
struct UtilityApp: App {
    var body: some Scene {
        MenuBarExtra("Utility App", systemImage: "hammer") {
            AppMenu()
        }
    }
}

// Toggle a status item on/off.
MenuBarExtra("App Menu Bar Extra", systemImage: "star", isInserted: $show) {
    StatusMenu()
}

// Window-styled panel.
MenuBarExtra("Utility App", systemImage: "hammer") {
    ScrollView { /* LazyVGrid content */ }
}
.menuBarExtraStyle(.window)
```

## Menus and Commands

The menu bar is populated from your scenes plus `.commands { }` modifiers. Scene
defaults differ: `WindowGroup` adds quit/hide, Copy/Paste, and window management; on
macOS the `Settings` scene adds the App-menu > Settings item; `DocumentGroup` adds
Save/Duplicate. The order of system menus is fixed; custom menus insert after the View
menu.

- Add system command groups contextually: `SidebarCommands()` only if your scene has a
  sidebar; text-editing scenes get a Format menu via `TextFormattingCommands`.
- Build custom menus with `CommandMenu("Actions")` using standard `Button`/`Toggle`
  views, and bind `.keyboardShortcut(...)`.

```swift
@main
struct MyApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MyAppDocument()) { file in
            ContentView(document: file.$document)
        }
        .commands { SidebarCommands() }

        WindowGroup {
            ContentView()
        }
        .commands {
            CommandMenu("Actions") {
                Button("Run") { /* ... */ }.keyboardShortcut("R")
                Button("Stop") { /* ... */ }.keyboardShortcut(".")
            }
        }
    }
}
```

## SwiftUI vs AppKit

- SwiftUI is the default for new Mac UI; AppKit remains the layer for advanced or legacy
  controls and when a SwiftUI equivalent is missing.
- SwiftUI symbols and scenes provide the cross-platform contract; gate Mac-specific
  scenes (`Settings`, `MenuBarExtra`) and platform-only modifiers with `#if os(macOS)`.
- For AppKit bridging details, use `appkit-interop`; this skill stays at the
  architecture/decision level.

## Mac Catalyst (iPad app to Mac)

Mac Catalyst produces a Mac version of an iPad app from the same project and source. In
Xcode: iOS target > General > Supported Destinations > add **Mac > Mac Catalyst**. Xcode
adds the Mac entitlement to the Mac build only and adds a "My Mac" destination.

- Mac Catalyst apps can use only APIs available in Mac Catalyst; AppKit APIs are not
  accessible from Catalyst.
- Exclude incompatible frameworks by setting the platform filter to iOS only in
  Frameworks, Libraries, and Embedded Content.
- Gate code with `#if !targetEnvironment(macCatalyst)` (unavailable API) and
  `#if targetEnvironment(macCatalyst)` (macOS-only).

Choose the UI idiom in Xcode after enabling Mac Catalyst:

- **Scale Interface to Match iPad** — iPad idiom. Fastest; UI scaled to the Mac with
  iPad-like metrics. The default.
- **Optimize Interface for Mac** — Mac idiom. Controls look and behave like AppKit;
  points equal AppKit points. May require re-laying out hard-coded sizes and constraints.
  Detect via `traitCollection.userInterfaceIdiom == .mac`.

```swift
// Tailor behavior for the Mac idiom.
if traitCollection.userInterfaceIdiom == .mac {
    showFavoritesAtTop.preferredStyle = .checkbox
    showFavoritesAtTop.title = "Always show favorite recipes at the top"
}

// Keep a control's iPad appearance in the Mac idiom.
slider.preferredBehavioralStyle = .pad
```

macOS features you get for free with Catalyst: default menu bar, pointer/mouse/keyboard
input, window resizing and full screen, Mac-style scroll bars, copy/paste, drag and
drop, Touch Bar. Extend with custom menu bar items (`UIMenuBuilder`), a Settings window
(auto-provided with a Settings bundle), pointer hover (`UIHoverGestureRecognizer`), and a
Liquid Glass sidebar background
(`splitViewController.primaryBackgroundStyle = .sidebar`).

```swift
// Pointer hover (Catalyst + macOS).
let hover = UIHoverGestureRecognizer(target: self, action: #selector(hovering(_:)))
button.addGestureRecognizer(hover)

@objc func hovering(_ r: UIHoverGestureRecognizer) {
    switch r.state {
    case .began, .changed: button.titleLabel?.textColor = .red
    case .ended:           button.titleLabel?.textColor = .link
    default: break
    }
}

// Use .alert (not .actionSheet) under Mac Catalyst.
#if targetEnvironment(macCatalyst)
let style = UIAlertController.Style.alert
#else
let style = UIAlertController.Style.actionSheet
#endif
```

## Checklist

- [ ] Main UI in a `WindowGroup`; document apps in `DocumentGroup`.
- [ ] App-menu settings via `Settings { }` gated with `#if os(macOS)`.
- [ ] Utility/status UI via `MenuBarExtra` (`.menuBarExtraStyle(.window)` for panels).
- [ ] Multi-window: id the group and open with `@Environment(\.openWindow)`.
- [ ] Menus via `.commands { }`; add `SidebarCommands` / `TextFormattingCommands` only
      when relevant; custom items in `CommandMenu` with `keyboardShortcut`.
- [ ] Mac-only scenes and modifiers wrapped in `#if os(macOS)`.
- [ ] Mac Catalyst: no AppKit calls; gate with `#if targetEnvironment(macCatalyst)`;
      pick Scale-to-iPad vs Optimize-for-Mac deliberately; detect via
      `userInterfaceIdiom == .mac`.
- [ ] Build verified for "My Mac" (native) and "My Mac (Catalyst)" destinations.

## When To Use Other Skills

- `swiftui-patterns` — concrete scene/window/toolbar/settings/split-view implementations.
- `window-management` — window chrome, placement, restoration, borderless windows.
- `appkit-interop` — reaching AppKit (NSWindow, panels, responder chain) from SwiftUI.
- `signing-entitlements` / `packaging-notarization` — ship the app once it builds.

## Resources

- <https://developer.apple.com/documentation/technologyoverviews/app-design-and-ui>
- <https://developer.apple.com/documentation/swiftui/app-structure>
- <https://developer.apple.com/documentation/swiftui/scene>
- <https://developer.apple.com/documentation/swiftui/windowgroup>
- <https://developer.apple.com/documentation/swiftui/settings>
- <https://developer.apple.com/documentation/swiftui/menubarextra>
- <https://developer.apple.com/documentation/swiftui/building-and-customizing-the-menu-bar-with-swiftui>
- <https://developer.apple.com/documentation/uikit/mac-catalyst>
- <https://developer.apple.com/documentation/uikit/creating-a-mac-version-of-your-ipad-app>
- <https://developer.apple.com/documentation/uikit/choosing-a-user-interface-idiom-for-your-mac-app>
- <https://developer.apple.com/documentation/uikit/optimizing-your-ipad-app-for-mac>
