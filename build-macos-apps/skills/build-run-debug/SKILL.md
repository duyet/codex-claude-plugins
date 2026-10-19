---
name: build-run-debug
description: Build, run, and debug macOS apps with shell-first Xcode and Swift workflows. Use when launching apps or diagnosing build, startup, or runtime failures.
---

# Build, run, debug

Own the workflow with one project-local `script/build_and_run.sh` (never inside app source dirs). Other tools may depend on its contract.

- Default path is kill the running app, build, launch. Optional flags: `--debug` (lldb), `--logs` (stream process logs), `--telemetry` (unified log filtered to app subsystem), `--verify` (launch, then `pgrep -x <AppName>`).
- Xcode projects use `xcodebuild`. SwiftPM command-line tools launch raw.
- SwiftPM GUI apps must be staged as `dist/<AppName>.app` (binary in `Contents/MacOS`, minimal `Info.plist` with `CFBundlePackageType=APPL`, `CFBundleExecutable`, `CFBundleIdentifier`, `CFBundleName`, `LSMinimumSystemVersion`, `NSPrincipalClass=NSApplication`) and launched with `/usr/bin/open -n`.
  A raw executable gives no Dock icon, no activation, and bundle id warnings. If the window stays behind, check `NSApp.setActivationPolicy(.regular)` and `NSApp.activate(ignoringOtherApps: true)`.
- Run `git init` only if the workspace is not already inside a git repo. Never nest one.
- Classify failures (compiler, linker, signing, build settings, SDK, script, runtime launch) and quote the smallest useful error. No simulator or mobile workflows on macOS. Do not claim UI state you cannot inspect.
