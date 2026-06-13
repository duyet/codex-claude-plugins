# Build iOS Apps Plugin

This plugin packages iOS and Swift workflows.

It currently includes these skills:

- `ios-debugger-agent`
- `ios-simulator-browser`
- `ios-ettrace-performance`
- `ios-memgraph-leaks`
- `ios-app-intents`
- `swiftui-liquid-glass`
- `swiftui-performance-audit`
- `swiftui-ui-patterns`
- `swiftui-view-refactor`

## What It Covers

- designing App Intents, app entities, and App Shortcuts for system surfaces
- building and refactoring SwiftUI UI using current platform patterns
- reviewing or adopting iOS 26+ Liquid Glass APIs
- auditing SwiftUI performance and guiding profiling workflows
- capturing symbolicated ETTrace simulator profiles for focused app flows
- capturing and comparing iOS memgraphs to root-cause leaks
- debugging iOS apps on simulators with XcodeBuildMCP-backed flows
- mirroring Simulator in the browser and hot-reloading package-backed SwiftUI previews
- restructuring large SwiftUI views toward smaller, more stable compositions

## Plugin Structure

```
build-ios-apps/
├── .claude-plugin/            # Claude manifest
├── .codex-plugin/             # Codex manifest
├── agents/
│   └── openai.yaml            # OpenAI surface metadata
├── assets/                    # Icons and SVGs
└── skills/                    # Skill payloads
    ├── ios-debugger-agent/
    ├── ios-simulator-browser/
    ├── ios-ettrace-performance/
    ├── ios-memgraph-leaks/
    ├── ios-app-intents/
    ├── swiftui-liquid-glass/
    ├── swiftui-performance-audit/
    ├── swiftui-ui-patterns/
    └── swiftui-view-refactor/
```

## License

MIT
