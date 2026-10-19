# CLAUDE.md

This repo is the shared brain, the root source of truth for agent memory across tools and sessions. Read [`AGENTS.md`](./AGENTS.md) for the protocol.

- `MEMORY.md` is the index. Read it first.
- [`memory/`](./memory/) holds atomic notes as an OKF v0.1 bundle.
- [`DREAM.md`](./DREAM.md) is the consolidation pass.

Per-project memory under `~/.claude/projects/<project>/memory/` is a scratchpad. Promote general facts from it into this repo's `memory/`, then commit.

If this repo is public, never store credentials, hostnames, IPs, machine names, locations, or anything not already public. See `AGENTS.md` section 3.
