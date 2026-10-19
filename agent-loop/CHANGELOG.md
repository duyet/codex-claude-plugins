# Changelog

## Unreleased

- Repetition now uses the harness scheduler (Claude Code `/loop`, or the Codex and Cursor equivalents) instead of a shell `sleep`.
- The state file is defined once, in the `agent-loop-orchestrator` skill. All state commands point to it.
- `/agent-loop:resume` refuses to restart a stopped loop. Use `/agent-loop:start --resume`.
- Removed duplicate flat skill files under `skills/`.

## 0.4.0 (2026-06-14)

- Added `/agent-loop:inspect`, `/agent-loop:reset`, and `/agent-loop:restore`.
- `/agent-loop:start` detects saved state and offers to resume.
- Timestamped state backups in `.agent-loop/backups/`.

## 0.3.0 (2026-06-11)

- Added `/agent-loop:resume` and `/agent-loop:status`.

## 0.1.0 (2026-06-09)

- First release with orchestrator, triage, autoreview, and browser skills.
