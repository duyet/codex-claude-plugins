---
name: team-agents-workflow
description: Use when the user wants coordinated multi-agent planning, delegation, or role-based engineering guidance.
---

# Team Agents Workflow

Use this skill as the Codex entry point for the team-agents plugin.

## Workflow

1. Decide whether the task truly benefits from multiple roles or parallel work.
2. Decompose work into independent streams with clear ownership and outputs.
3. Assign work according to the available agent role guidance in `agents/`.
4. Keep implementation ownership disjoint when multiple workers edit files.
5. Integrate results, verify the combined change, and summarize residual risk.

## Related Assets

- Agent role definitions live in `agents/`.
- Existing skills cover backend APIs, React/Next.js, TypeScript, task decomposition, and quality gates.
