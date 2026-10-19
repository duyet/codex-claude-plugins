---
name: command-code
description: Run the Command Code CLI (`cmd`) and dispatch it as a headless sub-agent on well-scoped tasks or GitHub issues. Use when the user mentions cmd or Command Code, asks to spawn or dispatch cmd, or when you are about to launch `cmd -p` and need the correct flags.
---

# Command Code (`cmd`)

Run `cmd --help` for flags. This skill holds the dispatch rules that `/command-code:dispatch` and `cmd-dispatcher` follow.

Unattended invocation needs all of: `cmd -p "<self-contained prompt>" --yolo --max-turns 100000 --skip-onboarding`. Without `-p` it opens a REPL. Without `--yolo` it hangs on the first permission prompt. The default turn cap is 10 and exit code 8 means it hit the cap with a half-done branch. `--skip-onboarding` stops the taste demo blocking.

Dispatch only independent, well-specified work. Do small, exploratory, or back-and-forth work yourself.

- Run `cmd status` first and stop if unauthenticated. Get the user's explicit consent for `--yolo`. If the host blocks the launch, surface it and ask.
- One git worktree and branch per worker. Never two workers in one directory.
- `cmd` shares none of your context, so the prompt is the whole brief: what and why, exact `path:line` seams and the pattern to copy, scope in and out, "do not run install or a full build", the exact conventional-commit message, "do not push", and "print files changed and deviations at the end". For an issue also say to run `gh issue view <N>`.
- Launch in the background with one log per worker.
- Review each diff yourself, not just the log. Verify once after merging branches into one tree, since concurrent builds across worktrees run out of memory.
- On exit code 8 prefer a fresh narrowly scoped `cmd -p` over `cmd -c -p`, which reloads the whole conversation.
- Push and merge nothing without the user's approval. Never put secrets in a prompt.
