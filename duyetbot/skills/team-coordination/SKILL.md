---
name: team-coordination
description: Spawn and coordinate team-agents and orchestration patterns for parallel execution. Use for complex multi-component work.
---

# Team Coordination

Duyetbot's capability to spawn and coordinate other agents for parallel execution.

## Available Agents

From **@team-agents** plugin:

| Agent | Model | Use For |
|-------|-------|---------|
| `leader` | opus | Complex decomposition, team coordination |
| `senior-engineer` | sonnet | Architectural decisions, complex impl |
| `junior-engineer` | haiku | Clear specs, fast execution |

## When to Spawn

### Spawn @leader
- Multi-component features
- Unclear requirements needing decomposition
- Work requiring architectural decisions

### Spawn @senior-engineer
- Complex implementation logic
- Architectural decisions
- Performance-critical code
- Security-sensitive work

### Spawn @junior-engineer
- Well-defined tasks with clear specs
- Straightforward CRUD operations
- Test writing with clear patterns
- Documentation updates

### Stay Solo
- Single-file changes
- Debugging sessions
- Analysis and investigation
- Quick fixes

## Orchestration Patterns

From **@orchestration** plugin:

### Fan-Out
Launch independent agents simultaneously:
```
├── Agent 1: Task A
├── Agent 2: Task B
└── Agent 3: Task C
→ All run in parallel
```

### Pipeline
Sequential stages:
```
Stage 1 → Stage 2 → Stage 3
(each depends on previous)
```

### Map-Reduce
Distribute then aggregate:
```
Map: Split work across agents
Reduce: Synthesize results
```

### Speculative
Competing approaches:
```
├── Hypothesis A
├── Hypothesis B
└── Hypothesis C
→ Select best evidence-backed
```

## Spawn Protocol

### 1. Task Analysis
```
[ANALYZE] Is this parallelizable?
- Independent components? → Fan-out
- Sequential dependencies? → Pipeline
- Need decomposition? → Spawn @leader
```

### 2. Agent Selection
```
[SELECT] Match agent to task:
- Complex/architectural → @senior-engineer
- Clear/straightforward → @junior-engineer
- Need coordination → @leader
```

### 3. Spawn with Context
```
Task tool with run_in_background=True:

=== WORKER AGENT ===
You are a WORKER spawned by duyetbot.
========================

TASK: [specific assignment]
CONTEXT: [background info]
SCOPE: [boundaries]
OUTPUT: [expected deliverable]
```

### 4. Monitor & Integrate
```
[MONITOR] Track agent progress
[WAIT] Await completion
[VERIFY] Check quality gates
[INTEGRATE] Combine results
```

## Output Format

```
[1] ANALYZE → 3 independent components identified
[2] SPAWN @senior-engineer → "Component A"
[3] SPAWN @junior-engineer → "Component B"
[4] SPAWN @junior-engineer → "Component C"
[5] WAIT → All agents complete
[6] VERIFY → Integration tests pass

─── duyetbot ── coordinating ─────
```

## Quality Gates for Spawned Work

Before accepting agent output:
- [ ] Meets task specification
- [ ] Follows project patterns
- [ ] Tests included and passing
- [ ] No security issues
- [ ] Integrates with other components

## Anti-Patterns

### Don't: Over-Orchestrate
```
BAD: Spawn 5 agents for a simple fix
GOOD: Solo execution for simple tasks
```

### Don't: Under-Specify
```
BAD: "Fix the bug"
GOOD: "Fix auth timeout in auth.ts:45, add retry logic with 3 attempts"
```

### Don't: Ignore Dependencies
```
BAD: Spawn parallel agents for dependent tasks
GOOD: Pipeline pattern for sequential dependencies
```
