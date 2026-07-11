---
name: command-code
description: Drive the Command Code CLI (`cmd`) — a terminal coding agent that learns your taste — and orchestrate it as a headless sub-agent. Use this skill whenever the user mentions "cmd", "Command Code", "commandcode", asks to "spawn cmd", "dispatch cmd", "use cmd as a subagent", run coding work headlessly/unattended, fan out implementation across GitHub issues or tasks with cmd, learn/manage taste, or set up `cmd` MCP/skills/auth. Also use it whenever you are about to launch `cmd` in print/headless mode and need the correct flags (always `--yolo --max-turns 100000 --skip-onboarding`).
---

# Command Code (`cmd`)

`cmd` (Command Code) is a standalone terminal coding agent — a sibling to Claude Code / Codex — that **continuously learns the user's taste of writing code**. It has its own model access, permission system, session store, MCP support, and a "taste" personalization layer. This skill teaches you to (a) run it interactively, and (b) drive it **headlessly as a sub-agent** to implement work in parallel.

The high-value use is the second one: `cmd` is excellent at being *dispatched* — you write a precise spec, hand it an isolated worktree, and let it implement, test, and commit autonomously while you do other work.

## The one invocation to memorize

For any unattended / headless / background dispatch, ALWAYS use:

```bash
cmd -p "<detailed self-contained prompt>" --yolo --max-turns 100000 --skip-onboarding
```

- **`-p/--print`** runs non-interactive: `cmd` executes the prompt and exits (no REPL). Required for scripting/background.
- **`--yolo`** bypasses every permission prompt (alias for `--dangerously-skip-permissions`). A headless `cmd` **cannot answer prompts** — without this it will hang forever the first time it wants to run a command or edit a file. This is mandatory for background runs.
- **`--max-turns 100000`** effectively removes the turn cap. The default is only **10**, and `cmd` **exits with code 8** the moment it hits the cap — mid-implementation, leaving a half-done branch. Real implementation tasks need many turns; set it absurdly high so the task finishes on its own merits, not on an arbitrary limit.
- **`--skip-onboarding`** skips the interactive taste-onboarding demo, which would otherwise block a fresh headless run.

`--yolo` is powerful and unsupervised. See [Safety & consent](#safety--consent) — you must have the user's go-ahead and you must isolate the work.

## When to reach for `cmd` vs. doing it yourself

Use `cmd` as a sub-agent when:
- The user explicitly asks to "spawn/dispatch/use cmd".
- There is **independent, parallelizable** implementation work (e.g. several GitHub issues, several packages) that can each be handed off with a clear spec and acceptance criteria.
- You want a second, taste-personalized implementer to take a well-scoped task off your plate while you keep orchestrating.

Do it yourself (don't dispatch) when the task is small, exploratory, needs tight back-and-forth, or isn't cleanly specifiable yet — the cost of writing a full handoff spec exceeds just doing it.

## Dispatching `cmd` as a headless sub-agent

This is the core workflow. Follow it exactly; each step exists to prevent a real failure mode.

### 1. Isolate the work in a git worktree

Never run two headless `cmd` sessions in the same working directory — they will clobber each other's edits and git index. Give each its own worktree on its own branch:

```bash
git worktree add -b feat/<slug> /path/to/wt/<slug> <base-branch>
```

One worktree per parallel task. Serial tasks in the same repo can reuse the main tree, but isolation is cheap insurance.

### 2. Write a self-contained spec as the prompt

`cmd` starts fresh — it does **not** share your conversation context. The prompt is the entire brief. A good dispatch prompt contains:
- **What & why** in one or two sentences.
- **Exact file seams** — paths and line numbers to read first (`packages/x/src/y.ts:120`), and the pattern to copy from. This is the single biggest quality lever; `cmd` implements far better against concrete anchors than against prose.
- **Scope boundaries** — what's in and explicitly what's out ("stub the gateway; adapter + tests only").
- **Style rules** — match the repo (indent, quotes, imports); tell it *not* to reformat unrelated code.
- **Build/test policy** — see [Don't let parallel workers build](#dont-let-parallel-workers-build).
- **Commit instructions** — exact conventional-commit message; "do not push".
- **A closing "print a summary of files changed + deviations"** so the log ends with something reviewable.

If the work is a GitHub issue, tell `cmd` to `gh issue view <N>` itself and follow it — but still restate the seams and constraints in the prompt; don't assume the issue body is enough.

### 3. Launch in the background, capture the log

```bash
cd /path/to/wt/<slug>
cmd -p "<spec>" --yolo --max-turns 100000 --skip-onboarding > /path/to/wt/<slug>.log 2>&1
```

Run it as a background process so several `cmd` workers proceed concurrently. Redirect to a per-task log file you can tail for progress and read on completion.

### 4. Review the branch, then verify — after merge, not during

When a worker finishes, inspect its branch, don't trust the log alone:

```bash
git -C /path/to/wt/<slug> log --oneline <base>..HEAD
git -C /path/to/wt/<slug> diff --stat <base>..HEAD
```

Read the diff. Then run the consolidated typecheck/test **once**, after collecting the branches — see below.

### Don't let parallel workers build

Concurrent `pnpm build` / `bun build` across several worktrees causes OOM and thrashing. In every dispatch prompt, tell `cmd`: **do not run `pnpm install` or any full build; writing correct code + tests is sufficient.** Verify once, yourself, after merging the branches into a single tree. This is the same discipline you'd apply to any parallel sub-agent fleet.

## Interactive & other modes

`cmd` is also a normal interactive agent. Common forms:

| Goal | Command |
|---|---|
| Start a REPL session | `cmd` |
| Start with a first message | `cmd "refactor the auth module"` |
| One-shot answer, then exit | `cmd -p "explain apps/main/src/auth.ts"` |
| Resume last conversation | `cmd -c` / `cmd --continue` (⚠️ can overflow context on a *large* prior session — for a small leftover task prefer a fresh scoped `cmd -p`; see `references/cli-reference.md`) |
| Resume a named conversation | `cmd -r "<name>"` |
| Fork a session (leave original untouched) | `cmd --resume <id> --fork-session` |
| Plan first, don't edit | `cmd --plan` or `--permission-mode plan` |
| Auto-accept edits but keep some gates | `cmd --auto-accept` / `--permission-mode auto-accept` |
| Pick the model | `cmd -m <model>` (`cmd --list-models` to see options) |
| Add extra context dirs | `cmd --add-dir <dir>` |

For the complete flag list, sub-commands (`taste`, `mcp`, `skills`, `login`), slash commands, and exit codes, read **`references/cli-reference.md`**.

## Taste, goals, MCP, skills — the personalization layer

`cmd`'s differentiator is **taste**: it learns how the user likes code written and applies it automatically.
- `cmd taste` — manage taste packages; `cmd taste learn <local-repo|github-repo>` — learn taste from a codebase.
- `cmd learn-taste` / `cmd --learn-taste` — build taste from existing Claude Code / Codex sessions.
- `/goal "<objective>"` (slash command inside a session) — set a standing objective the agent works toward; `/goal status`, `/goal clear`.
- `cmd mcp` — manage MCP servers; `cmd skills` — manage skills from GitHub repos.
- `cmd login` / `cmd status` / `cmd whoami` — auth. Before any headless fleet, confirm `cmd status` shows authenticated, or every worker fails identically.

When dispatching for a taste-sensitive codebase, consider running `cmd taste learn <this-repo>` once up front so the workers inherit the house style.

## Safety & consent

`--yolo` runs an autonomous agent loop with **no approval gate** — it can run any shell command or file edit in its working directory unsupervised. Treat it like handing someone commit access to that worktree.

- **Get explicit user consent** before launching `--yolo` runs. The host harness may also block launching an unsupervised third-party agent until the user has clearly authorized "approvals off"; if a launch is denied, surface it and ask — don't try to work around it.
- **Contain the blast radius**: dedicated worktree, a branch (never straight onto `main`), and "do not push" in the prompt so nothing leaves the machine without your review.
- **Never** put secrets in the prompt; `cmd` inherits the environment and its own auth.
- Review every diff before merging. `--yolo` means *you* are the approval gate, moved to the end.

## Quick reference: dispatch a fleet over GitHub issues

```bash
BASE=/path/to/worktrees; mkdir -p $BASE
for spec in "72:publications" "76:webhooks" "78:k8s-sandbox"; do
  n=${spec%%:*}; slug=${spec##*:}
  git worktree add -b "feat/issue-$n-$slug" "$BASE/issue-$n" main
  ( cd "$BASE/issue-$n" && \
    cmd -p "Implement GitHub issue #$n. Run 'gh issue view $n' and follow it exactly. <restate seams + scope + style + 'do not run pnpm install/build' + exact commit msg + 'do not push' + 'print a summary'>." \
        --yolo --max-turns 100000 --skip-onboarding > "$BASE/issue-$n.log" 2>&1 ) &
done
wait
# then: review each branch's diff, merge, and run ONE consolidated typecheck/test pass.
```

Use the `/command-code:dispatch` command for a guided version of this fan-out.
