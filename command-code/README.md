# command-code

Drive the Command Code CLI (`cmd`) from your coding agent, and dispatch it as a headless sub-agent that implements tasks or GitHub issues in parallel, each in its own git worktree.

```bash
/plugin install command-code@duyet-claude-plugins
```

## What ships

- `command-code` skill. The headless invocation (`cmd -p ... --yolo --max-turns 100000 --skip-onboarding`), the worktree dispatch workflow, review and resume rules, and safety notes.
- `/command-code:dispatch` command. Turns issues or tasks into isolated workers, launches them, and reviews the branches.
- `cmd-dispatcher` agent. Runs the whole dispatch loop.

## Safety

`--yolo` removes the approval gate, so you review each diff before merging. Dispatch only with the user's consent, in a dedicated worktree on a branch, with "do not push" in the prompt.

## Requirements

`cmd` installed and authenticated (`cmd login`, check with `cmd status`), `git`, and `gh` for issue-based work.
