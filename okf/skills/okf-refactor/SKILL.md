---
name: okf-refactor
description: Convert existing knowledge (loose notes, docs, wikis, a catalog or metadata export) into an Open Knowledge Format bundle. Use when migrating knowledge to OKF or normalizing a notes folder.
---

# okf-refactor

Emit a conformant OKF v0.1 bundle from existing knowledge. Read `../okf/reference/SPEC.md` first and use the `okf` skill for authoring rules. Check the result with `../okf/scripts/validate_okf.py`.

Confirm `<src>` (read-only, never edited) and `<out>` (a new directory). If `<out>` is missing, default to `./bundles/<name>` and say so.

## Pass

Plan before writing.

1. Survey the source. Identify what each item is (a table, an endpoint, a runbook), which becomes its `type`, and how items relate, which become links.
2. Design the directory layout from `type` or domain. Start flat. Use `tags` for cross-cutting facets.
3. Map each item to one concept file at `<group>/<slug>.md`. Split multi-topic notes.
4. Write frontmatter with a non-empty `type`, a `title`, and a one-line `description`. Set `resource` when the item has a canonical URI. Map source metadata to `tags` and `timestamp`, and keep anything else as extra keys.
5. Write the body: structured fields under `# Schema` as a table, usage under `# Examples`, sources under `# Citations`. Add nothing the source does not support.
6. Turn every relationship into an absolute bundle-relative link. Link or be linked wherever a real relationship exists.
7. Make sources cited by many concepts standalone `references/<slug>.md` docs.
8. Write an `index.md` per navigable directory, and a root `index.md` with `okf_version: "0.1"`. Seed `log.md` with an Initialization entry dated today.
9. Run `validate_okf.py <out>` and fix every error. Resolve broken links you can and report the rest.

## Rules

- Lose redundant words, never facts. Keep metadata with no obvious home as custom frontmatter keys.
- Mark genuine gaps plainly instead of guessing.
- Re-running on the same source should converge on the same bundle.

## Report

Give concept counts by type and group, indexes and reference docs created, links wired, and unresolved gaps. Then show the bundle tree.
