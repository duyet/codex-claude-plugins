# Software Development Orchestration

Patterns for building features, fixing bugs, refactoring code, and managing migrations.

## Feature Implementation

### Pattern: Plan-Parallel-Integrate

```
Phase 1: Research & Planning
├── Explore existing patterns in codebase
└── Design architecture and API contracts

Phase 2: Parallel Development
├── Backend implementation
├── Frontend implementation
├── Database changes
└── Infrastructure setup

Phase 3: Integration
├── Wire components together
├── Integration tests
└── Documentation
```

### Vertical Slice Approach

Build one complete flow before expanding:

```
Slice 1: Happy path
├── Create user (full stack)
└── Verify works end-to-end

Slice 2: Error handling
├── Validation errors
└── Server errors

Slice 3: Edge cases
├── Duplicate users
└── Rate limiting
```

## Bug Fixing

### Pattern: Diagnose-Hypothesize-Fix

```
Phase 1: Parallel Investigation
├── Agent 1: Analyze logs and errors
├── Agent 2: Review related code
├── Agent 3: Check recent changes
└── Agent 4: Reproduce the issue

Phase 2: Hypothesis Formation
→ Synthesize findings into likely causes

Phase 3: Speculative Testing
├── Test hypothesis A
└── Test hypothesis B

Phase 4: Implementation
├── Apply fix for confirmed cause
├── Add regression test
└── Document root cause
```

### Bisection Approach

When timing is unclear:

```
1. Create minimal reproduction
2. Identify last known working state
3. Binary search commits
4. Isolate breaking change
5. Apply targeted fix
```

## Refactoring

### Pattern: Map-Analyze-Transform

```
Phase 1: Map (parallel)
├── Find all instances of target pattern
├── Identify dependencies
└── Assess impact scope

Phase 2: Analyze
→ Determine safe transformation order

Phase 3: Transform (sequential by dependency)
├── Transform leaf nodes first
├── Work up dependency tree
└── Update dependents
```

### Strangler Fig Pattern

For large refactors:

```
1. Wrap old implementation with new interface
2. Route new code to new implementation
3. Gradually migrate existing callers
4. Remove old implementation when empty
```

## Migration

### Pattern: Schema-Data-Code

```
Phase 1: Schema Changes
├── Design new schema
├── Create migration scripts
└── Plan rollback strategy

Phase 2: Parallel Updates
├── Update data access layer
├── Update business logic
├── Update API contracts
└── Update frontend

Phase 3: Data Migration
├── Migrate existing data
├── Validate integrity
└── Cut over traffic
```

### Version Upgrade Pattern

```
Phase 1: Analysis (parallel)
├── Review breaking changes
├── Identify deprecated APIs
├── Check dependency compatibility
└── Review migration guides

Phase 2: Update (map-reduce)
├── Update dependencies
├── Fix breaking changes
├── Update deprecated APIs
└── Verify tests pass
```

## Greenfield Development

### Pattern: Scaffold-Parallel-Integrate

```
Phase 1: Foundation
├── Initialize project structure
├── Set up build tooling
├── Configure linting/testing
└── Establish conventions

Phase 2: Core Development (parallel)
├── Implement feature A
├── Implement feature B
├── Implement feature C
└── Set up infrastructure

Phase 3: Cross-Cutting Concerns
├── Authentication
├── Logging
├── Error handling
└── Monitoring

Phase 4: Integration
├── Wire features together
├── End-to-end tests
└── Documentation
```

### MVP-First Approach

```
Sprint 1: Minimal Viable
├── Core user flow only
├── No error handling yet
└── Deploy to staging

Sprint 2: Robustness
├── Error handling
├── Input validation
└── Edge cases

Sprint 3: Polish
├── Performance optimization
├── UX improvements
└── Production deploy
```

## Task Dependencies

Always define explicit dependencies:

```
Task Graph Example: E-commerce Checkout

[Product schema] ───┬──> [Cart service]
                    │
                    └──> [Inventory service] ───┐
                                                │
[Payment schema] ───┬──> [Payment service] ────┼──> [Checkout flow]
                    │                          │
                    └──> [Refund service]      │
                                                │
[User schema] ─────────> [Order service] ──────┘

Parallel Groups:
1. [Product schema], [Payment schema], [User schema]
2. [Cart], [Inventory], [Payment], [Refund], [Order] (after schemas)
3. [Checkout flow] (after all services)
```

## Quality Gates

Apply between phases:

```
After Implementation:
- [ ] All tests pass
- [ ] No linting errors
- [ ] Type checks clean
- [ ] No console.logs

After Integration:
- [ ] Integration tests pass
- [ ] E2E tests pass
- [ ] Performance acceptable
- [ ] Security review passed
```
