# kb

Knowledge base maintenance skills for markdown KBs. KB-agnostic: point each skill at any
markdown knowledge base via a path argument or the `$KB_DIR` environment variable.

## Skills

- **init** — scaffold a brand-new shared-brain kb folder (default `~/kb`): the
  memory protocol (`AGENTS.md`/`CLAUDE.md`/`DREAM.md`/`MEMORY.md`), an OKF v0.1
  `memory/` bundle, a capture inbox, and a self-contained CLI (`bin/kb`,
  `scripts/render_okf_viewer.py` for the graph viewer, `lint.sh`, `sync.sh`,
  `wire.sh`). Idempotent; never overwrites existing files; never edits anything
  outside the target folder without asking first.
- **dream** — the consolidation pass. Merges near-duplicate notes, flags contradictions,
  prunes stale/low-value notes, ingests inbox captures, refreshes notes from their
  source URLs, splits multi-fact notes, relinks/retags, and rebuilds the index. Shows a
  diff for approval before changing anything. Supports `--auto` (non-interactive, lock
  guarded) and `forget` (delete specific notes).

## Install

```bash
/plugin install kb@duyet-claude-plugins
```

## Usage

```bash
init                       # scaffold a new shared-brain kb at ~/kb (or $KB_DIR)
init ~/kb                  # scaffold at an explicit path

dream ./docs/kb            # consolidate a KB (interactive, diff-for-approval)
dream $KB_DIR --auto       # non-interactive; merges/prunes, skips contradictions
dream forget "old server"  # propose deleting notes matching a query
```

The KB is any directory of `*.md` notes with YAML frontmatter (`name`, `type`, `tags`,
`created`, `updated`, optional `pinned`/`confidence`/`sources`), optionally with a
`MEMORY.md` index, a `raw/inbox/` of captures, and `raw/` source docs — exactly what
`init` scaffolds. It is also a conformant [OKF v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
bundle; see the companion **okf** plugin for deeper bundle authoring, validation, and
graph-viewer rendering.
