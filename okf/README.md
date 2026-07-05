# okf

Tooling for the **Open Knowledge Format (OKF)** — a vendor-neutral way to represent
knowledge as plain markdown files with YAML frontmatter, organized in a directory
hierarchy. A bundle is just a directory: version-controllable, portable, lock-in
free, and readable by humans, LLMs, and any tool that speaks markdown (Obsidian,
Notion, MkDocs, a static file server, a search index, a graph viewer).

Spec: [OKF v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
— bundled verbatim at `skills/okf/reference/SPEC.md` so the agent is grounded
offline.

## Skills

- **okf** — author, initialize, validate, and render OKF bundles. Scaffolds the
  correct layout, writes concept docs with proper frontmatter, generates
  `index.md` / `log.md`, ships `validate_okf.py` for OKF v0.1 conformance
  checks, and `render_okf_viewer.py` to render a bundle as a self-contained
  interactive graph viewer.
- **okf-refactor** — convert existing knowledge (loose notes, wikis, README/docs,
  a catalog/metadata export, a database schema) into a conformant OKF bundle:
  one concept per file, cross-linked into a knowledge graph, with generated indexes.

## Install

```bash
/plugin marketplace add duyet/codex-claude-plugins
/plugin install okf@duyet-claude-plugins
```

Alternative ([skills.sh](https://skills.sh)):

```bash
npx skills add duyet/codex-claude-plugins
```

## Usage

```text
# Initialize a fresh bundle
okf init an OKF bundle at ./bundles/my_catalog

# Author a concept
okf add a BigQuery Table concept for the orders table

# Validate conformance
python3 skills/okf/scripts/validate_okf.py ./bundles/my_catalog

# Render an interactive graph viewer
python3 skills/okf/scripts/render_okf_viewer.py ./bundles/my_catalog

# Refactor existing knowledge into OKF
okf-refactor convert ./notes into an OKF bundle at ./bundles/notes
```

## What conformance means (OKF v0.1)

1. Every non-reserved `.md` file has parseable YAML frontmatter.
2. Every frontmatter block has a non-empty `type`.
3. Reserved files (`index.md`, `log.md`) follow their structure and carry no
   frontmatter — except the bundle-root `index.md`, which may declare
   `okf_version: "0.1"`.

Consumers are required to tolerate unknown types, unknown keys, broken links, and
missing indexes — so producing OKF is forgiving, and these skills aim to produce
the disciplined, well-linked end of that spectrum.
