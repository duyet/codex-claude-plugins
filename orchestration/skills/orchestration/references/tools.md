# Orchestration Tools Reference

Detailed guidance on using tools for effective orchestration.

## Core Tools

### Task Tool

Primary tool for spawning worker agents.

```typescript
Task({
  description: "Short description (3-5 words)",
  prompt: "Detailed task instructions with WORKER preamble",
  subagent_type: "explore" | "Plan" | "general-purpose" | "junior-engineer" | "senior-engineer",
  run_in_background: true,  // ALWAYS true for parallel execution
  model: "sonnet" | "opus" | "haiku"  // Optional, inherit from parent
})
```

**Agent Type Selection**:
| Type | Use Case | Complexity |
|------|----------|------------|
| `Explore` | Finding code, patterns, structure | Low |
| `Plan` | Architecture, design decisions | Medium |
| `junior-engineer` | Simple, well-defined tasks | Low |
| `senior-engineer` | Complex implementation | High |
| `general-purpose` | Building, broad implementation | Medium-High |

**Model Selection**:
| Model | Use Case |
|-------|----------|
| `haiku` | Quick, straightforward tasks |
| `sonnet` | Balanced complexity (default) |
| `opus` | Complex reasoning, critical decisions |

### AskUserQuestion Tool

Gather context through rich, consultative questioning.

```typescript
AskUserQuestion({
  questions: [
    {
      question: "Full question with context?",
      header: "Short Label",  // Max 12 chars
      options: [
        { label: "Option 1", description: "Full explanation of trade-offs" },
        { label: "Option 2", description: "Full explanation of trade-offs" },
        { label: "Option 3", description: "Full explanation of trade-offs" },
        { label: "Option 4", description: "Full explanation of trade-offs" }
      ],
      multiSelect: false  // true for non-exclusive choices
    }
  ]
})
```

**Maximal Questioning Strategy**:
- Up to 4 questions per interaction
- Each question has up to 4 rich options
- Options include full descriptions with trade-offs
- Be consultative, not transactional

```typescript
// BAD: Transactional
{
  question: "Which database?",
  options: [
    { label: "PostgreSQL", description: "Relational database" },
    { label: "MongoDB", description: "Document database" }
  ]
}

// GOOD: Consultative
{
  question: "What data model best fits your use case?",
  options: [
    {
      label: "Relational (PostgreSQL)",
      description: "Strong consistency, complex queries, ACID transactions. Best for structured data with relationships."
    },
    {
      label: "Document (MongoDB)",
      description: "Flexible schema, horizontal scaling, eventual consistency. Best for rapidly evolving schemas."
    },
    {
      label: "Key-Value (Redis)",
      description: "Ultra-fast reads, in-memory, simple data structures. Best for caching and sessions."
    },
    {
      label: "Hybrid approach",
      description: "Multiple databases for different needs. More complexity, maximum flexibility."
    }
  ]
}
```

### TodoWrite Tool

Track task decomposition and progress.

```typescript
TodoWrite({
  todos: [
    { content: "Task description", status: "pending", activeForm: "Processing task" },
    { content: "Active task", status: "in_progress", activeForm: "Working on task" },
    { content: "Completed task", status: "completed", activeForm: "Completed task" }
  ]
})
```

**Status Flow**:
```
pending → in_progress → completed
                ↓
         (blocked by dependency)
```

**Best Practices**:
- Update immediately when task status changes
- Only one task should be `in_progress` at a time
- Remove tasks that become irrelevant
- Use clear, action-oriented descriptions

## Worker Preamble Template

Every spawned agent MUST receive this preamble:

```markdown
=== WORKER AGENT ===
You are a WORKER agent, not an orchestrator.
- Complete ONLY the task described below
- Use tools directly (Read, Write, Edit, Bash)
- NEVER spawn sub-agents or manage tasks
- Report results clearly, then stop
========================

TASK: [Specific, actionable task description]

CONTEXT:
[Relevant background information]
[What this task is part of]
[Any constraints or requirements]

SCOPE:
[Clear boundaries]
[What to include]
[What to exclude]

OUTPUT:
[Expected format]
[What to deliver]
[How to report results]
```

## Parallel Execution

### Launching Multiple Agents

All agents in a single message execute in parallel:

```typescript
// One message with multiple Task calls = parallel
[
  Task({ description: "Analyze frontend", ... }),
  Task({ description: "Analyze backend", ... }),
  Task({ description: "Analyze database", ... })
]
```

### Handling Results

Results arrive as agents complete. Track with TodoWrite:

```typescript
// Initial state
todos: [
  { content: "Frontend analysis", status: "in_progress", ... },
  { content: "Backend analysis", status: "in_progress", ... },
  { content: "Database analysis", status: "in_progress", ... },
  { content: "Synthesize findings", status: "pending", ... }
]

// As results arrive
todos: [
  { content: "Frontend analysis", status: "completed", ... },
  { content: "Backend analysis", status: "in_progress", ... },  // Still running
  { content: "Database analysis", status: "completed", ... },
  { content: "Synthesize findings", status: "pending", ... }  // Blocked until all complete
]
```

## Error Handling

### Agent Failures

When a worker agent fails:
1. Note the failure in TodoWrite
2. Decide: retry, alternative approach, or proceed without
3. Communicate naturally to user if significant

### Dependency Failures

When a blocking task fails:
1. Assess downstream impact
2. Update blocked tasks appropriately
3. Consider alternative paths

### Partial Results

When some agents succeed, others fail:
1. Synthesize available results
2. Clearly note gaps
3. Suggest follow-up for failed areas

## Workflow Template

Complete orchestration flow:

```typescript
// 1. UNDERSTAND
// Read user request, assess complexity

// 2. CLARIFY (if needed)
AskUserQuestion({
  questions: [/* rich questions about scope and preferences */]
})

// 3. DECOMPOSE
TodoWrite({
  todos: [
    { content: "Task 1", status: "pending", ... },
    { content: "Task 2 (depends on 1)", status: "pending", ... },
    { content: "Task 3 (parallel with 1)", status: "pending", ... },
    { content: "Synthesize results", status: "pending", ... }
  ]
})

// 4. EXECUTE PHASE 1 (parallel)
TodoWrite({ todos: [/* update Task 1, Task 3 to in_progress */] })

[
  Task({ description: "Execute Task 1", run_in_background: true, ... }),
  Task({ description: "Execute Task 3", run_in_background: true, ... })
]

// 5. PROCESS RESULTS
// As results arrive, update todos, start next phase

// 6. SYNTHESIZE
// Combine all results into coherent response

// 7. DELIVER
// Present unified findings with clear recommendations
```
