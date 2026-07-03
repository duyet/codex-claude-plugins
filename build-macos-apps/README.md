# Build macOS Apps Plugin

This plugin packages macOS-first development workflows.

It currently includes these skills:

- `build-run-debug`
- `test-triage`
- `signing-entitlements`
- `swiftpm-macos`
- `packaging-notarization`
- `swiftui-patterns`
- `macos-app-best-practices`
- `liquid-glass`
- `window-management`
- `appkit-interop`
- `view-refactor`
- `telemetry`

## What It Covers

- discovering local Xcode workspaces, projects, and Swift packages
- building and running macOS apps with shell-first desktop workflows
- creating one project-local `script/build_and_run.sh` entrypoint and wiring `.codex/environments/environment.toml` so the Codex app Run button works
- implementing native macOS SwiftUI scenes, menus, settings, toolbars, and multiwindow flows
- adopting modern macOS Liquid Glass and design-system guidance with standard SwiftUI structures, toolbars, search, controls, and custom glass surfaces
- tailoring SwiftUI windows with title/toolbar styling, material-backed container backgrounds, minimize/restoration behavior, default and ideal placement, borderless window style, and launch behavior
- bridging into AppKit for representables, responder-chain behavior, panels, and other desktop-only needs
- refactoring large macOS view files toward stable scene, selection, and command structure
- adding lightweight `Logger` / `os.Logger` instrumentation for windows, sidebars, menu commands, and menu bar actions
- reading and verifying runtime events with Console, `log stream`, and process logs
- triaging failing unit, integration, and UI-hosted macOS tests
- debugging launch failures, crashes, linker problems, and runtime regressions
- inspecting signing identities, entitlements, hardened runtime, and Gatekeeper issues
- preparing packaging and notarization workflows for distribution

## Plugin Structure

```text
build-macos-apps/
├── .claude-plugin/            # Claude manifest
├── .codex-plugin/             # Codex manifest
├── agents/
│   └── openai.yaml            # OpenAI surface metadata
├── assets/                    # Icons and SVGs
├── commands/                  # Slash commands
│   ├── build-and-run-macos-app.md
│   ├── fix-codesign-error.md
│   └── test-macos-app.md
└── skills/                    # Skill payloads
    ├── build-run-debug/
    ├── test-triage/
    ├── signing-entitlements/
    ├── swiftpm-macos/
    ├── packaging-notarization/
    ├── swiftui-patterns/
    ├── macos-app-best-practices/
    ├── liquid-glass/
    ├── window-management/
    ├── appkit-interop/
    ├── view-refactor/
    └── telemetry/
```

## License

MIT
