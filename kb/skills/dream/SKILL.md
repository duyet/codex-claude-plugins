---
name: dream
description: Consolidate a markdown knowledge base by merging near-duplicates, flagging contradictions, pruning stale notes, ingesting the inbox, refreshing from sources, and rebuilding the index. Use when a KB is noisy or stale, on a schedule, or to forget notes.
---

# dream

Maintenance pass for a markdown KB. Show a diff of every proposed change and apply nothing until the user approves, unless run with `--auto`. If the KB ships `DREAM.md` or `AGENTS.md`, read it first and follow its note format, tags, and sync steps.

- `dream [<path>]`: path, else `$KB_DIR`, else ask.
- `dream --auto [<path>]`: no prompts. Apply merges and prunes, skip contradictions.
- `dream forget "<query>" [<path>]`: propose deleting matching notes. Pinned notes need per-note confirmation.

A note is `*.md` with YAML frontmatter: `name` (equals filename stem), `description`, `type`, `tags`, `created`, `updated`, optional `sources`, `pinned`, `confidence` (0 to 1). Filenames are `<type>-<slug>.md`. No nested `metadata:` blocks.

The pass:

1. Ingest `raw/inbox/*`: promote durable, general facts to notes, delete the inbox files, keep `raw/` sources.
2. Merge near-duplicates of the same `type`, never pinned ones. Lose words, not facts.
3. Flag contradictions and propose the more recent, higher-confidence note as winner.
4. Split multi-fact notes. Compact each note to about 25 lines.
5. Refresh notes whose `sources:` are over 30 days old (prefer `llms.txt`, bump `updated`, skip offline).
6. Propose pruning wrong, obsolete, out-of-scope, or past-retention notes. Never prune `pinned: true`. Retention days: `feedback` 180, `tech` 365, `unknown` 90, `user`, `project`, `reference` forever (overridable by a `retention:` map in state).
7. Fix `[[slug]]` links, give every note a link, fold tag sprawl into the existing vocabulary.
8. Rebuild `MEMORY.md` grouped by `type`, one line each: `[Title](<file>) - hook`. Descriptions must let an agent judge relevance from the index alone.
9. Remove secrets, hosts, and confidential facts. Set `last_dream` in state to today.

With nothing to change print `Dream complete. Nothing to change.` Never push automatically. Run the KB's sync step only if the user confirms. A second run must change nothing.

Auto mode takes a lock at `${TMPDIR:-/tmp}/dream_auto.lock` (skip if under 10 minutes old, remove on every exit), prints `[dream --auto] kb=<path> merged=<N> pruned=<N> conflicts_skipped=<N>`, and leaves one `source: dream-auto` reminder note when conflicts were skipped.
