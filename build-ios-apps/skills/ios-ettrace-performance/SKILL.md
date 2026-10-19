---
name: ios-ettrace-performance
description: Capture and interpret iOS Simulator ETTrace profiles. Use when profiling launch or runtime latency, comparing traces, or finding CPU-heavy stacks.
---

# iOS ETTrace performance

Tool: <https://github.com/EmergeTools/ETTrace> (`brew install emergetools/homebrew-tap/ettrace`, then `ettrace --help`). Pair with `ios-debugger-agent` for build, launch, and UI driving.

- One trace per user-visible flow. Link `ETTrace.xcframework` into the exact app target temporarily and remove it afterward.
- Do not draw conclusions from an unsymbolicated trace. Provide UUID-matched dSYMs for the app and embedded first-party frameworks via `--dsyms`.
- Run `ettrace` in a TTY. Only one instrumented simulator app at a time (fixed localhost port).
- Analyze only the processed `output_<thread>.json` files, and copy them right away because the next run overwrites them. Ignore `output.json`.
- Report flow, build, simulator runtime, top stacks with weights, symbolication completeness, and caveats. Compare before and after only for the same flow and setup.
