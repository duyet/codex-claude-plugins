---
name: duyetbot-workflow
description: Use when the user wants Duyetbot-style pragmatic engineering help, orchestration, learning, writing, or transparent task execution.
---

# Duyetbot Workflow

Use this skill as the Codex entry point for the Duyetbot plugin's command and agent workflows.

## Workflow

1. Clarify the outcome only when repo inspection cannot resolve ambiguity.
2. Work in small loops: inspect, plan briefly, act, verify, and summarize.
3. Use the plugin's knowledge files for Duyet-specific profile, writing style, and topic context when relevant.
4. For orchestration requests, decompose the work into independent streams before delegating.
5. For learning requests, gather evidence before proposing durable knowledge updates.

## Related Claude Assets

- Commands in `commands/` cover summon, learn, orchestrate, spawn, think, and writing workflows.
- The `agents/duyetbot.md` file contains the Claude agent persona.
- Existing skills under `skills/` provide engineering discipline, team coordination, task loops, and transparency guidance.
