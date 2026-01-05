# Testing Orchestration

Patterns for test generation, execution, coverage analysis, and test maintenance.

## Test Generation

### Pattern: Coverage-Driven Generation

```
Phase 1: Coverage Analysis
└── Identify untested code paths

Phase 2: Test Generation (parallel)
├── Agent 1: Unit tests for utilities
├── Agent 2: Unit tests for services
├── Agent 3: Integration tests for APIs
└── Agent 4: E2E tests for critical flows

Phase 3: Verification
├── Run all tests
├── Validate coverage improvement
└── Check for flaky tests
```

### Test Type Strategy

| Test Type | Coverage Target | Orchestration |
|-----------|-----------------|---------------|
| **Unit** | Functions, utilities | High parallelism, many agents |
| **Integration** | Module interactions | Medium parallelism |
| **E2E** | User flows | Sequential or limited parallel |
| **Performance** | Critical paths | Background execution |

## Test Execution

### Pattern: Parallel Test Suites

```
Fan-Out (parallel execution):
├── Agent 1: Unit tests (fast)
├── Agent 2: Integration tests (medium)
├── Agent 3: E2E tests (slow)
└── Agent 4: Performance tests (background)

Aggregate:
→ Combine results
→ Identify failures
→ Generate report
```

### Background Execution

For long-running test suites:

```
Background:
└── Full test suite (10+ minutes)

Foreground (continues immediately):
├── Code review
├── Documentation
└── Other tasks

Sync Point:
→ Check test results before merge/deploy
```

## Coverage Analysis

### Pattern: Gap Identification

```
Phase 1: Coverage Report
└── Run coverage tool (nyc, jest --coverage)

Phase 2: Gap Analysis (parallel)
├── Agent 1: Identify uncovered functions
├── Agent 2: Find untested branches
├── Agent 3: Locate missing edge cases
└── Agent 4: Check error path coverage

Phase 3: Prioritization
→ Risk-based priority (high-impact code first)
→ Complexity-based priority (complex logic first)
→ Churn-based priority (frequently changed code first)

Phase 4: Test Generation
→ Parallel test creation for gaps
```

### Risk-Based Coverage

```
Priority Matrix:

High Complexity + Frequently Changed = Critical
├── Authentication logic
├── Payment processing
└── Core business rules

Low Complexity + Rarely Changed = Low Priority
├── Simple utilities
├── Static configurations
└── Wrapper functions
```

## Test Maintenance

### Pattern: Parallel Diagnosis

```
When tests fail:

Fan-Out (parallel investigation):
├── Agent 1: Analyze failing tests
├── Agent 2: Check for code changes
├── Agent 3: Review environment issues
└── Agent 4: Identify flaky tests

Fix (parallel where independent):
├── Fix broken tests
├── Update outdated mocks
├── Resolve environment issues
└── Quarantine flaky tests for later
```

### Test Refactoring

```
Phase 1: Analysis
├── Identify test code smells
├── Find duplicate test logic
└── Locate slow tests

Phase 2: Refactoring (parallel)
├── Agent 1: Extract test utilities
├── Agent 2: Consolidate fixtures
├── Agent 3: Optimize slow tests
└── Agent 4: Improve test readability

Phase 3: Verification
└── Ensure all tests still pass
```

## E2E Testing

### Pattern: User Journey Testing

```
Sequential by flow:

Journey: User Registration
├── Step 1: Visit registration page
├── Step 2: Fill form with valid data
├── Step 3: Submit and verify success
├── Step 4: Check email verification
└── Step 5: Complete verification

Journey: Checkout Process
├── Step 1: Add items to cart
├── Step 2: Proceed to checkout
├── Step 3: Enter payment details
├── Step 4: Complete purchase
└── Step 5: Verify order confirmation
```

### Cross-Browser Testing

```
Fan-Out (parallel browsers):
├── Chrome (Agent 1)
├── Firefox (Agent 2)
├── Safari (Agent 3)
└── Edge (Agent 4)

Each runs:
├── Critical user journeys
├── Responsive breakpoints
└── Accessibility checks

Aggregate:
→ Browser-specific issues
→ Consistent failures
→ Compatibility report
```

### Visual Regression

```
1. Capture baseline screenshots
2. Run after changes
3. Compare with baseline
4. Flag differences
├── Intentional changes → Update baseline
└── Unintentional changes → Fix regression
```

## Test Output Template

```markdown
## Test Results Summary

**Total**: [X] tests
**Passed**: [Y] ([Y/X]%)
**Failed**: [Z]
**Skipped**: [W]
**Duration**: [time]

### Failures

#### [Test Name]
- **File**: [path:line]
- **Error**: [error message]
- **Root Cause**: [analysis]
- **Fix**: [recommendation]

### Coverage

| Category | Current | Target | Status |
|----------|---------|--------|--------|
| Lines | X% | Y% | [met/unmet] |
| Branches | X% | Y% | [met/unmet] |
| Functions | X% | Y% | [met/unmet] |

### Recommendations
1. [Priority action items]
```

## Best Practices

### Test Organization

```
tests/
├── unit/           # Fast, isolated tests
│   ├── services/
│   └── utils/
├── integration/    # Module interaction tests
│   └── api/
├── e2e/           # End-to-end flows
│   └── journeys/
├── fixtures/      # Shared test data
└── helpers/       # Test utilities
```

### Performance Guidelines

| Test Type | Target Time | Strategy |
|-----------|-------------|----------|
| Unit | < 10ms each | Mock external deps |
| Integration | < 100ms each | Use test database |
| E2E | < 30s each | Parallel when possible |

### Flaky Test Handling

```
1. Identify flaky tests (fails sometimes, passes sometimes)
2. Quarantine immediately
3. Investigate root cause
├── Race conditions
├── Time-dependent logic
├── External dependencies
└── Resource contention
4. Fix and un-quarantine
```
