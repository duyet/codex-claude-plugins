---
name: init
description: Scaffold a new shared-brain knowledge base folder (default ~/kb), a plain-markdown OKF v0.1 memory store any coding agent can read and write. Use when the user asks to set up or bootstrap a kb, shared brain, or persistent agent memory folder.
---

# init

Creates a self-contained folder with no database and no server.

- Protocol files: `AGENTS.md` (read and write rules), `CLAUDE.md` (pointer), `DREAM.md` (consolidation pass), `MEMORY.md` (index).
- `memory/`, an OKF v0.1 bundle with starter groups.
- `raw/inbox/` for quick captures and `raw/` for immutable sources.
- A vendored CLI in `bin/kb` and `scripts/`, so the folder works without this plugin. It includes the graph viewer renderer, `lint.sh`, `sync.sh`, and `wire.sh`.

The scaffold ships no memory content, git remote, or branding.

If a kb already exists at the target, check whether the user wants the `dream` skill instead.

## Steps

1. Resolve the target: a path the user gave, else `$KB_DIR`, else `$HOME/kb`. Confirm if ambiguous.
2. Run `scripts/scaffold.sh <absolute-target>` from this skill's directory. It does not expand `~`. It creates only files that do not exist, makes scripts executable, and ends by rendering `memory/index.md` and `viz.html`.
3. Report how many files were created and how many were skipped.
4. Offer these follow-ups separately and run none without a yes.
   - Add `export PATH="<target>/bin:$PATH"` to the shell rc.
   - `git init`, plus `git remote add origin <url>` if the user has one.
   - `<target>/scripts/wire.sh on`. It edits global agent config files outside the folder (`~/.claude/CLAUDE.md`, plus `~/.codex/AGENTS.md` and `~/.config/opencode/AGENTS.md` when present) so every future session reads the kb. `wire.sh off` reverses it. Explain this before asking.
5. Do not invent personal facts to seed `memory/`. Leave it empty or ask what to record.

## Afterwards

- The note format is `memory/_TEMPLATE.md` and the full protocol is `AGENTS.md`.
- Use the `dream` skill to consolidate notes and the `okf` plugin for custom concept types and conformance checks.
- `kb viz` opens the graph viewer.
