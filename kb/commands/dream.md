# /dream

Consolidate a markdown knowledge base: merge near-duplicates, flag contradictions, prune
stale notes, ingest inbox captures, refresh notes from sources, split, and rebuild the
index. Delegate to the `dream` skill for the full pass. Nothing changes until the user
approves the diff (unless `--auto`).

## Arguments

- `path`: KB directory (optional; defaults to `$KB_DIR`; ask if unset)
- `--auto`: non-interactive run (apply merges/prunes, skip contradictions, lock-guarded)
- `forget "<query>"`: delete notes matching a query (diff-for-approval)

Pass the rest of the line as `$ARGUMENTS`. Examples: `/dream ./docs/kb`,
`/dream $KB_DIR --auto`, `/dream forget "old server"`.

## Workflow

1. Parse `$ARGUMENTS`: detect `--auto`, a `forget "<query>"` subcommand, and a path.
   Resolve the KB path from the argument or `$KB_DIR`; ask if neither is set.
2. Invoke the `dream` skill and follow its pass exactly. The skill owns the consolidation
   logic, the diff format, the apply order, and the safety rules.
3. In interactive mode, print the diff, collect A/B/skip for each conflict, confirm, then
   apply in the skill's prescribed order.
4. In `--auto`, honor the lock file, apply merges and prunes silently, skip conflicts, and
   leave a reminder if conflicts still need review.
5. For `forget`, list matches and apply only approved deletions (and their index lines).

## Guardrails

- Never assume a fixed KB location; use the argument or `$KB_DIR`.
- Never auto-push or auto-sync; the user confirms before any write outside the KB.
- Never delete or merge `pinned` notes without explicit per-note confirmation.
- Keep this command thin — all consolidation logic lives in the `dream` skill.
