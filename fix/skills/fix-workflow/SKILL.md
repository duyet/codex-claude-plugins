---
name: fix-workflow
description: Use when the user asks to fix issues, tests, CI failures, or create/update/push a fix branch.
---

# Fix Workflow

Use this skill to diagnose and repair repository failures with focused changes.

## Workflow

1. Identify the project type and the most relevant checks from repository files.
2. Reproduce the failure when possible before editing.
3. Make the smallest change that addresses the root cause.
4. Run targeted verification first, then broader checks when the change is shared or risky.
5. For PR/update flows, commit with semantic format and preserve unrelated local work.

## Supported Checks

- Python: pytest, ruff, mypy
- Node/TypeScript: package scripts, tsc, eslint, jest, vitest
- Rust: cargo test, clippy
- Go: go test and lint tools when configured
