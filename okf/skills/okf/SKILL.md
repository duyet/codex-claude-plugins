---
name: okf
description: Author, initialize, validate, and render Open Knowledge Format (OKF) bundles, which are knowledge as markdown files with YAML frontmatter. Use when creating an OKF bundle, writing concept docs, building index.md or log.md, checking OKF v0.1 conformance, or rendering a graph viewer.
---

# okf

Read [reference/SPEC.md](reference/SPEC.md) first. It is the full OKF v0.1 spec, bundled for offline use, and it wins over this skill. To convert existing notes or a catalog export into a bundle, use the `okf-refactor` skill.

Rules to apply while authoring (details in the spec):

- Every non-reserved `.md` has YAML frontmatter with a non-empty `type`.
- `index.md` and `log.md` carry no frontmatter. Only the root `index.md` may, and only for `okf_version: "0.1"`.
- Write `title` and `description` on every concept, and `resource` on assets, because consumers index on them.
- Link with absolute bundle-relative paths (`/tables/orders.md`) so links survive moves. Inside an `index.md`, relative links are fine.

## Initialize a bundle

1. Confirm the path and create the root directory.
2. Choose top-level groups from the domain (`tables/`, `playbooks/`, `concepts/`). Start flat and nest only when a level earns it.
3. Write the root `index.md` with `okf_version: "0.1"` frontmatter, a title, and one bullet per group.
4. Add `references/` only if you expect standalone citation docs. Optionally seed `log.md` with today's date.

## Author a concept

One concept per file at `<group>/<slug>.md`, with a stable kebab-case slug.

```markdown
---
type: BigQuery Table
title: Orders
description: One row per completed customer order
resource: <canonical URI, if any>
tags: [sales]
timestamp: 2026-01-01T00:00:00Z
---

# Schema

| Column | Type | Description |
| --- | --- | --- |
| customer_id | STRING | FK to [customers](/tables/customers.md) |
```

Prefer tables, lists, and code blocks over prose. Add `# Examples` and `# Citations` sections when useful. Each inline link is an undirected graph edge. Extra frontmatter keys are allowed.

## Indexes and log

Write an `index.md` for each directory worth navigating, grouped under `#` headings, with each bullet's description copied from the concept. Regenerate it when concepts change. `log.md` is newest-first with ISO date headings.

## Render a viewer

`scripts/render_okf_viewer.py <bundle>` writes fresh `index.md` files at every level and a self-contained `viz.html` graph viewer. Pass `--title` and `--out` to change the title or output path. It draws edges from `related:` frontmatter, `[[slug]]` wikilinks, and markdown links, and colors nodes by `type`. It is idempotent.

## Validate

`scripts/validate_okf.py <bundle>` checks frontmatter and `type`, reserved-file structure, and reports broken links as warnings, which the spec tolerates. Fix errors, and resolve warnings you can.

Run both scripts from this skill's directory.
