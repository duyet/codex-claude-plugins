---
name: okf
description: Author, initialize, validate, and render Open Knowledge Format (OKF) bundles — vendor-neutral knowledge as markdown files with YAML frontmatter. Use when creating an OKF bundle, scaffolding a knowledge catalog, writing OKF concept docs, building index.md/log.md files, checking a bundle for OKF v0.1 conformance, or rendering a bundle as an interactive graph viewer.
---

# okf — author and validate Open Knowledge Format bundles

## What OKF is

Open Knowledge Format (OKF) is a vendor-neutral format for representing knowledge
as plain markdown files with YAML frontmatter, organized in a directory hierarchy.
It is not tied to any agent, framework, model provider, or serving system. A
bundle is just a directory: version-controllable, portable, lock-in free, readable
by humans and LLMs alike, and consumable by anything that reads markdown (Obsidian,
Notion, MkDocs, a static file server, a search index, a graph viewer).

**Read [reference/SPEC.md](reference/SPEC.md) first** — it is the full OKF v0.1
spec, bundled so you can ground every decision in it without network access. When
the spec and this skill disagree, the spec wins.

## When to use

- Initialize a new, empty OKF bundle with the correct layout.
- Author or edit OKF concept documents (one concept per `.md` file).
- Generate or refresh `index.md` (progressive disclosure) and `log.md` (history).
- Validate an existing bundle for OKF v0.1 conformance.
- Render a bundle as a self-contained, interactive graph viewer (`viz.html`).

To convert an existing pile of notes / a catalog export into an OKF bundle, use
the companion **okf-refactor** skill instead.

## The non-negotiable rules (from the spec)

1. Every non-reserved `.md` file MUST have parseable YAML frontmatter.
2. Every frontmatter block MUST include a non-empty `type`.
3. Reserved filenames — `index.md`, `log.md` — follow their special structure and
   carry NO frontmatter (the sole exception: the bundle-root `index.md` may carry
   `okf_version`).
4. Cross-links are normal markdown links; prefer **absolute bundle-relative**
   paths (`/tables/orders.md`) over relative ones so links survive file moves.
5. Be a disciplined producer: emit `title`, `description`, and (for assets)
   `resource` even though only `type` is strictly required — consumers index on them.

## Initialize a new bundle

When asked to init/scaffold an OKF bundle at `<path>`:

1. Confirm `<path>` (ask if not given). Create the root directory.
2. Decide the top-level grouping from the domain — directories ARE the coarse
   taxonomy (e.g. `datasets/`, `tables/`, `references/`, or `concepts/`,
   `playbooks/`, …). Don't over-structure; start flat, nest only when a level
   earns it.
3. Write a bundle-root `index.md` that declares the version and links the groups:

   ```markdown
   ---
   okf_version: "0.1"
   ---

   # <Bundle name>

   - [Datasets](datasets/) - <group description>
   - [Tables](tables/) - <group description>
   ```

4. Add a `references/` directory only if you expect standalone citation docs.
5. Optionally seed a root `log.md` with an `## <YYYY-MM-DD>` / `* **Initialization**`
   entry. Use the real current date.

## Author a concept document

One concept per file, `<group>/<slug>.md`. Slug is kebab-case, stable, matches the
asset name where possible.

```markdown
---
type: <Type name> # REQUIRED — e.g. "BigQuery Table", "API Endpoint", "Playbook"
title: <Display name> # strongly recommended
description: <one-line summary> # strongly recommended — used in indexes/previews
resource: <canonical URI> # for assets that have one
tags: [<tag>, <tag>] # optional, cross-cutting
timestamp: <ISO 8601> # optional, last meaningful change
---

# Schema (when the concept has structured fields — prefer a table)

| Column | Type | Description                    |
| ------ | ---- | ------------------------------ |
| ...    | ...  | FK to [other](/group/other.md) |

# Examples (concrete usage in code blocks)

# Citations (external sources)

[1] [Title](https://example.com)
```

Guidance:

- Prefer structural markdown (tables, lists, code blocks) over prose paragraphs.
- Express relationships by **linking** related concepts inline in the prose; the
  link is an undirected edge in the knowledge graph.
- Add producer-specific frontmatter keys freely — consumers preserve unknowns.

## Generate / refresh `index.md`

For any directory worth navigating, write an `index.md` with NO frontmatter
(except the root, which keeps `okf_version`). Group concepts under `#` sections;
pull each bullet's description from the linked concept's `description`:

```markdown
# Tables

- [Orders](orders.md) - one row per completed customer order
- [Customers](customers.md) - one row per customer
```

Use relative links inside an index (they sit beside their targets). Regenerate the
index whenever concepts are added, removed, or re-described.

## Maintain `log.md`

Append directory-level history, newest first, ISO dates:

```markdown
# Directory Update Log

## 2026-06-14

- **Creation**: Added orders and customers tables.
```

## Render a graph viewer

`scripts/render_okf_viewer.py` turns any bundle into a self-contained HTML
graph viewer (cytoscape + marked, loaded from CDN, no build step) plus fresh
`index.md` files at every level — the interactive counterpart to the flat
listings in "Generate / refresh index.md" above.

```bash
python3 ${CLAUDE_PLUGIN_ROOT}/skills/okf/scripts/render_okf_viewer.py ./bundles/my_bundle
python3 ${CLAUDE_PLUGIN_ROOT}/skills/okf/scripts/render_okf_viewer.py ./bundles/my_bundle \
  --title "My Catalog" --out ./bundles/my_bundle/viz.html
```

(Outside a plugin runtime, the script lives next to this SKILL.md under `scripts/`.)

It draws one edge per link it finds, from any of three sources — a bundle
written with only one of these still renders correctly:

- `related: ["[[slug]]", "other-slug"]` frontmatter
- `[[slug]]` wikilinks in the body
- `[text](path/to/concept.md)` markdown links — bundle-relative absolute
  (`/tables/orders.md`) or relative to the linking file

Node color is assigned per `type` in first-seen order from a fixed palette, so
any bundle's custom types get stable, distinct colors — nothing to configure.
Regenerate after adding, removing, or re-linking concepts; it's idempotent.

## Validate a bundle for OKF v0.1 conformance

Run `scripts/validate_okf.py <bundle>` (bundled with this skill) for a mechanical
check, then eyeball the report. It verifies:

- Every non-reserved `.md` has parseable frontmatter with a non-empty `type`.
- `index.md` / `log.md` carry no frontmatter (root `index.md` may carry only
  `okf_version`).
- Reports broken bundle-relative cross-links as warnings (broken links are
  _tolerated_ by the spec — surface them, don't fail on them).

```bash
python3 ${CLAUDE_PLUGIN_ROOT}/skills/okf/scripts/validate_okf.py ./bundles/my_bundle
```

(Outside a plugin runtime, the script lives next to this SKILL.md under `scripts/`.)

## Checklist

- [ ] Read reference/SPEC.md before authoring.
- [ ] Every concept file has frontmatter with a non-empty `type`.
- [ ] Ran render_okf_viewer.py after adding/removing/relinking concepts, if a viewer is wanted.
- [ ] `title` + `description` present on concepts; `resource` on assets.
- [ ] Cross-links use absolute bundle-relative paths in concept bodies.
- [ ] Root `index.md` declares `okf_version: "0.1"`; other index/log files have no frontmatter.
- [ ] Indexes regenerated to match current concepts; descriptions copied from concepts.
- [ ] Ran validate_okf.py; resolved errors (broken links are warnings, not errors).
