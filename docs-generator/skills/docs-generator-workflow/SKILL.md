---
name: docs-generator
description: Use when regenerating or maintaining this plugin marketplace documentation from plugin manifests and component folders.
---

# Docs Generator

Use this skill to regenerate and review the repository's plugin documentation.

## Workflow

1. Inspect plugin manifests and component folders before changing generated documentation.
2. Run `docs-generator/scripts/generate-docs.sh` from the repository root when regeneration is requested.
3. Review the generated root README and plugin CLAUDE files for accuracy.
4. Keep generated text grounded in manifest descriptions and actual files.

## Notes

- The Claude hook configuration lives in `hooks/hooks.json`.
- Keep Claude and Codex plugin metadata synchronized when both manifest families exist.
