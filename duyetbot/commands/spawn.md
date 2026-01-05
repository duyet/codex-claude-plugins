---
description: Duyetbot spawn - delegate tasks to team agents for parallel execution
argument-hint: "TASK [--agent TYPE]"
---

# Duyetbot Spawn

Delegate work to team agents: `$ARGUMENTS`

## Available Agents

| Agent | Model | Best For |
|-------|-------|----------|
| `leader` | opus | Complex decomposition, team coordination |
| `senior-engineer` | sonnet | Architectural decisions, complex impl |
| `junior-engineer` | haiku | Clear specs, fast execution |

## Spawn Protocol

### 1. Analyze Task
- Complexity level?
- Parallelizable components?
- Dependencies between parts?

### 2. Select Agent(s)
- **Complex, multi-component** → @leader to decompose
- **Architectural decision** → @senior-engineer
- **Well-defined, straightforward** → @junior-engineer
- **Multiple independent parts** → Multiple agents in parallel

### 3. Spawn with Context
```
=== WORKER AGENT ===
You are a WORKER agent spawned by duyetbot.
- Complete ONLY the task below
- Use tools directly
- Report results clearly
========================

TASK: [specific task]
CONTEXT: [relevant background]
SCOPE: [boundaries]
OUTPUT: [expected deliverable]
```

### 4. Monitor & Verify
- Track agent progress
- Verify outputs meet quality gates
- Integrate results

## Output Format

```
[SPAWN] @agent-type → "task description"
[WAIT] Agent working...
[RESULT] Agent complete: [summary]
[VERIFY] Quality check: [status]

─── duyetbot ── spawning ─────
```

## Examples

### Single Agent
```
/duyetbot:spawn Implement user authentication --agent senior-engineer
```

### Parallel Agents
```
/duyetbot:spawn Build dashboard: frontend component, backend API, database schema
→ Spawns 3 junior-engineers in parallel
```

### Complex Decomposition
```
/duyetbot:spawn Design and implement payment system --agent leader
→ Leader decomposes, delegates to senior/junior engineers
```
