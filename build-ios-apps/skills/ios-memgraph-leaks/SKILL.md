---
name: ios-memgraph-leaks
description: Capture and inspect iOS leaks and memgraphs. Use when debugging leaked objects, retain cycles, memory growth, or before/after leak evidence.
---

# iOS memgraph leaks

Pair with `ios-debugger-agent` to build and drive the flow. Scripts live in this skill's `scripts/` (resolve the skill folder, not the app repo's cwd). Store captures in a temp folder.

- Capture: `scripts/capture_sim_memgraph.sh --udid <sim> --bundle-id <id> --out-dir <dir>`.
- Summarize: `scripts/summarize_memgraph_leaks.py <file.memgraph> --trace-limit 5 --out <file.md>`.
- Inspect ownership with `leaks --traceTree=<address>`. "Found 0 roots" means an unreachable self-retained leak, so use `leaks --groupByType`.
- Do not claim a fix because the total count dropped. Show the specific type or ownership path disappeared after recapturing the same flow.
- Lazy allocation is a scope reduction, not a fix. Prefer deleting the retaining edge over cleanup code.
- If only framework noise appears, say so and recommend a narrower capture.
