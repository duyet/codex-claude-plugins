---
description: Scaffold a new shared-brain knowledge base folder (default ~/kb) — OKF v0.1-conformant, with a graph viewer and its own CLI, vendored and self-contained.
---

# /init

Scaffold a new shared-brain kb folder: memory protocol (`AGENTS.md`/`CLAUDE.md`/
`DREAM.md`/`MEMORY.md`), an OKF v0.1 `memory/` bundle, a capture inbox
(`raw/inbox/`), and a self-contained CLI (`bin/kb`, `scripts/`). Delegate to the
`init` skill for the full scaffold. Idempotent — never overwrites existing files.

## Arguments

- `path`: target directory (optional; defaults to `$KB_DIR` or `~/kb`)

Pass the rest of the line as `$ARGUMENTS`. Examples: `/init`, `/init ~/kb`,
`/init ./team-kb`.

## Workflow

1. Resolve the target path from `$ARGUMENTS`, `$KB_DIR`, or the default `~/kb`;
   confirm with the user if ambiguous.
2. Invoke the `init` skill and follow its steps exactly.
3. Report files created vs. skipped (pre-existing).
4. Offer PATH export, `git init`, and `scripts/wire.sh on` as separate,
   confirm-first follow-ups — never run them without asking, since wiring
   edits global agent config outside the scaffolded folder.

## Guardrails

- Never overwrite a file that already exists in the target.
- Never touch anything outside the target folder without explicit confirmation.
- Never invent personal facts to seed `memory/` with — leave it for the user.
- Keep this command thin — all scaffolding logic lives in the `init` skill.
