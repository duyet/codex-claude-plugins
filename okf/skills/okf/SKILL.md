---
name: okf
description: Author, initialize, validate, and render Open Knowledge Format (OKF) bundles, which are knowledge as markdown files with YAML frontmatter. Use when creating an OKF bundle, writing concept docs, building index.md or log.md, checking OKF v0.1 conformance, or rendering a graph viewer.
---

# okf

Read [reference/SPEC.md](reference/SPEC.md) first. It is the full OKF v0.1 spec and wins over this skill. To convert existing notes, use `okf-refactor`.

- Every non-reserved `.md` has YAML frontmatter with a non-empty `type`. Write `title` and `description` on every concept and `resource` on assets.
- `index.md` and `log.md` carry no frontmatter. Only the root `index.md` may, and only for `okf_version: "0.1"`.
- One concept per `<group>/<slug>.md`, kebab-case slug. Link with absolute bundle-relative paths (`/tables/orders.md`). Prefer tables and lists over prose.
- Start flat and nest only when a level earns it. Write an `index.md` per navigable directory. `log.md` is newest first with ISO date headings.

From this skill's directory:

- `python3 scripts/render_okf_viewer.py <bundle>` writes `index.md` files and a self-contained `viz.html` graph viewer (`--title`, `--out`). Idempotent.
- `python3 scripts/validate_okf.py <bundle>` checks conformance. Fix errors and resolve warnings you can.
