---
allowed-tools: Bash, Read
description: Inspect and validate the agent-loop state file or a backup. Use to debug a stuck or broken loop.
---

# Agent loop inspect

Flags: `--json`, `--threads`, `--errors`, `--limit <n>`, `--validate`, `--backup <file>`.

Read the state file, or the named file under `.agent-loop/backups/`. Validate it against the rules in the State file section of the `agent-loop-orchestrator` skill. Print each problem found (parse error, missing field, orphaned thread), `last_error`, failed threads with reasons, and the next step: `/agent-loop:resume` if valid, `/agent-loop:restore` if not.
