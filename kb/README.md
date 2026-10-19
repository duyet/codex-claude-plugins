# kb

Skills for scaffolding and maintaining a markdown knowledge base shared by every coding agent. Point each skill at a path or set `$KB_DIR`.

```bash
/plugin install kb@duyet-claude-plugins
```

## What ships

- `init` scaffolds a shared-brain folder (default `~/kb`): protocol files, an OKF v0.1 `memory/` bundle, a capture inbox, and a self-contained CLI with a graph viewer. It never overwrites existing files and asks before editing anything outside the folder.
- `dream` consolidates a KB: merges duplicates, flags contradictions, prunes stale notes, ingests the inbox, refreshes notes from their sources, and rebuilds the index. It shows a diff first. `--auto` runs unattended and `forget` deletes chosen notes.

```bash
/init ~/kb
/dream ./docs/kb
/dream $KB_DIR --auto
/dream forget "old server"
```

The scaffolded folder vendors its own copy of `render_okf_viewer.py`, identical to the one in the `okf` plugin, so it keeps working without this plugin installed. See `okf` for bundle authoring and validation.
