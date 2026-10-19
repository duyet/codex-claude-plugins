---
name: quality-gates
description: Concrete checks to run before calling work done, with rules for reporting results honestly. Use before handing off, opening a PR, or merging code written by you or a subagent.
---

# Quality gates

Use the repo's own commands (package.json scripts, Makefile, CI config). Do not invent them. Order: lint, typecheck (whole project), tests (changed area, then full suite once), build once at the end, security check if dependencies changed. Never run builds in parallel workers.

Extra gates by change: public API or schema (check callers, note breaking changes), migrations (apply on a scratch DB), hot paths (measure before and after), UI (run the app, exercise empty and error states), auth or deploy config (second reviewer and rollback plan).

Reporting rules:

- Report the exact command and its result. Never say "tests pass" from memory.
- Skipped tests are skipped, not passed. A gate that could not run is "not verified", not green.
- A flaky failure is a failure. Report both runs.
- Separate pre-existing failures from yours by running the base branch.
- Never weaken a gate to get green (deleting tests, loosening assertions, adding skips, lowering thresholds) without user approval.
- Report "blocked" with the failures listed, never "done" with failures.
- After a fix, rerun the failed gate and every earlier one. After three failed fixes, stop and report.
