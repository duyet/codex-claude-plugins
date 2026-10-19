---
name: dream
description: Consolidate a markdown knowledge base by merging near-duplicates, flagging contradictions, pruning stale notes, ingesting the inbox, refreshing from sources, and rebuilding the index. Use when a KB is noisy or stale, on a schedule, or to forget notes.
---

# dream

Maintenance pass for a markdown KB. Propose every change as a diff and apply nothing until the user approves, unless run with `--auto`.

If the KB ships its own `DREAM.md` or `AGENTS.md`, read it first and follow its note format, tag vocabulary, and sync steps.

## Invocation

- `dream [<path>]` consolidates the KB at `<path>`, else `$KB_DIR`, else ask.
- `dream --auto [<path>]` runs without prompts. It applies merges and prunes, skips contradictions, and takes a lock.
- `dream forget "<query>" [<path>]` lists notes matching the query and proposes deleting them through the same diff flow. Pinned notes are deleted only with per-note confirmation.

A note is a `*.md` file with YAML frontmatter: `name` (equals the filename stem), `description`, `type`, `tags`, `created`, `updated`, and optional `sources`, `pinned`, `confidence` (0 to 1). Treat a missing `type` as `unknown`, missing dates as file mtime, missing `pinned` as false.

## The pass

Hold everything in memory until the apply step.

1. Resolve the KB. Expect `memory/` notes, a `MEMORY.md` index, `raw/inbox/` captures, `raw/` source docs, and a state file. Adapt if the layout differs.
2. Ingest the inbox. Promote durable, general facts from `raw/inbox/*` into notes, then delete the inbox files. Keep `raw/` source docs and record them as processed in state.
3. Merge near-duplicates. Two notes qualify when they share a `type`, overlap on more than about 60% of significant nouns, and neither is pinned. Write one note that keeps the clearest, most recent wording. Lose words, not facts.
4. Flag contradictions. When two notes assert opposing facts, propose the more recent, higher-confidence one as the winner and show both.
5. Split notes that hold several facts into one note per fact, named `<type>-<slug>.md`.
6. Validate frontmatter. Fix the `<type>-` filename prefix if the type changed. No nested `metadata:` blocks.
7. Refresh notes whose `sources:` URL is older than about 30 days or whose facts look outdated. Prefer `llms.txt`, bump `updated:`, and skip silently when offline.
8. Compact each note to its essential facts, about 25 lines at most.
9. Propose prunes for notes that are wrong, obsolete, out of scope, past their type's retention, or below 0.3 confidence with nothing project-specific. Never prune `pinned: true`. Refresh before deleting for age alone.
10. Fix `[[slug]]` links, remove links to deleted notes, give every note at least one link, and fold tag sprawl into the existing vocabulary.
11. Rebuild `MEMORY.md` from the surviving notes, grouped by `type`, one line each: `[Title](<file>) - hook`.
12. Remove any secrets, hosts, or confidential facts that slipped in. Set `last_dream` in state to today.

Retention in days by type, overridable by a `retention:` map in state: `feedback` 180, `tech` 365, `unknown` 90, `user`, `project`, and `reference` kept forever.

## Diff report

Print this before any change and omit empty sections.

```text
## dream report

Merges (<N>):
  <file1> + <file2> -> "<merged summary>"

Conflicts (<N>):
  <fileA> vs <fileB> on "<topic>" [A/B/skip]

Prune (<N>):
  <file> (<type>, <age>d old)

Inbox ingested <N>, refreshed <N>, split <N>, relinked <N>.

Apply? [Y/n]
```

With no proposals, print `Dream complete. Nothing to change.` and stop. On `n`, print `Cancelled. No changes made.`

## Apply order

1. Merges. Write the merged note with `updated` set to today, the higher `confidence`, and `source: dream`. Delete both originals and rewrite inbound links.
2. Contradictions. Delete the loser of each resolved pair and leave skipped pairs alone.
3. Prunes. Delete the note and its index line.
4. Splits, refreshes, compaction, relinking, and the index rebuild.
5. Stamp state. Run the KB's sync step only if one exists and the user confirms. Never push automatically.

## Auto mode

- Check `${TMPDIR:-/tmp}/dream_auto.lock`. If it is under 10 minutes old, print `[dream --auto] another run in progress, skipping.` and stop. Otherwise write the lock and delete it on every exit path.
- Skip the diff and prompts. Skip contradictions.
- Print `[dream --auto] kb=<path> merged=<N> pruned=<N> conflicts_skipped=<N>`.
- If conflicts were skipped, leave one reminder note marked `source: dream-auto` so a human runs interactive `dream`. Do not add a second if one exists.

## Rules

- The pass must be idempotent. A second run changes nothing.
- Every `description` must let an agent judge relevance from the index alone.
- Never assume a fixed KB location.
