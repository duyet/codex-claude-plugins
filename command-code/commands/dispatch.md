---
description: Dispatch one or more headless Command Code (`cmd`) workers to implement well-scoped tasks or GitHub issues in parallel — each in its own git worktree, running `cmd -p --yolo --max-turns 100000`, committed to its own branch for review.
---

# /command-code:dispatch

Fan out implementation work to the **Command Code CLI (`cmd`)** running headlessly as sub-agents. Read the `command-code` skill first — it has the invocation contract, the worktree workflow, and the safety rules.

The user's request (issues, tasks, or a description) is: **$ARGUMENTS**

## Step 0 — Preconditions

- Confirm `cmd` is installed and authenticated: `which cmd && cmd status`. If not authenticated, tell the user to run `cmd login` and stop.
- Confirm you're in a git repo with a clean base branch. Note the base branch (usually `main`).
- **Get explicit consent for `--yolo`.** These workers run unsupervised with no permission gate. State that plainly and confirm the user wants autonomous background dispatch. If the host blocks the launch, surface it and let the user decide — do not try to bypass.

## Step 1 — Resolve the work-list

Turn `$ARGUMENTS` into a concrete list of independent units of work:
- GitHub issue numbers → one worker per issue (each will `gh issue view <N>`).
- A larger task → decompose into independent, separately-committable pieces. If pieces have dependencies, dispatch only the independent ones now and note the rest as follow-ups.
- If the work isn't cleanly separable or is too small to be worth a handoff, say so and offer to just do it inline instead.

## Step 2 — Write a self-contained spec per worker

`cmd` shares none of this conversation's context. For each unit, write a prompt that stands alone (see the skill's "Write a self-contained spec"): what & why, exact file seams with paths/line numbers and the pattern to copy, scope in/out, style rules, `do not run pnpm install or any build`, the exact conventional-commit message, `do not push`, and a closing `print a summary of files changed + deviations`.

## Step 3 — Isolate + launch

One worktree + branch per worker; launch each in the background with the mandatory flags:

```bash
BASE=<a worktrees dir outside the main tree>
git worktree add -b feat/<slug> "$BASE/<slug>" <base-branch>
( cd "$BASE/<slug>" && \
  cmd -p "<spec>" --yolo --max-turns 100000 --skip-onboarding > "$BASE/<slug>.log" 2>&1 ) &
```

`--yolo --max-turns 100000 --skip-onboarding` is non-negotiable — without them the headless task hangs or exits code 8 mid-run. Never run two workers in the same directory.

## Step 4 — Track, then review

- Report the launched workers (slug → branch → worktree → log path). Let them run in the background; you'll be notified as each finishes.
- On completion, review each branch (`git -C <wt> log/diff --stat <base>..HEAD`) and read the diff — don't trust the log alone. Note anyone that exited code 8 (unfinished) and offer to resume it with `cmd -c`.

## Step 5 — Verify once, after collecting branches

Do NOT build inside the parallel workers. After the branches are ready, bring them into one tree and run a single consolidated typecheck/test pass, then report per-branch status (clean / needs-fix) so the user can decide what to merge. Nothing is pushed or merged without the user's say-so.
