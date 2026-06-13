---
name: dream
description: Consolidate a markdown knowledge base — merge near-duplicates, flag contradictions, prune stale notes, ingest inbox, refresh from sources, split, and rebuild the index. Use when a KB is noisy or stale, on a schedule, or to forget notes. Diff-for-approval; supports --auto.
---

# dream — KB memory consolidation

## Overview

Dream is the maintenance pass that keeps a markdown knowledge base compact and
retrievable — the agent equivalent of sleep consolidating the day's memories. Run it when
the KB feels noisy (duplicates, contradictions, sprawl, stale facts), on a schedule, or
to forget specific notes. Everything is proposed as a diff first; nothing changes until
you approve (or you run `--auto`).

Dream is KB-agnostic and generic. It never assumes a fixed location.

## Invocation

- `dream [<path>]` — consolidate the KB at `<path>`. If omitted, use `$KB_DIR`; if that
  is unset, ask for the path. Examples: `dream ./docs/kb`, `dream $KB_DIR`.
- `dream --auto [<path>]` — non-interactive: apply merges and prunes silently, skip
  contradictions (they need human judgment), guarded by a lock file.
- `dream forget "<query>" [<path>]` — find notes matching a query and propose deletion
  (same diff-for-approval flow as consolidation).

A note is any `*.md` file with YAML frontmatter. Map missing fields gracefully:

```yaml
---
name: type-short-slug # equals the filename stem
description: one line, keyword-front-loaded
type: tech # user | feedback | project | reference | tech | ...
tags: [topic, topic]
sources: ["https://example.com/llms.txt"]
created: 2026-06-01
updated: 2026-06-13
pinned: false # optional — pinned notes are never pruned or merged
confidence: 0.8 # optional — 0..1; low + generic => prune candidate
---
```

- No `type` => `unknown`. No `created`/`updated` => use file mtime. No `confidence` =>
  neutral. No `pinned` => false.

## The pass (run strictly in order)

Work in memory until the apply step; modify nothing early.

1. **Resolve the KB.** Confirm `<path>` holds `memory/` (notes) and ideally `MEMORY.md`
   (index), `raw/inbox/` (captures), `raw/` (source docs), and a state file. If the
   layout differs, operate on whatever `*.md` files exist and adapt.
2. **Load.** Read the index, every note, `raw/inbox/*`, source docs, and state.
3. **Ingest inbox.** Promote durable, general facts from `raw/inbox/*` into `memory/`
   (create or merge notes). Delete inbox files once distilled (they are ephemeral). Keep
   `raw/` source docs (immutable ground truth); record processed ones in state.
4. **Dedupe and merge (near-duplicates).** Group notes by `type`. Two notes are
   near-duplicates when: same `type`; significant-noun overlap above ~60% (a proxy for
   cosine similarity > 0.9); neither is `pinned`. Draft a merged note that is more
   complete and specific than either, keeping the clearest, most recent phrasing.
   Lossless of meaning, not of words.
5. **Contradictions.** Two notes assert opposing facts on the same topic (for example
   "deploy to ECS" vs "deploy to Vercel"). Proposed winner: more recent with higher
   confidence. Present both for A/B/skip (interactive); skip in `--auto`.
6. **Split.** If a note holds multiple distinct facts, split into atomic notes (one fact
   per file), renamed to `<type>-<slug>.md`.
7. **Validate frontmatter.** Every note has `name` (equals filename stem), `description`,
   `type`, `tags`, `created`, `updated`. Fix the `<type>-` filename prefix if the type
   changed. No nested `metadata:` blocks.
8. **Refresh from sources.** For notes with a `sources:` URL whose `updated:` is stale
   (older than ~30 days) or whose facts look outdated, fetch the source (prefer
   `llms.txt`), update the note, bump `updated:`. Skip silently when offline.
9. **Compact.** Trim each note to essential facts; drop filler. Aim for ~25 lines or
   fewer.
10. **Prune candidates.** A note is a prune candidate when any holds:
    - its `type` has a retention policy and it is older than the policy's days (compare
      `created`/`updated` to today);
    - `confidence` is below 0.3 AND it has no project-unique info (no paths,
      identifiers, or domain nouns);
    - it is wrong, obsolete, or out of scope.
      Never prune `pinned: true`. Prefer refreshing (step 8) over deleting merely because
      a note is old.
11. **Relink and retag.** Fix `[[slug]]` references; ensure no orphans (each note links
    at least one other); merge tag sprawl into the controlled vocabulary; drop links to
    deleted notes.
12. **Rebuild index.** Regenerate `MEMORY.md` from surviving notes, grouped by `type`,
    one line each: `[Title](file) — hook`.
13. **Verify scope.** Confirm no secrets, hosts, or confidential facts slipped in;
    remove any that did.
14. **Stamp.** Set `state.last_dream` to today.

## Retention policies (load in step 1)

Default per-type retention, in days (`null` means keep forever). Override via a
`retention:` map in the KB's state or config file.

- `feedback`: 180
- `project`: null
- `reference`: null
- `tech`: 365
- `user`: null
- `unknown`: 90

## Diff report (interactive)

Print exactly this before any change. Omit any section that has zero items.

```text
## dream — consolidation report

Merges (<N>):
  [note:<file1>] + [note:<file2>] -> "<merged summary, ~80 chars>"

Conflicts (<N>):
  [note:<fileA>] vs [note:<fileB>] — "<topic>" [A/B/skip]

Prune (<N>):
  [note:<file>] — <type>, <age>d old

Inbox ingested (<N>), refreshed (<N>), split (<N>), relinked (<N>).

Proposed: <N> merges, <N> prunes, <N> conflicts. Apply? [Y/n]
```

If there are zero proposals, print `Dream complete. No duplicate, contradictory, or stale
notes found.` and stop.

## Resolve and apply (interactive)

- For each conflict, collect `A`, `B`, or `skip` (empty input = skip).
- Final confirm: `Apply? [Y/n]`. `n` or `no` prints `Cancelled. No changes made.` and
  stops.
- On confirm, apply in this order:
  1. **Merges** — write the merged note (`<type>-<slug>.md`; `type` and `updated` = today;
     `confidence` = the higher of the two originals; a `source: dream` marker), delete
     both originals, and rewrite inbound links to point at the merged slug.
  2. **Contradictions** — delete the loser of each resolved A/B pair; skipped pairs stay
     untouched.
  3. **Prunes** — delete the note and its index line.
  4. **Split, refresh, compact, relink, index rebuild** — apply the file writes.
  5. **Stamp** state, and run the KB's sync step only if one exists and only after the
     user confirms — never auto-push.

## Auto mode (`--auto`)

- **Concurrency guard.** Before working, check `${TMPDIR:-/tmp}/dream_auto.lock`. If it
  exists and is less than 10 minutes old, print
  `[dream --auto] another run in progress — skipping.` and stop. Otherwise write the lock
  (current timestamp); delete it on every exit path.
- Run load and analyze (steps 1–3). Apply merges and prunes silently (no diff, no
  prompt). Skip contradictions (human judgment). Apply split, refresh, compact, relink,
  index rebuild, and stamp.
- Print: `[dream --auto] kb=<path>  merged=<N>  pruned=<N>  conflicts_skipped=<N>`.
- If contradictions were skipped, leave a single reminder note so the human runs
  interactive `dream` to resolve them. First search for an existing `dream-auto` reminder
  (by `source: dream-auto`); skip storing if one already exists.

## forget

`dream forget "<query>" [<path>]` searches notes by keyword and semantic match, lists
them, and proposes deletion as a diff:

```text
[note:<file>] — "<title>" [Y/n]
```

Apply only approved deletions (and their index lines). Pinned notes are listed but not
deleted unless explicitly confirmed per note.

## Principles

- **Lossless of meaning** — compaction removes words and redundancy, never facts.
- **Atomic** — one fact per file after the pass.
- **Retrieval-first** — every `description` lets an agent judge relevance from the index
  alone; every note is reachable via tags and `[[links]]`.
- **Conservative deletes** — prune only what is wrong, redundant, or out of scope; refresh
  rather than delete just because old.
- **Idempotent** — running twice in a row changes nothing the second time.
- **No surprises** — diff before write; never auto-push or auto-sync without approval.

## Checklist

- [ ] Resolved KB path from the argument or `$KB_DIR`; never assumed a fixed location.
- [ ] Held everything in memory; no writes before the diff.
- [ ] Inbox ingested and deleted; source docs kept.
- [ ] Near-duplicates merged (same type, >60% noun overlap, not pinned).
- [ ] Contradictions resolved (A/B) or skipped (`--auto`).
- [ ] Stale notes refreshed from sources before pruning; pinned notes untouched.
- [ ] Index rebuilt; no orphans; no broken `[[links]]`.
- [ ] Scope verified (no secrets, hosts, or confidential facts).
- [ ] State stamped; lock removed (`--auto`).

## Resources

- If the KB ships its own `DREAM.md` or `AGENTS.md`, read it first and align with its note
  format, controlled vocabulary, and sync steps.
