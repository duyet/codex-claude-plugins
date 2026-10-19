# agent-loop

Unattended repo maintenance. Each cycle triages open issues and PRs, sends fixable items to parallel subagents, and reports what landed. The harness's own scheduler (Claude Code `/loop`, or the Codex and Cursor equivalents) repeats the cycle.

## Install

```bash
/plugin install agent-loop@duyet-claude-plugins
```

## Skills

- `agent-loop-orchestrator` runs one cycle and defines the state file.
- `agent-loop-triage` classifies issues and PRs as autonomous, needs review, defer, or blocked.
- `agent-loop-autoreview` applies verified AI review bot fixes and merges when safe.
- `agent-loop-browser` captures screenshot proof for UI changes.

## Commands

- `/agent-loop:start`, `/agent-loop:resume`, `/agent-loop:stop` control the loop.
- `/agent-loop:status`, `/agent-loop:inspect` read the state file.
- `/agent-loop:reset`, `/agent-loop:restore` clear or recover state from backups.
- `/agent-loop:triage`, `/agent-loop:autoreview` run one pass without the loop.

## Example

```bash
/agent-loop:start --scope current --max-concurrency 3
/loop 5m /agent-loop:resume
```

State lives in `.agent-loop/state.json`. Add `.agent-loop/` to `.gitignore`.

## Credits

Triage and browser skills are adapted from [steipete/agent-scripts](https://github.com/steipete/agent-scripts).
