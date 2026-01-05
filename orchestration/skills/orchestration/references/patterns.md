# Orchestration Patterns Reference

Comprehensive playbook for decomposing complex tasks into parallel execution strategies.

## Core Framework

All patterns build on the Task Graph concept:
1. **Decompose** - Break work into tasks
2. **Dependencies** - Define what blocks what
3. **Parallelize** - Execute unblocked work simultaneously
4. **Synthesize** - Combine results coherently

## Primary Patterns

### 1. Task Graph

Foundation for all orchestration. Manages complex dependencies.

```
Structure:
├── Task A (no deps) ──────────────────┐
├── Task B (no deps) ────────────┐     │
├── Task C (depends on A) ←──────│─────┘
├── Task D (depends on A, B) ←───┴─────┐
└── Task E (depends on C, D) ←─────────┘

Execution:
Phase 1: A, B (parallel)
Phase 2: C, D (parallel, after Phase 1)
Phase 3: E (after Phase 2)
```

**When to use**: Any complex work with interdependencies.

### 2. Fan-Out

Launch independent agents simultaneously, no dependencies between them.

```
Request: "Analyze this codebase"

Fan-Out:
├── Agent 1: Architecture analysis
├── Agent 2: Code quality scan
├── Agent 3: Security audit
├── Agent 4: Performance review
└── Agent 5: Dependency analysis

Reduce:
→ Synthesize into unified codebase report
```

**When to use**: Multi-dimensional analysis, comprehensive reviews, parallel investigations.

### 3. Pipeline

Sequential agents where each passes output to the next.

```
Request: "Add new feature end-to-end"

Pipeline:
Research → Design → Implement → Test → Document
    ↓         ↓         ↓        ↓        ↓
 patterns   specs     code    tests    docs
```

**When to use**: Linear workflows, build processes, migrations.

### 4. Map-Reduce

Distribute work across parallel agents, then aggregate results.

```
Request: "Update all API endpoints to v2"

Map (parallel):
├── Agent 1: /users/* endpoints
├── Agent 2: /products/* endpoints
├── Agent 3: /orders/* endpoints
└── Agent 4: /auth/* endpoints

Reduce:
→ Verify consistency
→ Update API documentation
→ Create migration guide
```

**When to use**: Batch operations, distributed analysis, large-scale changes.

### 5. Speculative

Run multiple competing approaches simultaneously, select the best.

```
Request: "Fix slow dashboard loading"

Speculate (parallel hypotheses):
├── Agent 1: Database query optimization
├── Agent 2: Frontend rendering optimization
├── Agent 3: API response caching
└── Agent 4: Asset optimization

Evaluate:
→ Measure impact of each approach
→ Select most effective
→ Optionally combine complementary fixes
```

**When to use**: Root cause unknown, multiple valid approaches, performance optimization.

### 6. Background

Long-running work continues while other tasks proceed.

```
Request: "Deploy with confidence"

Background:
├── Full test suite (10 min)
└── Security scan (5 min)

Foreground (continues immediately):
├── Prepare deployment config
├── Update documentation
└── Notify stakeholders

Sync point:
→ Wait for background tasks before deploy
```

**When to use**: Test suites, builds, long-running validations.

## Pattern Combinations

### Fan-Out → Reduce → Pipeline

```
Phase 1 (Fan-Out): Parallel investigation
├── Investigate frontend
├── Investigate backend
└── Investigate database

Phase 2 (Reduce): Synthesize findings
→ Root cause identified

Phase 3 (Pipeline): Sequential fix
Research fix → Implement → Test → Deploy
```

### Pipeline → Fan-Out → Pipeline

```
Phase 1 (Pipeline): Setup
Research → Design architecture

Phase 2 (Fan-Out): Parallel implementation
├── Build component A
├── Build component B
└── Build component C

Phase 3 (Pipeline): Integration
Integrate → Test → Deploy
```

### Speculative → Fan-Out

```
Phase 1 (Speculative): Find approach
├── Try approach A
└── Try approach B
→ Select winner

Phase 2 (Fan-Out): Apply everywhere
├── Apply to module 1
├── Apply to module 2
└── Apply to module 3
```

## Critical Rules

### Parallel Execution
Multiple background agents MUST be launched in a **single message** to execute in parallel:

```typescript
// CORRECT: Single message, parallel execution
[
  Task(agent1, run_in_background=True),
  Task(agent2, run_in_background=True),
  Task(agent3, run_in_background=True)
]

// WRONG: Separate messages, sequential execution
Task(agent1, run_in_background=True)
// wait for response
Task(agent2, run_in_background=True)
// wait for response
Task(agent3, run_in_background=True)
```

### Dependency Management
Always explicitly declare dependencies:

```
Task A: "Implement database schema" (no deps)
Task B: "Implement API endpoints" (depends on A)
Task C: "Implement frontend" (depends on B)
Task D: "Write tests" (depends on A, can run parallel with B, C)
```

### Synthesis Strategy

After parallel work completes:
1. **Prioritize** - Order findings by severity/importance
2. **Deduplicate** - Remove redundant insights across agents
3. **Hide machinery** - Present as unified analysis
4. **Tell the story** - Coherent narrative, not agent-by-agent dump
5. **Actionable** - Clear next steps with ownership

## Pattern Selection Guide

| Scenario | Recommended Pattern |
|----------|-------------------|
| Multi-dimensional analysis | Fan-Out → Reduce |
| Build/deploy process | Pipeline |
| Large batch changes | Map-Reduce |
| Unknown root cause | Speculative |
| Long-running + urgent work | Background |
| Complex feature | Pipeline → Fan-Out → Pipeline |
| Comprehensive review | Fan-Out → Reduce |
| A/B testing approaches | Speculative → Fan-Out |
