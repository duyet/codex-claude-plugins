---
name: task-decomposition
description: Rules for splitting a large task into independent units that separate workers can do in parallel. Use when planning a multi-part feature or refactor before assigning work.
---

# Task decomposition

A good task has all four of these.

- **One deliverable.** One sentence describes what exists when it is done.
- **Stated inputs.** The files, specs, interfaces, or decisions the worker starts from. A worker should not need the rest of the conversation.
- **An acceptance check.** A command or observable result that proves it is done (a test, a typecheck, an endpoint response).
- **Disjoint files.** No two parallel tasks edit the same file. If they must, make one task own the file and the other depend on it.

## Sizing

- A task should fit one worker's context and finish in one pass. If the description needs more than a short paragraph, split it.
- If a task cannot be verified on its own, it is too small or its boundary is wrong. Merge it with its neighbor.
- Fix shared contracts (types, schemas, API shapes) first as their own task. Then fan out the work that depends on them.
- Sequence by dependency. Anything that touches shared config, lockfiles, or generated files runs alone.
- Prefer fewer, larger independent tasks over many tiny ones. Each task carries setup cost.

## Where the rest lives

Fan-out, the worker preamble, and the verify loop are covered by the `orchestration` skill in the orchestration plugin. Use it once the task list is written.
