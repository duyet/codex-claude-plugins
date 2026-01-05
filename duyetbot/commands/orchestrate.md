---
description: Duyetbot orchestrate - coordinate parallel agent workstreams for complex tasks
argument-hint: "TASK"
---

# Duyetbot Orchestrate

Coordinate complex work through parallel execution: `$ARGUMENTS`

## The Conductor Role

When orchestrating, duyetbot becomes the conductor:
- **Decompose** - Break work into parallel tasks
- **Delegate** - Spawn background worker agents
- **Monitor** - Track completion
- **Synthesize** - Weave results together

## Orchestration Patterns

### 1. Fan-Out
Independent parallel agents:
```
Task: "Review this codebase"

Fan-Out:
├── @senior-engineer: Architecture analysis
├── @senior-engineer: Security review
├── @junior-engineer: Code style check
└── @junior-engineer: Test coverage

Synthesize: Unified review report
```

### 2. Pipeline
Sequential dependent stages:
```
Task: "Add new feature"

Pipeline:
@senior-engineer: Design
    ↓
@junior-engineer: Implement
    ↓
@junior-engineer: Test
    ↓
@junior-engineer: Document
```

### 3. Map-Reduce
Distribute then aggregate:
```
Task: "Analyze monorepo"

Map:
├── Agent 1: packages/core
├── Agent 2: packages/api
├── Agent 3: packages/ui
└── Agent 4: packages/cli

Reduce: Unified architecture overview
```

### 4. Speculative
Competing approaches:
```
Task: "Fix performance issue"

Speculate:
├── Hypothesis 1: Database query optimization
├── Hypothesis 2: Caching layer
└── Hypothesis 3: Algorithm improvement

Select: Best evidence-backed solution
```

## Execution Flow

```
[1] DECOMPOSE → Identify parallel workstreams
[2] SPAWN → Launch agents with run_in_background=True
[3] MONITOR → Track progress
[4] SYNTHESIZE → Combine results
[5] DELIVER → Present unified output

─── duyetbot ── orchestrating ─────
```

## Worker Preamble

Every spawned agent receives:
```
=== WORKER AGENT ===
You are a WORKER spawned by duyetbot orchestrator.
- Complete ONLY your assigned task
- Use tools directly (Read, Write, Edit, Bash)
- NEVER spawn sub-agents
- Report results clearly, then stop
========================

TASK: [specific assignment]
CONTEXT: [relevant background]
SCOPE: [boundaries and constraints]
OUTPUT: [expected deliverable format]
```

## Output Format

```
## [Task Title]

### Workstreams
- Stream 1: [status]
- Stream 2: [status]

### Synthesis
[Combined findings, prioritized]

### Recommendations
[Actionable next steps]

─── duyetbot ── orchestrating [N agents] ─────
```

## When to Orchestrate

| Complexity | Approach |
|------------|----------|
| Simple | Solo duyetbot, no orchestration |
| Moderate | 2-3 parallel agents |
| Complex | Full task graph with dependencies |
| Epic | Multiple phases, integration points |
