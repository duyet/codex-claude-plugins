# kb — your shared brain

A single, plain-text knowledge base that every coding agent (Claude Code, Codex,
opencode, …) reads from and writes to — the root source of truth for agent
memory on this machine. Write a fact once; every agent and session uses it.

## Design

Simple and hackable (Zettelkasten-style): plain markdown, no database (agents
`grep` it); **atomic notes** (one fact per file); **index-first** (`MEMORY.md`
loaded before anything else); **linked** via `[[wikilinks]]` + `tags` (browsable
as a graph in Obsidian, or `kb viz` for a standalone viewer); **self-healing**
via the `DREAM.md` consolidation pass.

## Structure

```
.
├── AGENTS.md      ← canonical protocol for ALL agents (read/write/dream rules)
├── CLAUDE.md      ← thin pointer to AGENTS.md
├── DREAM.md       ← memory-consolidation ("dream") protocol
├── MEMORY.md      ← master index, one line per note — load first
├── raw/           ← capture inbox (raw/inbox/<date>.md) + ground-truth sources
├── memory/        ← the OKF v0.1 bundle: notes nested under <group>/…
│   ├── index.md   ← generated OKF listing (okf_version: "0.1") — run `kb gen`
│   ├── log.md     ← generated change history (newest-first)
│   ├── _TEMPLATE.md  ← the note standard
│   └── user/ feedback/ reference/ projects/ topics/  ← starter groups; nest freely
├── scripts/       ← kb CLI internals: lint / sync / wire / render_okf_viewer.py
├── bin/kb         ← the `kb` CLI
├── viz.html       ← generated self-contained graph viewer — run `kb viz`
└── .agent/        ← state.json (ingested files + tasks)
```

This repo **is a conformant [OKF v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) bundle** — `memory/` is the bundle root; each concept is one `.md` carrying `type` (an OKF custom field). `index.md`/`log.md`/`viz.html` are generated; re-run `kb gen` (or `kb viz` to also open the viewer) after writing notes.

Every note follows `memory/_TEMPLATE.md` and must pass `kb lint`. Format spec in
`AGENTS.md`.

## How it works

- **Read in:** `kb index` (= `MEMORY.md`), open the relevant notes; fetch a note's
  `sources:` (`llms.txt`) for deeper detail.
- **Write out:** unsure it's durable → `kb capture "note"` (lands in `raw/inbox/`);
  known keeper → a standard note in `memory/<group>/…`. Then
  `kb lint && kb gen` (regenerate the OKF `index.md`/`viz.html`), and
  `kb sync` if this repo has a git remote.
- **Dream:** periodically (or `/loop`) run `DREAM.md` — it ingests the inbox + raw
  sources into clean notes, dedupes, refreshes stale notes from `sources:`, rebuilds
  the index, and syncs.

## Put this KB on PATH

```bash
export PATH="<this-directory>/bin:$PATH"     # add to ~/.zshrc or ~/.bashrc
```

## Wire the reflex into your agents (optional)

`scripts/wire.sh on` adds a small, removable, marked block to each installed
agent's global instruction file (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`,
`~/.config/opencode/AGENTS.md` — only the ones that already exist) so every new
session reads `MEMORY.md` on start and knows how to capture/write notes. Remove
it any time with `scripts/wire.sh off`; it touches nothing else in those files.

## Version control (optional but recommended)

```bash
git init
git remote add origin <your-git-remote>   # e.g. a private repo for personal notes
```

If you make this repo **public**, keep only general, durable, public-facing
knowledge in it — see `AGENTS.md` §3 for what must never be committed.

## CLI

```bash
kb capture "rough note"   # → raw/inbox/<today>.md
kb ingest <file>          # add a source doc to raw/
kb index | kb lint | kb sync | kb dream | kb root
kb gen | kb viz           # regenerate (and open) the OKF index.md files + viz.html
kb wire on|off            # add/remove the reflex block in agents' global config
kb autosync on|off|status # opt-in */15min sync cron (requires a git remote)
```

## Scope

If this repo is public: general, durable, public-facing knowledge only.
**Never** here: secrets, SSH hosts, internal/employer-confidential details,
anything private — keep those in a private repo or the agent's local memory.
