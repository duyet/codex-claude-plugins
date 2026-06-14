# Changelog

All notable changes to the agent-loop plugin are documented here.

## [0.4.0] — 2026-06-14

### Added

**State Management & Recovery**
- ✨ Auto-detection of existing `.agent-loop/state.json` on startup — `/agent-loop:start` now checks for saved state and prompts to resume or start fresh
- ✨ `/agent-loop:inspect` command — deep inspection of state file, view cycle history, thread details, errors, and state integrity
- ✨ `/agent-loop:reset` command — clear state and start fresh, with automatic backup of old state to `.agent-loop/backups/`
- ✨ `/agent-loop:restore` command — recover state from timestamped backups
- ✨ State validation and corruption detection — automatic checks when loading state.json
- ✨ Backup system with timestamped files — automatic backups on reset or fresh start

**Enhanced Commands**
- 📝 Improved `/agent-loop:start` to auto-detect and prompt for resume vs. fresh (can force with `--fresh` or `--resume`)
- 📝 Enhanced `/agent-loop:resume` documentation with recovery details and state restoration info
- 📝 Updated `/agent-loop:status` to show when resuming from backed-up state

**Documentation**
- 📖 Enhanced orchestrator skill with state validation, recovery procedures, and backup system details
- 📖 Added "State Management & Recovery" section to README with recovery scenarios
- 📖 Updated README with organized command reference (Loop Control, State Management, One-Shot Operations)
- 📖 Comprehensive guides for all new commands with examples and recovery workflows

### Changed

- 🔄 Plugin version bumped from 0.3.0 to 0.4.0 (across all manifests: `.claude-plugin`, `.codex-plugin`, `.antigravity-plugin`)
- 🔄 State file schema now includes `version` and `state_valid` fields for better corruption detection
- 🔄 Updated descriptions in all manifests to mention "Auto-detects and resumes from saved state"

### Technical

- 🔧 State schema v0.4.0 with enhanced validation fields
- 🔧 Backup directory: `.agent-loop/backups/state-YYYY-MM-DD-HHmmss.json`
- 🔧 Enhanced environment variable: `AGENT_LOOP_BACKUP_DIR` (default: `.agent-loop/backups`)
- 🔧 State integrity checks: JSON validity, required fields, type safety, orphaned threads, metric consistency

### Why These Changes?

The agent-loop plugin previously required manual state management. Users had to explicitly remember to resume with `/agent-loop:resume` after interruptions, and there was no built-in recovery from state corruption or accidental resets.

**v0.4.0 improvements:**
1. **Smarter startup** — Auto-detect saved state and offer to resume (no more lost context)
2. **Better debugging** — Inspect command lets users understand their loop state deeply
3. **Safe reset** — Automatic backups mean resets are never destructive
4. **Full recovery** — Restore from backups for corruption or accidents
5. **Validated state** — Automatic corruption detection prevents silent failures

## [0.3.0] — 2026-06-11

### Added

- Antigravity manifest and commands
- Resume command for loop restoration
- State persistence documentation

### Changed

- Version bumped to 0.3.0

## [0.2.0] — 2026-06-10

### Added

- Agent loop orchestrator skill
- Triage, autoreview, and browser skills
- Core commands: start, stop, status

## [0.1.0] — 2026-06-09

### Added

- Initial agent-loop plugin structure
- Basic CLI commands and skills
