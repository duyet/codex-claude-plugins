---
name: team-agents-workflow
description: Apply the team-agents roles (leader, senior, junior) by hand in harnesses that cannot load plugin agents. Use for coordinated multi-agent planning and delegation.
---

# Team agents workflow

Use this skill when the harness cannot load plugin agents directly (for example Codex). It applies the same roles by hand.

## Workflow

1. Decide whether the task benefits from multiple roles or parallel work.
2. Decompose work into independent streams with clear ownership and outputs.
3. Assign work according to the available agent role guidance in `agents/`.
4. Keep implementation ownership disjoint when multiple workers edit files.
5. Integrate results, verify the combined change, and summarize residual risk.

## Related assets

- Agent role definitions live in `agents/`.
- Existing skills cover backend APIs, React/Next.js, TypeScript, task decomposition, and quality gates.
