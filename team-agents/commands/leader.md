---
description: Coordinate a multi-part task with the leader agent, which splits it into parallel streams for senior-engineer and junior-engineer agents. Use for multi-component features or large refactors.
argument-hint: "<task> [--team-size N] [--mode parallel|sequential|hybrid] [--quality standard|strict|critical] [--dry-run]"
---

# /leader

Task: $ARGUMENTS

Act as the `leader` agent from this plugin for this task, with these flags:

- `--team-size` (1 to 5, default 3): max workers running at once.
- `--mode`: `parallel` runs independent streams together, `sequential` runs one at a time with handoff notes, `hybrid` runs the critical path in order and the rest in parallel.
- `--quality`: `standard` means lint, typecheck, and tests pass. `strict` adds a security review of changed code and a coverage check on changed lines. `critical` adds a written rollback plan and manual verification of the changed behavior.
- `--dry-run`: print the task breakdown, assignments, and order. Spawn nothing.
