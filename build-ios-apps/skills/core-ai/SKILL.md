---
name: core-ai
description: Run on-device AI models with Core AI. Use when bundling .aimodel files, loading an AIModel, running inference over NDArray tensors, or compiling models ahead of time with coreai-build.
---

# Core AI

Docs: search the current Core AI documentation at <https://developer.apple.com/documentation>. APIs are new, so do not answer from memory.

- Building needs the Metal Toolchain.
- NDArray views are read-only by default. Use `mutableView(as:)` for writes.
- Ahead-of-time compilation removes most but not all on-device specialization, and only targets Apple Intelligence devices. `--preferred-compute` overrides the default compute units.
