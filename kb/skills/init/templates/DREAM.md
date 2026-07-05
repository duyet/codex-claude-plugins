# DREAM.md — memory consolidation

"Dreaming" is the maintenance pass that keeps the KB compact and retrievable —
the agent equivalent of sleep consolidating the day's memories. Run it manually,
on a `/loop`, or whenever the KB feels noisy (duplicates, sprawl, stale facts).

## When to dream

- The index `MEMORY.md` has grown large or has near-duplicate lines.
- Several notes restate the same fact, or one note has grown into many facts.
- A note contradicts newer knowledge, or its `updated:`/`timestamp` is old and
  may be stale.
- A note is orphaned (no `[[links]]`), or links/tags have sprawled.
- Links `[[slug]]` point at notes that don't exist (or should).
- New unprocessed files sit in `raw/`.
- On a schedule, e.g. `/loop 1d "run <this kb>/DREAM.md consolidation"`.

## The pass

1. **Load.** Read `MEMORY.md`, every `memory/**/*.md` (recursive — **excluding**
   reserved `index.md`, `log.md`, and `_TEMPLATE.md`), `raw/inbox/*.md`, the
   `raw/` source docs, and `.agent/state.json`.
2. **Ingest & rewrite.** Read `raw/inbox/*` (daily captures) and any `raw/` source
   doc not in `state.json.processed`. Promote durable, general facts into
   `memory/` — **create new notes or rewrite/merge existing ones** to absorb them
   (per `AGENTS.md` §2 + the standard). Then clean up:
   - **inbox files:** once distilled, **delete** them (they're ephemeral).
   - **source docs:** **keep** them (immutable ground truth); record in `processed`.
3. **Dedupe & merge.** Fold duplicate/overlapping notes into one. Keep the
   clearest, most recent phrasing. Lossless of meaning, not of words.
4. **Split.** If a note holds multiple facts, split into atomic notes.
5. **Validate frontmatter.** Every note has top-level `name` (== filename stem),
   `description`, `type`, `tags`, `created`, `updated`, `timestamp` (ISO 8601).
   Fix the `<type>-` filename prefix if `type` changed. No nested `metadata:`
   blocks.
6. **Refresh from sources.** For notes with a `sources:` URL whose `timestamp`/
   `updated:` is stale (>~30 days) or whose facts look outdated, fetch the source
   (prefer `llms.txt`), update the note, and bump `updated:` and `timestamp`.
7. **Compact.** Trim notes to the essential facts. Drop filler. Aim ≤~25 lines.
8. **Relink & retag.** Fix `[[slug]]` references; ensure no orphans (every note
   links ≥1 other); merge tag sprawl into the controlled vocabulary; drop links
   to deleted notes.
9. **Prune.** Delete notes that are wrong, obsolete, or now-private — and their
   index lines.
10. **Rebuild index.** Regenerate `MEMORY.md` from surviving notes — grouped by
    `type`, one line each: `[Title](file) — hook`. Then run **`kb gen`** to
    regenerate every `memory/**/index.md` (OKF listings) + `viz.html` (graph
    viewer) so they stay in sync with the nested layout. Append a new dated entry
    to `memory/log.md` summarizing the pass (what merged/split/pruned).
11. **Verify scope.** If this repo is public, confirm no secrets/hosts/confidential
    facts slipped in (`AGENTS.md` §3). Remove any that did.
12. **Stamp & sync.** Set `state.json.last_dream` to today, then `scripts/sync.sh`
    (only if this repo has a git remote).

## Principles

- **Lossless of meaning.** Compaction removes words and redundancy, never facts.
- **Atomic.** One fact per file after the pass.
- **Retrieval-first.** Every `description` must let an agent judge relevance from
  the index alone; every note is reachable via tags and `[[links]]`.
- **Conservative deletes.** Only prune what is wrong, redundant, or out-of-scope —
  never delete a fact just because it's old (refresh it instead, step 6).
- **Idempotent.** Running the pass twice in a row should change nothing the
  second time.
