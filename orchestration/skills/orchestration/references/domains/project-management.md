# Project Management Orchestration

Patterns for breaking down epics, planning sprints, tracking progress, and coordinating work.

## Epic Breakdown

### Pattern: Hierarchical Decomposition

```
Epic: [Large initiative]
    ↓
├── Story 1: [User-facing capability]
│   ├── Task 1.1: [Technical work]
│   ├── Task 1.2: [Technical work]
│   └── Task 1.3: [Technical work]
│
├── Story 2: [User-facing capability]
│   ├── Task 2.1
│   └── Task 2.2
│
└── Story 3: [User-facing capability]
    └── ...

Fan-Out (parallel analysis):
├── Agent 1: Decompose frontend stories
├── Agent 2: Decompose backend stories
├── Agent 3: Decompose infrastructure stories
└── Agent 4: Identify cross-cutting concerns

Consolidation:
→ Complete backlog with dependencies
→ Estimated complexity
→ Suggested sprint allocation
```

### Vertical Slice Approach

```
Instead of horizontal layers:
├── All UI components
├── All API endpoints
├── All database changes

Use vertical slices:
├── Login flow (UI + API + DB)
├── Registration flow (UI + API + DB)
└── Password reset flow (UI + API + DB)

Benefits:
├── Deliverable value each sprint
├── Early integration feedback
└── Reduced integration risk
```

### Spike-First Method

```
When uncertainty is high:

Phase 1: Spike (time-boxed research)
├── Technical feasibility
├── Architecture options
├── Risk assessment
└── Effort estimation

Phase 2: Planning
→ Informed story breakdown
→ Realistic estimates
→ Risk mitigation in plan

Phase 3: Implementation
→ Execute with confidence
```

## Sprint Planning

### Pattern: Capacity-Based Planning

```
Inputs (parallel gathering):
├── Agent 1: Review prioritized backlog
├── Agent 2: Calculate team capacity
├── Agent 3: Identify blockers
└── Agent 4: Check dependencies

Planning:
├── Match capacity to backlog
├── Account for uncertainty (20% buffer)
├── Identify stretch goals
└── Define sprint goal

Output:
→ Committed scope
→ Sprint goal statement
→ Task breakdown per assignee
```

### Capacity Calculation

```
Team Capacity:
├── Available days × engineers
├── Subtract: meetings, support rotation, PTO
├── Factor: velocity (points/day from history)

Example:
├── 10 working days
├── 4 engineers
├── -2 days meetings
├── -3 days PTO
├── = 35 engineer-days
├── × 2 points/day velocity
├── = 70 points capacity
├── × 0.8 safety factor
├── = 56 points commitment
```

### Risk-Adjusted Planning

```
Risk factors:
├── New technology: +30% buffer
├── External dependency: +20% buffer
├── Complex integration: +25% buffer
├── Unclear requirements: +40% buffer

Apply to affected items:
├── Story A (new tech): 5 pts × 1.3 = 6.5 pts
├── Story B (external dep): 8 pts × 1.2 = 9.6 pts
└── Adjust capacity accordingly
```

## Progress Tracking

### Pattern: Multi-Dimensional Status

```
Fan-Out (parallel status gathering):
├── Agent 1: Task completion status
├── Agent 2: Blocker identification
├── Agent 3: Timeline alignment
├── Agent 4: Quality metrics
└── Agent 5: Risk assessment

Dashboard metrics:
├── Burndown chart
├── Blocker count/severity
├── Scope changes
├── Quality indicators
└── Risk register updates
```

### Status Update Template

```markdown
## Sprint [N] Status - Day [X]/[Y]

### Progress
| Category | Planned | Done | Remaining |
|----------|---------|------|-----------|
| Stories | 8 | 5 | 3 |
| Points | 56 | 38 | 18 |

### Burndown
[Chart or trend indicator]

### Blockers
| Issue | Owner | Status | ETA |
|-------|-------|--------|-----|
| [blocker] | [name] | [status] | [date] |

### Risks
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [risk] | [H/M/L] | [H/M/L] | [action] |

### Next 24 Hours
- [Priority 1]
- [Priority 2]
```

## Dependency Management

### Pattern: Graph Construction

```
Phase 1: Identify Dependencies (parallel)
├── Agent 1: Technical dependencies
├── Agent 2: External team dependencies
├── Agent 3: Resource dependencies
└── Agent 4: Timeline dependencies

Phase 2: Graph Building
→ Create dependency graph
→ Identify critical path
→ Find parallel opportunities

Phase 3: Risk Assessment
├── Single points of failure
├── Long dependency chains
├── External blockers
└── Mitigation strategies
```

### Critical Path Analysis

```
Identify longest dependency chain:

[A: 3d] ──┬──> [C: 2d] ──┬──> [F: 3d] ──> [G: 2d]
          │              │
[B: 2d] ──┘              │
                         │
[D: 4d] ──> [E: 2d] ─────┘

Critical path: D → E → F → G (11 days)
Parallel work: A, B can run with D → E

Focus:
├── Protect critical path items
├── Parallelize non-critical work
└── Monitor critical path progress
```

## Team Coordination

### Pattern: Skill-Based Distribution

```
Phase 1: Analysis (parallel)
├── Agent 1: Parse requirements
├── Agent 2: Assess team skills
├── Agent 3: Calculate capacity
└── Agent 4: Identify training needs

Phase 2: Assignment
├── Match skills to requirements
├── Balance workload
├── Consider growth opportunities
└── Plan knowledge transfer

Phase 3: Coordination
├── Define handoff points
├── Schedule sync meetings
├── Set up communication channels
└── Establish escalation paths
```

### Cross-Team Coordination

```
When multiple teams involved:

Phase 1: Alignment
├── Share roadmaps
├── Identify dependencies
├── Agree on interfaces
└── Define SLAs

Phase 2: Execution
├── Regular sync meetings
├── Shared tracking board
├── Clear escalation path
└── Joint retrospectives

Phase 3: Integration
├── Defined integration points
├── Joint testing
├── Coordinated deployment
└── Shared monitoring
```

## Output Templates

### Epic Breakdown Document

```markdown
## Epic: [Title]

### Overview
[Purpose and business value]

### Success Criteria
- [ ] [Measurable outcome 1]
- [ ] [Measurable outcome 2]

### Stories

#### Story 1: [Title]
**Description**: [As a... I want... So that...]
**Estimate**: [points]
**Dependencies**: [list]

Tasks:
- [ ] [Task 1.1]
- [ ] [Task 1.2]

#### Story 2: [Title]
[...]

### Dependencies
[Graph or table of dependencies]

### Timeline
| Sprint | Stories | Goal |
|--------|---------|------|
| S1 | 1, 2 | [milestone] |
| S2 | 3, 4 | [milestone] |

### Risks
| Risk | Mitigation |
|------|------------|
| [risk] | [action] |
```

## Best Practices

### Planning Principles

```
1. Break down until estimatable (max 3 days)
2. Make dependencies explicit
3. Include buffer for unknowns
4. Define done criteria upfront
5. Update progress in real-time
```

### Meeting Efficiency

| Meeting | Purpose | Frequency | Duration |
|---------|---------|-----------|----------|
| Standup | Sync | Daily | 15 min |
| Planning | Commit scope | Per sprint | 2 hrs |
| Review | Demo work | Per sprint | 1 hr |
| Retro | Improve | Per sprint | 1 hr |
| Backlog grooming | Prep work | Weekly | 1 hr |
