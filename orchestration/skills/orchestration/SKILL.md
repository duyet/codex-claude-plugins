---
name: orchestration
description: Split large work into independent lanes, run them as parallel background subagents, verify each result, and synthesize one answer. Use for multi-component features, broad investigations, or reviews that benefit from parallel workers.
---

# Orchestration

You are the coordinator. You decompose, delegate, verify, and synthesize. Read enough of the code to split the work well and to check what workers return. Leave the bulk reading and editing to workers so your context stays free for coordination.

Stay solo when the work is one file, a debugging session that depends on live state, or anything smaller than the cost of briefing a worker.

## Decompose

1. List the deliverables. Each lane owns one deliverable with defined inputs, outputs, and an acceptance check you can run.
2. Map dependencies. Lanes with no dependency on each other run in the same wave. A lane that needs another lane's output waits for the next wave.
3. Split any lane a single worker could not finish and verify in one pass.
4. Give lanes disjoint files. Two workers editing the same file conflict. If they must share, run them in sequence or give each its own branch or worktree.
5. Track the lanes in the harness's todo or task list.

Ask the user before spawning only when scope is ambiguous in a way the code cannot answer. Ask everything at once, not one question per turn.

## Fan out

Spawn every lane in the current wave in one message, as background subagents, so they run concurrently. Pick the cheapest model and agent type that can do the lane well: a fast model for search and mechanical edits, a stronger one for design and subtle bugs.
If the team-agents plugin is installed, its `leader`, `senior-engineer`, and `junior-engineer` agents fit these roles. Any general-purpose subagent works without it.

Start every worker prompt with this preamble:

```text
=== WORKER AGENT ===
You are a worker, not an orchestrator.
- Complete only the task below.
- Use tools directly. Do not spawn subagents.
- Do not commit, push, or run full builds unless the task says to.
- Report what you changed (file paths), how you verified it, and anything you could not do.
====================

TASK: <one deliverable>
CONTEXT: <file paths and facts the worker needs; point to files, do not paste them>
SCOPE: <files it may touch, files it must not touch>
DONE WHEN: <the acceptance check>
```

Common shapes:

- **Fan-out and reduce.** N workers analyze one target from different angles (security, performance, tests), then you merge and deduplicate.
- **Map.** One worker per independent unit (per package, per file group, per failing test).
- **Pipeline.** Waves in dependency order: schema, then API and UI in parallel, then integration tests.
- **Speculative.** Two workers try competing approaches. Keep the one whose check passes with the smaller diff.

## Verify loop

Do not trust a worker's summary. For each finished lane:

1. Run its acceptance check yourself, or read the diff against the DONE WHEN line.
2. If it fails, spawn a fresh worker with the original brief, the failure output, and the previous worker's report. Do not just say "try again".
3. Stop a lane after three failed rounds on the same step and report it as blocked with the evidence.

When a wave is verified, start the next one. After the last wave, run the whole-project check once (build, lint, tests). Run builds once here, not inside parallel workers, since concurrent builds can exhaust memory.

## Synthesize

Report outcomes, not process: what changed, where, how it was verified, and what is still open. Merge overlapping findings, rank them by severity, and name any lane that was blocked or skipped. If anything was skipped, say so. Do not report done.
