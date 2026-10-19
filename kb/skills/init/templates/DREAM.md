# DREAM.md

The maintenance pass that keeps this KB compact and retrievable. Run it by hand, on a schedule (`/loop 1d "run DREAM.md"`), or when notes duplicate, contradict newer facts, go stale, or sprawl.

## The pass

1. Load `MEMORY.md`, every `memory/**/*.md` except `index.md`, `log.md`, and `_TEMPLATE.md`, `raw/inbox/*.md`, the `raw/` source docs, and `.agent/state.json`.
2. Ingest. Promote durable, general facts from the inbox and from any `raw/` doc not in `state.json.processed` into new or rewritten notes (see `AGENTS.md` section 2). Delete processed inbox files. Keep source docs and record them in `processed`.
3. Merge duplicates into one note. Keep the clearest, most recent wording. Lose words, not facts.
4. Split notes that hold several facts.
5. Validate frontmatter: top-level `name` (equals the filename stem), `description`, `type`, `tags`, `created`, `updated`, `timestamp`. Fix the `<type>-` filename prefix if `type` changed.
6. Refresh notes whose `sources:` are older than about 30 days, preferring `llms.txt`. Bump `updated` and `timestamp`.
7. Compact each note to about 25 lines.
8. Fix `[[slug]]` links, give every note at least one link, and fold tag sprawl into the existing vocabulary.
9. Prune notes that are wrong, obsolete, or now private. Refresh instead of deleting for age alone.
10. Rebuild `MEMORY.md`, grouped by `type`, one line each: `[Title](<file>) - hook`. Run `kb gen` to regenerate `memory/**/index.md` and `viz.html`, then append a dated entry to `memory/log.md`.
11. If this repo is public, remove anything that breaks `AGENTS.md` section 3.
12. Set `state.json.last_dream` to today and run `scripts/sync.sh` if there is a git remote.

The pass is idempotent. A second run changes nothing.
