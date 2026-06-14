# Open Knowledge Format (OKF) v0.1 — Specification

> Vendor-neutral format for representing knowledge as plain markdown files with
> YAML frontmatter. Not tied to any agent, framework, model provider, or serving
> system. Anyone can produce it (humans, agents, export pipelines, scripts);
> anyone can consume it (file servers, Obsidian/Notion/MkDocs, LLMs, search
> indexes, graph viewers).
>
> Source: https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md

## Core principles

- **Human- and agent-readable** — no SDK or query language between reader and content.
- **Version-controllable** — bundles live in git; diffs, blame, review just work.
- **Portable, lock-in free** — a bundle is a directory; tarball it, host it anywhere.
- **Structured + unstructured deliberately** — frontmatter for the few fields you
  query/filter/index on; markdown body for prose, schemas, examples.
- **Minimally opinionated, freely extensible** — a small set of required keys for
  interoperability; arbitrary extra frontmatter keys and body sections are allowed.
- **Progressive disclosure** — `index.md` files let a reader navigate one level at
  a time instead of loading the whole bundle.
- **Graph-shaped** — concepts link to each other via normal markdown links,
  expressing relationships richer than the directory tree.

## Bundle structure

A knowledge bundle is a hierarchical directory of markdown files:

```
bundle_root/
├── index.md            (optional; only place frontmatter is allowed in an index)
├── log.md              (optional)
├── concept.md
└── subdirectory/
    ├── index.md
    ├── concept.md
    └── nested_subdirectory/
```

**Reserved filenames:**
- `index.md` — progressive-disclosure directory listings.
- `log.md` — chronological update history.

Every other `.md` file represents one concept.

## Concept document

Two sections: required YAML frontmatter, then a markdown body.

### Frontmatter

```yaml
---
type: <Type name>                 # REQUIRED — non-empty string
title: <Display name>             # Recommended
description: <One-line summary>    # Recommended
resource: <Canonical URI>          # Recommended for assets
tags: [<tag>, <tag>]               # Optional
timestamp: <ISO 8601 datetime>     # Optional
# Producers may add arbitrary custom keys.
---
```

- **`type` (REQUIRED)** — descriptive string identifying the concept category
  (e.g. `BigQuery Table`, `API Endpoint`, `Playbook`). Types are not centrally
  registered; consumers must tolerate unknown types.
- **`title`** — display name; consumers may derive from filename if omitted.
- **`description`** — single-sentence summary for previews and indexes.
- **`resource`** — URI uniquely identifying the underlying asset.
- **`tags`** — YAML list for cross-cutting categorization.
- **`timestamp`** — last meaningful change, ISO 8601.

Producers may add custom key/value pairs; consumers must preserve unknown fields
on round-trips.

### Body

Standard markdown. Conventional section headings (prefer structural markdown —
tables, lists, code blocks — over prose):

| Section       | Purpose                                       |
|---------------|-----------------------------------------------|
| `# Schema`    | Structured description of columns/fields.     |
| `# Examples`  | Concrete usage examples in code blocks.       |
| `# Citations` | External sources supporting claims.           |

## Cross-linking

- **Absolute (bundle-relative) — recommended:** `[customers](/tables/customers.md)`
  — stable when documents move within subdirectories.
- **Relative — standard markdown:** `[neighbor](./other.md)`.

Links assert relationships conveyed by the surrounding prose, not by link syntax.
Consumers treat all links as undirected edges; broken links are tolerated as
incomplete knowledge.

## Index files (`index.md`)

Optional, support progressive disclosure. Sections group concepts. No frontmatter
(except the bundle-root `index.md`, which may carry `okf_version`):

```markdown
# Section Heading

* [Title](relative-url) - description from the linked concept
* [Subdirectory](subdir/) - group description

# Another Section

* [Title](url) - description
```

Producers may generate them automatically; consumers may synthesize dynamically.

## Log files (`log.md`)

Optional, record directory-level history as date-grouped entries, newest first.
Date headings must use ISO 8601 `YYYY-MM-DD`. Leading bold words are conventional:

```markdown
# Directory Update Log

## 2026-05-22
* **Update**: Description of change
* **Creation**: Description of new content

## 2026-05-15
* **Initialization**: Foundational changes
```

## Citations

External sources supporting concept claims go under `# Citations`. Links may be
absolute URLs, bundle-relative paths, or paths into a `references/` subdirectory:

```markdown
# Citations

[1] [Title](https://absolute-url)
[2] [Title](/bundle-relative-path)
[3] [Title](references/local-reference.md)
```

## Conformance

A bundle conforms to OKF v0.1 if:

1. Every non-reserved `.md` file contains parseable YAML frontmatter.
2. Every frontmatter block includes a non-empty `type` field.
3. Reserved filenames (`index.md`, `log.md`) follow the structure above when present.

Consumers must gracefully handle: missing optional fields, unknown `type` values,
unknown frontmatter keys, broken cross-links, and absent index files. This
permissive model supports growth, refactoring, and partial agent generation.

## Versioning

A bundle may declare its target version with `okf_version: "0.1"` in the
**bundle-root `index.md` frontmatter** — the only place frontmatter appears in an
index file.

- **Minor bumps:** backward-compatible additions (new optional fields, headings).
- **Major bumps:** breaking changes (field renames, reserved-filename changes).

Best-effort consumption is preferred over rejection.

## Minimal example

```
my_bundle/
├── index.md
├── datasets/
│   ├── index.md
│   └── sales.md
└── tables/
    ├── index.md
    ├── orders.md
    └── customers.md
```

`datasets/sales.md`:

```markdown
---
type: BigQuery Dataset
title: Sales
description: All sales-related tables for the retail business.
resource: https://console.cloud.google.com/bigquery?p=acme&d=sales
tags: [sales]
timestamp: 2026-05-28T00:00:00Z
---

The sales dataset contains transactional tables, including
[orders](/tables/orders.md) and [customers](/tables/customers.md).
```

`tables/orders.md`:

```markdown
---
type: BigQuery Table
title: Orders
description: One row per completed customer order.
resource: https://console.cloud.google.com/bigquery?p=acme&d=sales&t=orders
tags: [sales, orders]
timestamp: 2026-05-28T00:00:00Z
---

# Schema

| Column        | Type    | Description                              |
|---------------|---------|------------------------------------------|
| `order_id`    | STRING  | Unique order identifier.                 |
| `customer_id` | STRING  | FK to [customers](/tables/customers.md). |
| `total_usd`   | NUMERIC | Order total in USD.                      |

Part of the [sales dataset](/datasets/sales.md).
```
