# okf

Tooling for the Open Knowledge Format (OKF): knowledge as plain markdown files with YAML frontmatter in a directory tree. A bundle is a version-controllable directory that humans, LLMs, Obsidian, MkDocs, and graph viewers can all read.

```bash
/plugin install okf@duyet-claude-plugins
```

## What ships

- `okf` authors, initializes, validates, and renders bundles. It includes `validate_okf.py` for conformance checks, `render_okf_viewer.py` for a self-contained graph viewer, and the OKF v0.1 spec at `skills/okf/reference/SPEC.md`.
- `okf-refactor` converts existing notes, wikis, or catalog exports into a conformant bundle.

## Use

```text
okf init an OKF bundle at ./bundles/my_catalog
okf add a BigQuery Table concept for the orders table
okf-refactor convert ./notes into an OKF bundle at ./bundles/notes

python3 skills/okf/scripts/validate_okf.py ./bundles/my_catalog
python3 skills/okf/scripts/render_okf_viewer.py ./bundles/my_catalog
```

Spec: [OKF v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md).

The `kb` plugin vendors an identical copy of `render_okf_viewer.py` so scaffolded knowledge bases work without this plugin.
