# kb

Knowledge base maintenance skills for markdown KBs. KB-agnostic: point each skill at any
markdown knowledge base via a path argument or the `$KB_DIR` environment variable.

## Skills

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
dream ./docs/kb           # consolidate a KB (interactive, diff-for-approval)
dream $KB_DIR --auto      # non-interactive; merges/prunes, skips contradictions
dream forget "old server" # propose deleting notes matching a query
```

The KB is any directory of `*.md` notes with YAML frontmatter (`name`, `type`, `tags`,
`created`, `updated`, optional `pinned`/`confidence`/`sources`), optionally with a
`MEMORY.md` index, a `raw/inbox/` of captures, and `raw/` source docs.
