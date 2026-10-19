---
name: command-code
description: Run the Command Code CLI (`cmd`) and dispatch it as a headless sub-agent on well-scoped tasks or GitHub issues. Use when the user mentions cmd or Command Code, asks to spawn or dispatch cmd, or when you are about to launch `cmd -p` and need the correct flags.
---

# Command Code (`cmd`)

`cmd` is a standalone terminal coding agent with its own model access, permissions, sessions, MCP support, and a "taste" layer that learns how the user writes code. Its best use here is as a headless sub-agent: you write a precise spec, give it an isolated worktree, and it implements, tests, and commits while you do other work. Run `cmd --help` for flags and subcommands.

This skill is the single home for the dispatch rules. `/command-code:dispatch` and the `cmd-dispatcher` agent follow it.

## Headless invocation

```bash
cmd -p "<self-contained prompt>" --yolo --max-turns 100000 --skip-onboarding
```

Every flag is required for unattended runs.

- `-p` runs once and exits. Without it `cmd` opens a REPL and waits for a human.
- `--yolo` skips every permission prompt. A headless run cannot answer them and hangs on the first action without it.
- `--max-turns 100000` removes the cap. The default is 10, and `cmd` exits with code 8 at the cap, leaving a half-done branch.
- `--skip-onboarding` stops the taste demo from blocking a fresh run.

## When to dispatch

Dispatch when the user asks for it, or when there is independent work (several issues or packages) that can each be handed off with a clear spec. Do it yourself when the task is small, exploratory, needs back-and-forth, or cannot yet be specified, because the handoff costs more than the work.

## Dispatch workflow

1. **Preconditions.** Run `cmd status` and stop if unauthenticated, since every worker would fail the same way. Get the user's explicit consent for `--yolo`, as workers run with no approval gate. If the host blocks the launch, surface it and ask. Do not work around it.
2. **Isolate.** One git worktree and branch per worker: `git worktree add -b feat/<slug> <dir> <base>`. Never run two workers in one directory, because they corrupt each other's edits and index.
3. **Write the spec.** `cmd` shares none of your context, so the prompt is the whole brief. Include:
   - What and why, in a sentence or two.
   - Exact file seams (`path:line`) and the pattern to copy. This is the biggest quality lever.
   - Scope in and out, and style rules (match the repo, do not reformat unrelated code).
   - "Do not run install or any full build."
   - The exact conventional-commit message and "do not push".
   - "Print a summary of files changed and deviations at the end."

   For a GitHub issue, tell it to run `gh issue view <N>`, and still restate seams and constraints.
4. **Launch in the background**, one log per worker.

   ```bash
   ( cd <dir> && cmd -p "<spec>" --yolo --max-turns 100000 --skip-onboarding > <dir>.log 2>&1 ) &
   ```

5. **Review.** When a worker finishes, read `git -C <dir> log --oneline <base>..HEAD` and `git diff --stat <base>..HEAD`, then the diff. Do not trust the log alone.
6. **Verify once.** Concurrent builds across worktrees cause out-of-memory failures, so run one typecheck and test pass after merging the branches into a single tree.
7. **Resume if needed.** Exit code 8 means unfinished. Prefer a fresh narrowly scoped `cmd -p` naming only the remaining work. `cmd -c -p "..."` reloads the whole prior conversation and can overflow context on a large session, so use it only for short ones.

Nothing is pushed or merged without the user's approval. Treat `--yolo` as moving the approval gate to review time, and never put secrets in a prompt.

## Taste and auth

- `cmd taste learn <repo>` learns house style from a repo. Run it once before dispatching into a taste-sensitive codebase.
- `cmd login` and `cmd status` handle auth. `/goal "<objective>"` inside a session sets a standing objective.
