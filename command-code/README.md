# command-code

Drive the **Command Code CLI (`cmd`)** from Claude Code — and orchestrate it as a **headless sub-agent** to implement work in parallel.

`cmd` (Command Code) is a standalone terminal coding agent that continuously learns your taste of writing code. This plugin teaches Claude how to run it correctly, and how to fan it out across isolated git worktrees so several `cmd` workers implement independent tasks (or GitHub issues) at once.

## What's inside

| Component | What it does |
|---|---|
| **Skill** `command-code` | The full contract for running `cmd`: the mandatory headless invocation, the worktree dispatch workflow, taste/MCP/skills, and safety rules. Auto-triggers on "cmd", "Command Code", "dispatch cmd", etc. |
| **Reference** `references/cli-reference.md` | Complete flag list, sub-commands, slash commands, and exit codes. |
| **Command** `/command-code:dispatch` | Guided fan-out: turn issues/tasks into isolated `cmd` workers, launch, track, review. |
| **Agent** `cmd-dispatcher` | Sub-agent that orchestrates the whole dispatch loop end to end. |

## The one rule to remember

For any unattended / background run, always:

```bash
cmd -p "<detailed self-contained prompt>" --yolo --max-turns 100000 --skip-onboarding
```

Miss any of these and the headless task **breaks**:
- no `-p` → opens a REPL and waits for a human
- no `--yolo` → hangs on the first permission prompt
- default `--max-turns` (10) → exits code 8 mid-implementation
- no `--skip-onboarding` → blocks on the taste-onboarding demo

## Dispatch pattern

1. One git worktree + branch per worker (never two `cmd` runs in one dir).
2. A self-contained spec as the prompt — `cmd` shares none of your context; give it exact file seams, scope, style, and the commit message.
3. Launch in the background, capture a per-worker log.
4. Tell workers **not** to build; verify once after collecting branches (parallel builds OOM).
5. Review each diff; nothing is pushed or merged without your approval.

## Safety

`--yolo` runs an autonomous agent loop with no approval gate. Only launch with the user's explicit consent, always in a dedicated worktree on a branch (never straight onto `main`), with "do not push" in the prompt. You are the approval gate — moved to diff-review time.

## Requirements

- `cmd` installed and authenticated (`cmd login`; verify with `cmd status`).
- `git` (for worktree isolation), and `gh` if dispatching over GitHub issues.
