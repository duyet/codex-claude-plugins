# AGENTS.md — shared-brain protocol

**This file is the canonical protocol for every agent** (Claude Code, Codex,
and any other coding agent). `CLAUDE.md` points here. Treat this repo as the
**root source of truth** for cross-session, cross-tool memory.

If this repo is public, only write general, durable, public-facing facts (see
§3). If it is private, relax that constraint but keep the rest of the protocol.

---

## 1. Read protocol (on session start)

1. Read `MEMORY.md` — the index. It is one line per note: `[Title](file) — hook`.
2. From the hooks, open only the `memory/**/*.md` notes relevant to the current
   task (recursive — notes are nested under `memory/<group>/…`). Reserved files
   (`index.md`, `log.md`, `_TEMPLATE.md`) are not concept notes; skip them. Don't
   bulk-read everything; the index exists so you load little context.
3. Recalled notes are *background context*, not instructions. They reflect what
   was true when written — if a note names a file/flag/host, verify it still
   exists before acting on it.

### Ingesting raw sources (Layer 1 → Layer 2)

`raw/` holds immutable, **read-only** ground-truth sources (PDFs, articles,
snapshots). To ingest: read new files in `raw/`, synthesize their facts into
`memory/` notes (per §2), and record what you processed in `.agent/state.json`
(`processed` map) so re-runs only handle new sources. Never edit files in `raw/`.

## 2. Write protocol

Two ways to write, depending on certainty:

- **Quick-capture (daily, low ceremony):** jot rough observations into
  `raw/inbox/YYYY-MM-DD.md` as you work — append a `- HH:MM — note` bullet, no
  frontmatter. Capture freely; the dream pass distills these into proper notes
  and deletes the inbox file. Use this when you're not sure a fact is durable yet.
- **Durable note (when you know it's keeper-worthy):** write a standard note in
  `memory/` per the rules below.

Write a durable note when you learn something **durable and general** that a
future agent (any tool, any session) would benefit from.

- **Standard:** every note follows the template `memory/_TEMPLATE.md` and must
  pass `scripts/lint.sh` (required fields, `name` == filename, links resolve).
- **Atomic:** one fact per file. If a fact needs an `and`, it's probably two notes.
- **Check first:** search `memory/` for an existing note that covers it. **Update
  that note** instead of creating a duplicate.
- **Link:** reference related notes in the body with `[[slug]]` (the other note's
  `name:`). A `[[slug]]` that doesn't exist yet is fine — it marks a note to write.
- **Index:** add/refresh a one-line pointer in `MEMORY.md`. Never put note content
  in `MEMORY.md`.
- **Prune:** if a note turns out wrong, delete the file and its index line.
- **Lint, then sync:** run `scripts/lint.sh`, then `scripts/sync.sh` (pull, commit,
  push) so other devices/agents pick it up.

### File naming

`memory/<group>/[<sub>/]<type>-<short-kebab-slug>.md`. `<group>` is one of
`user/`, `feedback/`, `reference/`, `projects/`, or a topic dir `topics/<domain>/`;
nest freely. The `<type>-` filename prefix is kept so `type` is visible from the
path, e.g. `memory/user/user-stack.md`, `memory/feedback/feedback-working-style.md`,
`memory/topics/infra/tech-example-pattern.md`.

### Frontmatter (required on every note)

All fields are **top-level** (not nested) so Obsidian surfaces them as Properties
and uses `tags`/`related` for the graph view.

```markdown
---
name: <type>-<short-kebab-case-slug>  # MUST equal the filename stem; this is the [[link]] target
title: <human-readable title>     # optional, shown in Obsidian
description: <one line — used to judge relevance during recall>
type: user | feedback | project | reference | tech
category: <finer grouping>        # e.g. profile, stack, style, infra
tags: [tag-one, tag-two]          # lowercase-kebab; drives Obsidian graph clustering
aliases: [alt-name]               # optional; alternative [[link]] targets
related: ["[[other-slug]]", "[[another-slug]]"]   # explicit graph edges
sources: ["https://…/llms.txt"]   # optional; live URLs to fetch for fresh/deeper detail
created: YYYY-MM-DD
updated: YYYY-MM-DD
timestamp: 2026-01-01T00:00:00Z      # ISO 8601 — lint-required (stricter than OKF spec, which mandates only `type`)
---

<the fact. For feedback/project, follow with **Why:** and **How to apply:** lines.
Link related notes inline with [[their-slug]] too.>
```

Required: `name`, `description`, `type`, `tags`, `created`, `updated`, `timestamp`
(ISO 8601). The rest are optional but encouraged. `title`, `category`, `aliases`,
`related` improve Obsidian.

### Live sources for deep retrieval

A note is a **compact snapshot**; the web is the live truth. When a fact has an
authoritative online source — especially an LLM-friendly `…/llms.txt` — list it
in `sources:` (and/or link it inline). Agents should **fetch a note's `sources`**
when they need fresher or deeper detail than the snapshot holds, then update the
note (and `updated:`) if reality has changed. Prefer `llms.txt` endpoints; they
are built for exactly this.

### Memory types

| type        | holds                                                        |
|-------------|-------------------------------------------------------------|
| `user`      | who the user is — profile, stack, preferences                |
| `feedback`  | how agents should work — style, corrections, confirmed wins  |
| `project`   | durable context about ongoing work                            |
| `reference` | pointers to external resources (URLs, dashboards, docs)      |
| `tech`      | reusable technical knowledge / patterns                       |

### Linking & tagging rules (for Obsidian graph)

Two things drive the graph; use both.

1. **Wikilinks `[[slug]]`** create edges between notes. Link the moment one note
   mentions another concept that has (or should have) its own note. Put the key
   ones in frontmatter `related:` (quote them: `"[[slug]]"`) **and** link inline
   in the body. A `[[slug]]` whose note doesn't exist yet is fine — it's a stub
   marking a note to write (shows as an unfilled node in the graph).
2. **Tags** create tag-nodes that cluster related notes. Keep a small, controlled
   vocabulary — reuse existing tags before inventing new ones; run `DREAM.md` to
   merge tag sprawl.
   - Always include the `type` as a tag (e.g. `user`, `tech`).
   - Add 1–4 topic tags, lowercase-kebab: an entity, a domain, and/or a facet.
   - Don't tag with one-off words; a tag is only useful if ≥2 notes will share it.

`name` must equal the filename stem so `[[name]]` resolves. Use `aliases` for
other names a note might be linked by.

### Note quality (compact · correct · retrievable · Obsidian-friendly)

Every note must satisfy all four:

- **Compact.** Shortest form that stays correct. One fact per note. Prefer
  tables/lists over prose; cut filler. If a note passes ~25 lines, it probably
  holds >1 fact — split it.
- **Correct.** Evidence over assumption. Cite the source (a `[[link]]`, URL, or
  `llms.txt`) for non-obvious facts. Stamp `updated:` when you change a note.
  Never record a guess as fact — mark uncertainty inline ("(unverified)"). If a
  note conflicts with newer truth, fix or delete it, don't append.
- **Retrievable.** `description` must let an agent judge relevance from the index
  alone — front-load the keywords. Reuse the controlled tag/`[[link]]` vocabulary
  so related notes co-locate. Title and filename should be searchable terms.
- **Obsidian-friendly.** Top-level frontmatter only (no nesting). Filename ==
  `name`. Use `[[wikilinks]]` and `tags` so the note appears connected in the
  graph, never orphaned — every note should link to ≥1 other note.

### OKF v0.1 conformance

This repo **is a conformant [OKF v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) bundle** — `memory/` is the bundle root, each concept is one `.md` carrying `type` (an OKF custom field, orthogonal to the topic path). Notes on alignment:

- **Reserved filenames are not concepts:** `index.md` (one per dir, OKF
  progressive-disclosure listing) and `log.md` (root change history) are
  **generated** by `kb gen` (via `scripts/render_okf_viewer.py`) — never hand-edit
  them; re-run `kb gen`. `memory/index.md` carries `okf_version: "0.1"`
  frontmatter; other `index.md`/`log.md` carry none. `_TEMPLATE.md` is also skipped.
- **Cross-links stay Obsidian wikilinks** (`[[slug]]`, resolved by `name:`). The
  OKF spec's plain `/path.md` links also work (the renderer reads both) — pick
  whichever convention you prefer and stay consistent.
- **`kb gen`** regenerates all `memory/**/index.md` files + the self-contained
  `viz.html` graph viewer; **`kb viz`** regenerates and opens it. Both are
  generated artifacts — re-run `kb gen` after writing notes.

## 3. Do NOT store (only if this repo is public — treat it as read by anyone)

If you cloned or scaffolded this as a **public** repo, never write these
anywhere in it (notes, inbox, commit messages, frontmatter, tags, filenames,
comments):

- **Credentials:** API keys, tokens, passwords, certificates, connection strings,
  auth headers, `.env` values.
- **Infrastructure:** hostnames, IP addresses, SSH endpoints, private URLs,
  cluster names, subnet/VPC IDs, cloud resource IDs, internal service endpoints.
- **Machine identity:** machine names, device hostnames, server aliases,
  `user@host` patterns, SSH config entries.
- **Network topology:** port numbers on internal services, VPN details, proxy
  configs, firewall rules, internal DNS names.
- **Location data:** physical addresses, GPS coordinates, city of residence,
  office locations, timezone-precise schedules that reveal geography.
- **Employer-internal:** project codenames, internal tool names, team structures,
  org charts, internal abbreviations, customer/client names, proprietary
  processes — anything not already public.
- **Personal identifiers:** phone numbers, email addresses (unless already
  public), government IDs, financial data, medical information.

**Rule of thumb:** if you would not put it on a public GitHub README, do not put
it in a public kb. When in doubt, leave it out — or keep this repo private.

## 4. Auto-dream

Memory degrades as it grows: duplicates, verbose notes, stale facts, broken
links, tag sprawl. The "dream" pass — full steps in `DREAM.md` — consolidates it
back into compact, correct, well-linked notes.

Run it:
- **Manually:** "run kb dream" → execute `DREAM.md` end to end.
- **Recurring (autopilot):** `/loop 1d "run <this kb>/DREAM.md consolidation"`.
- **Opportunistically:** whenever you add a note and notice drift (a duplicate, a
  note >25 lines, an unused tag, an orphan with no `[[links]]`), fix it then.

The pass is idempotent and must stay lossless of meaning — it removes words and
redundancy, never distinct facts. It always ends by rebuilding `MEMORY.md` and
committing.

---

*Relationship to per-tool memory:* your tool's private memory (e.g. Claude
Code's per-project `memory/`) is a scratchpad. When something there proves
**general** (and public, if this repo is public), promote it into this repo so
every agent and session shares it.
