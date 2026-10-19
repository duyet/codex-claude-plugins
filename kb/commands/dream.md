---
description: Consolidate a markdown knowledge base. Supports a forget subcommand and --auto.
---

# /dream

Run the `dream` skill (`skills/dream/SKILL.md`) on `$ARGUMENTS`.

- `path`: KB directory, defaulting to `$KB_DIR`. Ask if neither is set.
- `--auto`: non-interactive run.
- `forget "<query>"`: propose deleting matching notes.

Examples: `/dream ./docs/kb`, `/dream $KB_DIR --auto`, `/dream forget "old server"`.
