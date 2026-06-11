---
allowed-tools: Bash(git *), Bash(gh *), Read, Edit, Write, Task(deep,quick)
description: One-shot autonomous review of a PR. Fetches review comments from AI bots, applies verified fixes, validates, and merges when safe.
---

# Agent Loop Autoreview

One-shot autonomous PR review. Does NOT start the loop — just reviews,
fixes, validates, and optionally merges a single PR.

## Usage

```bash
/agent-loop:autoreview
/agent-loop:autoreview --pr 123
/agent-loop:autoreview --repo duyet/clickhouse-monitoring --pr 123
/agent-loop:autoreview --pr 123 --merge
/agent-loop:autoreview --pr 123 --merge --dry-run
```

## Options

- `--pr <number>`: PR number (default: current branch's PR)
- `--repo <owner/repo>`: Repository (default: from git remote)
- `--merge`: Merge PR after successful review
- `--dry-run`: Preview what would happen without applying changes
- `--skip-labels <label,...>`: Skip PRs with these labels (default: wip,do-not-merge,blocked)

## Workflow

1. Fetch PR details and diff
2. Fetch AI review bot comments (CodeRabbit, Sourcery, Gemini)
3. Extract and apply verified fixes
4. Validate: lint → test → build
5. Commit and push fixes
6. If `--merge`: check merge readiness, merge
7. Report results

## Safety Gates

- Skips draft PRs
- Skips PRs with skip-labels
- Skips PRs with unresolved human review changes requested
- Skips security-sensitive changes on first-time contributors
- Validates every fix before applying
- Reports all decisions with reasoning
