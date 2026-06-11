---
allowed-tools: Bash(git *), Bash(gh *), Read
description: Run one-shot triage on repo queues. Scans open issues, PRs, CI status. Classifies items by fit, risk, autonomy. No loop, just snapshot.
---

# Agent Loop Triage

One-shot triage scan of repository queues. Does NOT start the loop — just
inspects and reports.

## Usage

```bash
/agent-loop:triage
/agent-loop:triage --scope all
/agent-loop:triage --scope org --org duyet
/agent-loop:triage --repo duyet/clickhouse-monitoring
/agent-loop:triage --detail          # Full detail on every item
/agent-loop:triage --json            # Machine-readable output
```

## Options

- `--scope <current|all|org>`: Triage scope (default: current repo)
- `--org <name>`: Organization for org scope (default: from git remote)
- `--repo <owner/repo>`: Specific repo to triage
- `--detail`: Full detail on every item (not just top items)
- `--json`: Machine-readable JSON output
- `--limit <n>`: Max items per queue (default: 50)

## Output

```text
Triage Report — duyet/clickhouse-monitoring
Scanned: 12 issues, 5 PRs

Autonomous (2):
  GH-123: bug | login timeout on slow networks
    Risk: low | Proof: repro + failing test
    → Dispatch: fix and PR

  GH-124: deps | update lodash to 4.17.21
    Risk: low | Proof: green CI
    → Dispatch: merge

Needs Review (1):  GH-125: feature | dark mode

Defer/Close (2):   GH-126, GH-127 (stale/duplicate)
```
