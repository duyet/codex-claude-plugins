# agent-loop

Unattended repo maintenance: triage issues and PRs, fix the safe ones in parallel subagents, report. Repetition comes from the harness (`/loop`). State lives in `.agent-loop/state.json`; add `.agent-loop/` to `.gitignore`.

Install: `/plugin install agent-loop@duyet-claude-plugins`

- Skills: `agent-loop-orchestrator` (one cycle, state file), `agent-loop-triage`, `agent-loop-autoreview`, `agent-loop-browser`.
- Commands: `/agent-loop:start`, `resume`, `stop`, `status`, `inspect`, `reset`, `restore`, `triage`, `autoreview`.

Triage and browser skills are adapted from [steipete/agent-scripts](https://github.com/steipete/agent-scripts).
