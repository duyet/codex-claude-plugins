# Orchestration Examples

Real-world workflow demonstrations showing internal orchestration and user experience.

## Example 1: PR Review

### User Request
"Review this PR for issues"

### Orchestration Strategy
**Pattern**: Fan-Out → Reduce

### Internal Flow
```
Phase 1: Fan-Out (parallel analysis)
├── Agent 1: Code quality (style, patterns, complexity)
├── Agent 2: Security (vulnerabilities, input validation)
├── Agent 3: Performance (algorithms, queries, caching)
└── Agent 4: Test coverage (missing tests, edge cases)

Phase 2: Reduce (synthesis)
→ Prioritize findings by severity
→ Deduplicate overlapping issues
→ Create unified review with actionable feedback
```

### User Experience
```
User: "Review this PR for issues"

Claude: "On it. Analyzing code quality, security, and performance..."

[~30 seconds later]

Claude: "Review complete. Found 3 issues to address:

## Critical
1. SQL injection vulnerability in user_search.py:45
   → Use parameterized queries instead of string concatenation

## Important
2. N+1 query pattern in get_orders()
   → Add prefetch_related for order items

## Suggested
3. Consider extracting duplicate validation logic to shared helper

All tests pass. Security and performance otherwise look solid.

─── Orchestrating ── PR review complete ─────"
```

---

## Example 2: Feature Implementation

### User Request
"Add user authentication with email/password and OAuth"

### Orchestration Strategy
**Pattern**: Pipeline → Fan-Out → Pipeline

### Internal Flow
```
Phase 1: Pipeline (research & design)
├── Research: Explore existing auth patterns in codebase
└── Design: Plan architecture, API contracts, component structure

Phase 2: Fan-Out (parallel implementation)
├── Agent 1: Database schema and migrations
├── Agent 2: Backend auth service (JWT, sessions)
├── Agent 3: OAuth provider integration
├── Agent 4: Frontend login/register components
└── Agent 5: Email verification flow

Phase 3: Pipeline (integration & validation)
├── Integrate: Wire components together
├── Test: Integration tests, E2E tests
└── Document: API docs, setup instructions
```

### User Experience
```
User: "Add user authentication with email/password and OAuth"

Claude: "Great feature. A few questions to nail this down:"

[AskUserQuestion with options for:
 - OAuth providers (Google, GitHub, etc.)
 - Session strategy (JWT, cookies, etc.)
 - Password requirements
 - Email verification needs]

User: [Selects options]

Claude: "Perfect. Breaking this into phases:
- Phase 1: Research patterns and design architecture
- Phase 2: Build components in parallel
- Phase 3: Integration and testing

Starting with research..."

[Later]

Claude: "Phase 1 complete. Proposed architecture:
- JWT tokens with refresh flow
- Separate auth service module
- OAuth via next-auth with custom providers
- Prisma schema extending existing User model

Proceeding with parallel implementation..."

[Later]

Claude: "Phase 2 complete. All components built:
- Database: 3 new tables, migrations ready
- Auth service: login, register, refresh, logout
- OAuth: Google and GitHub configured
- Frontend: Login, Register, ForgotPassword pages
- Email: Verification and reset flows

Starting integration..."

[Final]

Claude: "Authentication system complete.

## Summary
- Email/password auth with JWT
- OAuth (Google, GitHub)
- Email verification
- Password reset flow

## Files Changed
- 12 new files
- 4 modified files
- 3 database migrations

## Next Steps
1. Run migrations: `pnpm db:migrate`
2. Add env vars: GOOGLE_ID, GOOGLE_SECRET, etc.
3. Test auth flows locally

─── Orchestrating ── auth implementation complete ─────"
```

---

## Example 3: Bug Diagnosis

### User Request
"The dashboard is loading slowly, sometimes takes 10+ seconds"

### Orchestration Strategy
**Pattern**: Fan-Out (investigation) → Speculative (hypotheses) → Pipeline (fix)

### Internal Flow
```
Phase 1: Fan-Out (parallel investigation)
├── Agent 1: Analyze database queries
├── Agent 2: Check API response times
├── Agent 3: Review frontend rendering
└── Agent 4: Examine network requests

Phase 2: Speculative (if multiple causes found)
├── Hypothesis 1: Database N+1 queries
├── Hypothesis 2: Missing API caching
└── Hypothesis 3: Heavy client-side computation

Phase 3: Pipeline (implement fix)
├── Apply fix for primary cause
├── Test performance improvement
└── Document findings
```

### User Experience
```
User: "The dashboard is loading slowly, sometimes takes 10+ seconds"

Claude: "Let me investigate. Checking database, API, frontend, and network..."

[Later]

Claude: "Found the culprit. Multiple issues, but one is critical:

## Root Cause
The `getDashboardStats` query runs 47 separate database calls (N+1 problem).
Each widget fetches its data independently without batching.

## Contributing Factors
- No caching layer (every load hits DB)
- Large JSON payloads (500KB+ per request)

## Fix Applied
1. Batched queries using DataLoader pattern
2. Added 5-minute cache for stats that update infrequently
3. Optimized payload with field selection

## Results
- Before: 10-12 seconds
- After: ~400ms
- 96% improvement

Want me to add real-time updates for time-sensitive widgets?

─── Orchestrating ── performance fix complete ─────"
```

---

## Example 4: Codebase Understanding

### User Request
"Help me understand how this codebase is organized"

### Orchestration Strategy
**Pattern**: Fan-Out → Reduce

### Internal Flow
```
Fan-Out (parallel exploration):
├── Agent 1: Directory structure and conventions
├── Agent 2: Core architecture patterns
├── Agent 3: Data flow and state management
├── Agent 4: API and service boundaries
└── Agent 5: Build and deployment setup

Reduce:
→ Synthesize into comprehensive overview
→ Create mental model diagram
→ Highlight key patterns and conventions
```

### User Experience
```
User: "Help me understand how this codebase is organized"

Claude: "Exploring the codebase structure, patterns, and conventions..."

[Later]

Claude: "Here's how this codebase works:

## Architecture
Monorepo with 3 packages:
- `apps/web` - Next.js 14 frontend
- `apps/api` - Express backend
- `packages/shared` - Common types/utils

## Key Patterns

**Frontend**
- Feature-based organization (`/features/auth`, `/features/dashboard`)
- Container/presenter component pattern
- React Query for server state
- Zustand for client state

**Backend**
- Layered: routes → controllers → services → repositories
- Dependency injection via tsyringe
- Prisma for database access

**Shared**
- Zod schemas for validation (shared between FE/BE)
- Type-safe API contracts

## Data Flow
1. Frontend calls API via React Query hooks
2. API validates with Zod, processes in service layer
3. Repository handles Prisma operations
4. Response flows back with consistent error handling

## Conventions
- Files: kebab-case
- Components: PascalCase
- Hooks: use prefix
- API routes: RESTful with /api/v1 prefix

Where would you like to dive deeper?

─── Orchestrating ── codebase overview complete ─────"
```

---

## Example 5: Test Management

### User Request
"Tests are failing in CI. Fix them and make sure coverage is good"

### Orchestration Strategy
**Pattern**: Background (test run) + Fan-Out (investigation/fixes)

### Internal Flow
```
Background:
└── Full test suite (to see current state)

Fan-Out (parallel):
├── Agent 1: Analyze failing unit tests
├── Agent 2: Analyze failing integration tests
├── Agent 3: Check test environment issues
└── Agent 4: Review recent changes that might have broken tests

After investigation:
Fan-Out (parallel fixes):
├── Agent 1: Fix unit test issues
├── Agent 2: Fix integration test issues
└── Agent 3: Add missing test coverage

Final:
└── Verify all tests pass
```

### User Experience
```
User: "Tests are failing in CI. Fix them and make sure coverage is good"

Claude: "Running the test suite while I investigate the failures..."

[Later]

Claude: "Found the issues. Here's what went wrong:

## Failing Tests (7 total)

**Unit Tests (4 failures)**
- `user.service.test.ts`: Mock not updated after refactor
- `auth.utils.test.ts`: Edge case not handled for empty token

**Integration Tests (3 failures)**
- Database connection timeout (env issue in CI)
- API contract changed but tests not updated

## Fixes Applied
1. Updated user service mocks
2. Added null check for empty token
3. Fixed CI database connection string
4. Updated API tests for new contract

## Coverage Improvement
- Before: 72%
- After: 84%
- Added tests for uncovered auth edge cases

All 127 tests now passing. CI should be green.

─── Orchestrating ── tests fixed, coverage improved ─────"
```

---

## Pattern Quick Reference

| Scenario | Pattern | Phases |
|----------|---------|--------|
| PR Review | Fan-Out → Reduce | Parallel analysis → Synthesis |
| Feature Build | Pipeline → Fan-Out → Pipeline | Research → Parallel impl → Integration |
| Bug Diagnosis | Fan-Out → Speculative → Pipeline | Investigate → Hypothesize → Fix |
| Codebase Understanding | Fan-Out → Reduce | Explore → Synthesize |
| Test Management | Background + Fan-Out | Run suite → Parallel fixes |
| Refactoring | Map-Reduce | Distribute changes → Verify consistency |
| Migration | Pipeline → Map-Reduce | Plan → Parallel migrate → Validate |
