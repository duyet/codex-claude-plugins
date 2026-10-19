---
allowed-tools: Bash, Read, Write, Task, Agent
description: Resume the agent-loop from .agent-loop/state.json and run the next cycle. Use after a stop, crash, or as the command a scheduler invokes each interval.
---

# Agent loop resume

1. Load and validate the state file per the State file section of the `agent-loop-orchestrator` skill. If it is missing, say so and suggest `/agent-loop:start`. If it is invalid, suggest `/agent-loop:restore`.
2. If `shutdown_requested` is true, the loop was stopped. Print that, tell the user to run `/agent-loop:start --resume` to restart, and exit. A leftover scheduled run must not restart a stopped loop.
3. Otherwise increment `cycle` and run one cycle per that skill.
