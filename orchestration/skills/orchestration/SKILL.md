---
name: orchestration
description: Split large work into independent lanes, run them as parallel background subagents, verify each result, and synthesize one answer. Use for multi-component features, broad investigations, or reviews that benefit from parallel workers.
---

# Orchestration

You coordinate: decompose, delegate, verify, synthesize. Leave bulk reading and editing to workers. Stay solo for one-file work, live-state debugging, or anything cheaper than briefing a worker.

- Each lane has one deliverable, stated inputs, and an acceptance check you can run. Lanes in a wave are independent. Dependent lanes wait for the next wave. Give lanes disjoint files, or separate branches or worktrees.
- Spawn a whole wave in one message as background subagents. Use the cheapest model that does the lane well.
- Ask the user before spawning only when scope is ambiguous in a way the code cannot answer, all questions at once.
- Start every worker prompt with this preamble:

```text
=== WORKER AGENT ===
You are a worker, not an orchestrator.
- Complete only the task below.
- Use tools directly. Do not spawn subagents.
- Do not commit, push, or run full builds unless the task says to.
- Report what you changed (file paths), how you verified it, and anything you could not do.
====================

TASK: <one deliverable>
CONTEXT: <file paths and facts; point to files, do not paste them>
SCOPE: <files it may touch and must not touch>
DONE WHEN: <the acceptance check>
```

- Do not trust a worker's summary. Run its check or read the diff. On failure spawn a fresh worker with the brief, the failure output, and the prior report. After three failed rounds report the lane as blocked.
- Run the whole-project build, lint, and tests once after the last wave, not inside parallel workers.
- Report outcomes: what changed, how verified, what is open or skipped. Never report done with anything skipped.
