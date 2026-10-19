---
name: okf-refactor
description: Convert existing knowledge (loose notes, docs, wikis, a catalog or metadata export) into an Open Knowledge Format bundle. Use when migrating knowledge to OKF or normalizing a notes folder.
---

# okf-refactor

Read `../okf/reference/SPEC.md` and follow the `okf` skill's authoring rules. Confirm `<src>` (read-only) and `<out>` (new directory, default `./bundles/<name>`, say so).

- Plan the `type` and layout before writing. One concept file per item, split multi-topic notes, turn relationships into links.
- Lose redundant words, never facts. Keep unmapped metadata as extra frontmatter keys. Mark gaps instead of guessing. Re-running must converge on the same bundle.
- Seed `log.md` with an Initialization entry. Root `index.md` carries `okf_version: "0.1"`.
- Run `../okf/scripts/validate_okf.py <out>` and fix every error.

Report concept counts by type, links wired, unresolved gaps, and the bundle tree.
