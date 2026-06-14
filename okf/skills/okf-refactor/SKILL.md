---
name: okf-refactor
description: Refactor existing knowledge into an Open Knowledge Format (OKF) bundle — convert loose notes, docs, READMEs, wikis, or a catalog/metadata export into markdown concept files with YAML frontmatter, index.md, and a knowledge graph. Use when migrating existing knowledge to OKF, normalizing a notes folder, or exporting a catalog to OKF.
---

# okf-refactor — convert existing knowledge into an OKF bundle

## Goal

Take knowledge that already exists in some other shape — a folder of loose
markdown notes, a wiki, README/docs, a data-catalog export, a database schema, a
JSON/CSV metadata dump — and emit a conformant **OKF v0.1** bundle: a directory of
one-concept-per-file markdown docs with YAML frontmatter, navigable `index.md`
files, and a cross-linked knowledge graph.

This skill depends on the **okf** skill for the format itself. Read
`../okf/reference/SPEC.md` (the bundled OKF v0.1 spec) before refactoring — it is
the source of truth. Use `../okf/scripts/validate_okf.py` to check the result.

## Inputs and outputs

- **Input** (`<src>`): a directory, file set, or export to read FROM. Treat it as
  immutable ground truth — never edit the source in place.
- **Output** (`<out>`): the bundle directory to write TO. New, separate from `<src>`.

Confirm both paths before writing. If `<out>` is omitted, default to
`./bundles/<name>` and state the choice.

## The refactor pass (run in order; plan before writing)

1. **Survey the source.** Inventory every item of knowledge and its natural
   boundaries. Identify what each "thing" is (a table, an endpoint, a concept, a
   runbook) — that becomes a concept's `type`. Note relationships between things
   (foreign keys, "see also", parent/child) — those become cross-links.

2. **Design the taxonomy = the directory layout.** Group concepts into top-level
   directories by `type` or domain (`tables/`, `datasets/`, `references/`,
   `concepts/`, `playbooks/`…). Start flat; nest only when a level earns it.
   Directories are the coarse taxonomy; frontmatter `tags` carry cross-cutting
   facets.

3. **Map each source item to one concept doc.** Atomic — one concept per file,
   `<group>/<slug>.md`, kebab-case stable slug. Never pack two concepts into one
   file; split multi-topic source notes.

4. **Write frontmatter for each concept.** Always set a non-empty `type`. Derive
   `title` and `description` (one line — this is what indexes show). Set
   `resource` to the canonical URI when the item has one. Map source metadata to
   `tags` and `timestamp`. Preserve any source-specific metadata as extra
   frontmatter keys (consumers tolerate unknown keys) rather than dropping it.

5. **Write the body.** Move structured fields under `# Schema` (prefer a table),
   runnable usage under `# Examples`, and sources under `# Citations`. Keep prose
   tight; favor structural markdown. Do not invent facts not present in the source.

6. **Wire the graph.** Convert every relationship into an inline markdown link
   using **absolute bundle-relative** paths (`[orders](/tables/orders.md)`).
   Ensure no concept is fully orphaned — each should link, or be linked by, at
   least one other where a real relationship exists.

7. **Mint reference docs.** External authoritative sources cited by many concepts
   become standalone `references/<slug>.md` concept docs (with their own `type`,
   e.g. `Reference`), linked from `# Citations`.

8. **Generate indexes.** Write an `index.md` per navigable directory (no
   frontmatter; group under `#` sections; copy each bullet's description from the
   linked concept). Write the bundle-root `index.md` with `okf_version: "0.1"`
   frontmatter linking the top-level groups.

9. **Seed `log.md`.** At the root, record an `## <YYYY-MM-DD>` entry noting the
   `* **Initialization**: Refactored from <source>.` Use the real current date.

10. **Validate.** Run `validate_okf.py <out>`. Fix every error. Broken
    cross-links are warnings (the spec tolerates them) — resolve the ones you can,
    report the rest.

## Fidelity rules

- **Lossless of meaning.** Restructuring may drop redundant words, never facts.
  If the source has metadata with no obvious home, keep it as a custom frontmatter
  key rather than discarding it.
- **No invention.** Don't fabricate descriptions, schemas, or links the source
  doesn't support. Mark genuine gaps plainly instead of guessing.
- **Source stays immutable.** All writes land in `<out>`; `<src>` is read-only.
- **Idempotent-ish.** Re-running against the same source should converge on the
  same bundle, not accumulate duplicates.

## Report

After the pass, summarize: number of concepts emitted (by `type`/group), index and
reference docs created, cross-links wired, and any unresolved gaps or broken links
the source left dangling. Then show the bundle tree.

## Checklist

- [ ] Confirmed `<src>` (read-only) and `<out>` (new) paths.
- [ ] Read ../okf/reference/SPEC.md before refactoring.
- [ ] One concept per file; multi-topic notes split; stable kebab-case slugs.
- [ ] Every concept has a non-empty `type`, plus `title` + `description`.
- [ ] Relationships wired as absolute bundle-relative links; no true orphans.
- [ ] Root index.md has `okf_version: "0.1"`; per-directory indexes generated.
- [ ] log.md seeded with the initialization entry (real date).
- [ ] validate_okf.py run; errors fixed; remaining broken links reported.
- [ ] No facts invented; source-specific metadata preserved as custom keys.
