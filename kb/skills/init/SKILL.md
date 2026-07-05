---
name: init
description: Scaffold a new shared-brain knowledge base folder (default ~/kb) — a plain-markdown, OKF v0.1-conformant memory store that any coding agent can read/write across sessions. Use when the user asks to set up, init, or bootstrap a kb / shared brain / persistent agent memory folder, or wants an OKF bundle with a graph viewer ready out of the box.
---

# init — scaffold a shared-brain kb folder

## What this creates

A self-contained directory — plain markdown, no database, no server — that is:

- **A memory protocol.** `AGENTS.md` (the full read/write/dream rules), `CLAUDE.md`
  (thin pointer for Claude Code), `DREAM.md` (the consolidation pass), `MEMORY.md`
  (the index every agent reads first).
- **An OKF v0.1 bundle.** `memory/` is the bundle root; every note is one `.md`
  file with a `type` in frontmatter. Conforms to
  [OKF v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
  — see the companion **okf** skill/plugin for deeper bundle authoring and
  validation.
- **A capture inbox.** `raw/inbox/` for low-ceremony daily notes; `raw/` for
  immutable source docs.
- **Its own CLI and tooling**, vendored into `scripts/`/`bin/` so the folder
  keeps working even if this Claude plugin is later removed: `bin/kb`
  (capture/lint/sync/gen/viz/wire), `scripts/render_okf_viewer.py` (regenerates
  `memory/**/index.md` + a self-contained `viz.html` graph viewer), `scripts/
lint.sh`, `scripts/sync.sh`, `scripts/wire.sh`.

This is the generic, brand-neutral form of a personal "shared brain" pattern —
it ships with no memory content, no assumed git remote, and no personal
branding. Everything it writes is a template for the user to fill in.

## When to use

- "set up a kb / shared brain / persistent memory folder for me"
- "init ~/kb" or "bootstrap my knowledge base"
- The user wants cross-session, cross-agent memory but has none yet.

If a kb already exists at the target (has `AGENTS.md` or `memory/`), this skill
is still safe to run — see Idempotency below — but check first whether the user
actually wants `dream` (consolidate existing notes) instead of `init`.

## Steps

1. **Resolve the target path.** Default `$HOME/kb`. Use `$KB_DIR` if set, or a
   path the user gave explicitly. Confirm the path with the user if ambiguous.
2. **Scaffold.** Run the bundled script with an absolute path (it does not
   expand `~`):

   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/skills/init/scripts/scaffold.sh" "$HOME/kb"
   ```

   It is idempotent — creates missing files, chmods scripts executable, seeds
   starter `memory/{user,feedback,reference,projects,topics}/` groups, and
   **never overwrites a file that already exists** in the target. It ends by
   running `render_okf_viewer.py` once so `memory/index.md` and `viz.html`
   exist immediately.

3. **Report what happened**: how many files were created vs. skipped
   (pre-existing), and the target path.
4. **Offer, but do not run automatically, three follow-ups** — each changes
   something outside the new folder or is otherwise consequential, so ask
   first:
   - **PATH.** Suggest adding `export PATH="<target>/bin:$PATH"` to the user's
     shell rc. Don't edit their `.zshrc`/`.bashrc` yourself unless they ask.
   - **Version control.** Offer `git init` (and `git remote add origin <url>`
     if they have one). Skip silently if they don't want git.
   - **Wiring.** `<target>/scripts/wire.sh on` adds a small marked block to
     `~/.claude/CLAUDE.md` (and `~/.codex/AGENTS.md` / `~/.config/opencode/
AGENTS.md` if those tools are present) so every future session
     auto-reads the kb. This edits files **outside** the scaffolded folder and
     affects every future session — explain what it does and get explicit
     confirmation before running it. `wire.sh off` cleanly reverses it.
5. **If the user wants example notes**, don't invent personal facts — either
   leave `memory/` empty for them to fill in via `kb capture`, or ask what to
   record.

## After scaffolding

- Point to `memory/_TEMPLATE.md` for the note format and `AGENTS.md` for the
  full protocol — both are self-documenting inside the new folder.
- For ongoing maintenance (merge duplicates, prune stale notes, rebuild the
  index), use this plugin's **dream** skill against the new kb.
- For richer OKF authoring/validation beyond what `bin/kb gen` covers (custom
  concept types, `validate_okf.py` conformance checks), use the **okf** plugin.
- `kb viz` (or `bin/kb viz` before `PATH` is set) opens the graph viewer any
  time after notes are added.

## Idempotency & safety

- `scaffold.sh` only ever creates files that don't already exist — re-running
  it against a partially-set-up or already-populated kb is safe and adds
  nothing to files it finds present.
- It never touches anything outside `<target>` — no global config, no shell
  rc, no git remote. Those are the explicit, confirm-first follow-ups above.
- It writes no personal data — the scaffolded files are generic templates.

## Checklist

- [ ] Resolved target path (arg, `$KB_DIR`, or confirmed default `~/kb`).
- [ ] Ran `scaffold.sh` with an absolute path; reported created vs. skipped files.
- [ ] `memory/index.md` and `viz.html` exist (scaffold.sh generates them).
- [ ] Offered PATH / git init / wire as separate, confirm-first steps — did not
      edit anything outside the target folder without asking.
- [ ] Did not invent personal facts to seed `memory/` with.
