---
name: ios-simulator-browser
description: Mirror an iOS Simulator into a browser and hot-reload SwiftUI previews from importable Swift packages. Use when previewing SwiftUI in the simulator or live-reloading package-backed previews.
---

# iOS simulator browser

Mirror with `npx --yes serve-sim@latest <udid>` (see `--help`) and open the URL it prints. Run it in a long-lived terminal with a trap that runs `serve-sim --kill <udid>`. Never run an unscoped `--kill`. Verify a real frame renders before reporting success.

Previews from a Swift package: `node <skill-root>/scripts/swiftui-preview-browser.mjs /abs/Package.swift --package-target <target> --device <udid>` (see `--help`, including `--preview-filter`). It builds a disposable host outside the source tree and hot-swaps on edits. Never edit the user's `.xcodeproj`, `.xcworkspace`, `Package.swift`, or schemes for preview support.

Proof: a browser screenshot of the simulator frame. For hot reload, also the launcher's `hot reloaded package preview` output and the changed frame.
