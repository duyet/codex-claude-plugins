# CLAUDE.md

This repo is the **shared brain** — the root source of truth for agent memory
across every tool and session.

**The protocol lives in [`AGENTS.md`](./AGENTS.md). Read it.** It defines how to
read the index, write atomic notes, the frontmatter format, what must never be
stored, and the dream/consolidation pass.

Quick map:
- [`MEMORY.md`](./MEMORY.md) — master index, read first.
- [`memory/`](./memory/) — atomic notes, one fact per file; OKF v0.1 bundle (nested `<group>/…` topics).
- [`DREAM.md`](./DREAM.md) — memory-consolidation protocol.
- [`README.md`](./README.md) — human onboarding & new-device setup.

Claude-specific note: your per-project memory under
`~/.claude/projects/<project>/memory/` is a private scratchpad. When a fact
there is **general** (and public, if this repo is public), promote it into this
repo's `memory/` so every other session and tool shares it too. Then commit
(and push, if this repo has a remote).

## ⚠️ If this repo is public

Never commit: credentials, hostnames, IPs, machine names, SSH endpoints,
internal project names, locations, or anything not already public. Full list
in [`AGENTS.md` §3](./AGENTS.md). If you wouldn't put it on a public README,
don't put it here — or keep this repo private instead.
