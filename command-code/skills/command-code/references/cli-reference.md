# Command Code (`cmd`) — Full CLI Reference

Reference for `cmd` v0.44.x. Read this when you need a flag, sub-command, slash command, or exit code that isn't in `SKILL.md`. Verify against `cmd --help` if behavior looks different — the CLI evolves.

## Invocation forms

| Form | Meaning |
|---|---|
| `cmd` | Start an interactive session (REPL). |
| `cmd "message"` | Start interactive, seeded with an initial message. |
| `cmd -p "query"` / `cmd --print "query"` | **Non-interactive / headless**: run the query, print the response, exit. The basis of all scripting and background dispatch. |

## Options

| Flag | Description |
|---|---|
| `-r, --resume [name]` | Resume a conversation by id or name (quote multi-word names), or pick from history if omitted. |
| `-c, --continue` | Continue the last conversation. |
| `--fork-session` | With `--resume`/`--continue`, fork into a new session; the original is left untouched. |
| `-t, --trust` | Auto-trust the project (skip the one-time "trust the files in this folder?" prompt). Per project directory. |
| `-p, --print [query]` | Non-interactive mode: output response and exit. |
| `--max-turns <number>` | Cap conversation turns in `-p` mode. **Default 10. Exits with code 8 when the cap is hit.** For real implementation work set this very high (e.g. `100000`) so the task finishes on completion, not on the cap. |
| `-m, --model <model>` | Run this session on a specific model. |
| `--list-models` | List available models and exit. |
| `--plan` | Start in plan mode (agent plans, doesn't edit, until you approve). |
| `--permission-mode <mode>` | `standard` \| `plan` \| `auto-accept`. |
| `--auto-accept` | Start in auto-accept mode (auto-accepts edits; softer than `--yolo`). |
| `--yolo` | Bypass ALL permission prompts. Alias for `--dangerously-skip-permissions`. **Required for unattended/background runs** — otherwise the first action prompt blocks forever. |
| `--add-dir <directory>` | Add a directory to the workspace context. |
| `--skip-onboarding` | Skip taste onboarding (required for clean automated/headless runs). |
| `--ide-setup` | Connect an IDE to share the open file and selected lines. |
| `-v, --version` | Print the version. |
| `-h, --help` | Show help. |

## The mandatory headless combination

```bash
cmd -p "<prompt>" --yolo --max-turns 100000 --skip-onboarding
```

If ANY of these is missing, an unattended run breaks:
- no `-p` → it opens a REPL and waits for a human.
- no `--yolo` → it hangs on the first permission prompt (can't run bash / edit files).
- low/default `--max-turns` → it exits code 8 partway through, leaving a half-finished branch.
- no `--skip-onboarding` → a fresh install blocks on the taste-onboarding demo.

## Sub-commands

| Command | Purpose |
|---|---|
| `cmd info` | Display system information. |
| `cmd status` | Show authentication status. Run before a headless fleet to confirm auth. |
| `cmd whoami` | Show the current user. |
| `cmd update` | Update `cmd` to the latest version. |
| `cmd feedback [title]` | Share feedback / report a bug. |
| `cmd taste` | Manage taste-learning packages. |
| `cmd taste learn <source>` | Learn taste from a local repo path or a GitHub repo. |
| `cmd learn-taste` | Learn command structure / taste from existing Claude Code / Codex sessions. |
| `cmd mcp` | Manage MCP (Model Context Protocol) servers. |
| `cmd skills` | Manage skills from GitHub repositories. |
| `cmd login` | Log in with a Command Code account. |
| `cmd logout` | Log out. |

## Slash commands (inside an interactive session)

| Slash | Purpose |
|---|---|
| `/init` | Initialize an `AGENTS.md` for this project. |
| `/goal [<objective>\|clear\|status]` | Set/clear/inspect a standing objective the agent works toward. |
| `/memory` | Manage Command Code memory. |
| `/resume` | Resume a past conversation. |
| `/fork [name]` | Fork the conversation into a new session. |
| `/rename [name]` | Rename the current session. |

## Exit codes

| Code | Meaning |
|---|---|
| `0` | Success. |
| `8` | `--max-turns` cap hit in `-p` mode (task likely unfinished). Treat as "increase the cap and/or resume", not "done". |
| non-zero (other) | Error — read the captured log. |

## Auth & personalization notes

- Auth is via `cmd login`; `cmd status` verifies. A whole headless fleet fails identically if auth is missing — check first.
- **Taste** is `cmd`'s differentiator: it learns how the user writes code and applies it automatically. For a taste-sensitive repo, `cmd taste learn <repo>` once up front makes dispatched workers match house style.
- `--add-dir` widens context when the task needs files outside the current tree (e.g. a shared package in a monorepo you didn't cd into).

## Resuming a capped or interrupted run

If a run exits 8 (or you interrupted it), resume in the same worktree instead of restarting from scratch:

```bash
cd <worktree>
cmd -c -p "continue; finish the remaining acceptance criteria, then commit" --yolo --max-turns 100000 --skip-onboarding
```

`-c` continues the last conversation in that directory, preserving its context.
