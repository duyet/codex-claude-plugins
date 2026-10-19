---
name: init
description: Scaffold a new shared-brain knowledge base folder (default ~/kb), a plain-markdown OKF v0.1 memory store any coding agent can read and write. Use when the user asks to set up or bootstrap a kb, shared brain, or persistent agent memory folder.
---

# init

Creates a self-contained folder: `AGENTS.md`, `CLAUDE.md`, `DREAM.md`, `MEMORY.md`, an OKF v0.1 `memory/` bundle, `raw/inbox/`, and a vendored CLI (`bin/kb`, `scripts/`) that works without this plugin. It ships no memory content or git remote. If a kb already exists at the target, consider `dream` instead.

1. Target: user path, else `$KB_DIR`, else `$HOME/kb`.
2. Run `scripts/scaffold.sh <absolute-target>` from this skill's directory. It does not expand `~` and never overwrites existing files.
3. Report files created and skipped.
4. Offer separately, and run none without a yes: add `<target>/bin` to PATH, `git init`, and `<target>/scripts/wire.sh on`. Explain that `wire.sh on` edits global agent config files outside the folder, and `off` reverses it.
5. Do not invent personal facts to seed `memory/`.

Note format: `memory/_TEMPLATE.md`. Protocol: `AGENTS.md`. Custom concept types and conformance: the `okf` plugin.
