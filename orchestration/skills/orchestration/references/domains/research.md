# Research Orchestration

Patterns for investigating codebases, exploring technical systems, and synthesizing findings.

## Codebase Exploration

### Pattern: Fan-Out Discovery

```
Fan-Out (parallel exploration):
├── Agent 1: Project Structure
│   ├── Directory organization
│   ├── File naming conventions
│   └── Module boundaries
│
├── Agent 2: Build & Dependencies
│   ├── Package management
│   ├── Build configuration
│   └── External dependencies
│
├── Agent 3: Architecture Patterns
│   ├── Design patterns used
│   ├── Data flow
│   └── State management
│
├── Agent 4: Testing Strategy
│   ├── Test organization
│   ├── Coverage approach
│   └── Testing tools
│
└── Agent 5: Documentation
    ├── README quality
    ├── Inline comments
    └── API documentation

Reduce:
→ Create mental model
→ Identify key patterns
→ Document conventions
```

## Feature Tracing

### Pattern: End-to-End Flow

```
Trace complete feature flow:

Entry Point
    ↓
├── Route/Endpoint handler
├── Middleware processing
├── Business logic layer
├── Data access layer
└── Response formation

For each layer:
├── Identify key files
├── Note dependencies
├── Document data transformations
└── Map error handling paths
```

### Example: Authentication Flow

```
Login Request
    ↓
[API Route: /api/auth/login]
    ↓
[Middleware: rateLimiter, validateBody]
    ↓
[Controller: AuthController.login]
    ↓
[Service: AuthService.authenticate]
    ├── UserRepository.findByEmail
    ├── PasswordService.verify
    └── TokenService.generate
    ↓
[Response: { token, user }]
```

## Root Cause Analysis

### Pattern: Hypothesis-Driven Investigation

```
Phase 1: Evidence Gathering (parallel)
├── Agent 1: Analyze error logs
├── Agent 2: Review related code
├── Agent 3: Check configuration
└── Agent 4: Examine recent changes

Phase 2: Hypothesis Formation
→ Synthesize evidence into hypotheses
→ Rank by probability

Phase 3: Hypothesis Validation
├── Test most likely hypothesis first
├── Gather confirming/disconfirming evidence
└── Refine or pivot based on results

Phase 4: Root Cause Documentation
→ Causal chain from trigger to symptom
→ Contributing factors
→ Prevention recommendations
```

## Dependency Analysis

### Pattern: Graph Building

```
Build dependency graph:

1. Direct Dependencies
├── Package.json / requirements.txt
├── Import statements
└── Runtime dependencies

2. Transitive Dependencies
├── Dependency tree depth
├── Version conflicts
└── Security vulnerabilities

3. Internal Dependencies
├── Module coupling
├── Circular dependencies
└── Interface contracts
```

### Impact Assessment

```
When evaluating changes:

1. Identify changed module
2. Find all dependents (reverse deps)
3. Assess impact scope
├── Direct callers
├── Transitive callers
└── Test coverage of affected paths
4. Categorize risk level
```

## Technology Evaluation

### Pattern: Multi-Criteria Analysis

```
Fan-Out (evaluation criteria):
├── Agent 1: Technical Fit
│   ├── Feature requirements
│   ├── Performance needs
│   └── Integration complexity
│
├── Agent 2: Ecosystem
│   ├── Community size
│   ├── Documentation quality
│   └── Third-party support
│
├── Agent 3: Operational
│   ├── Maintenance burden
│   ├── Monitoring/debugging
│   └── Deployment complexity
│
└── Agent 4: Risk Assessment
    ├── Vendor lock-in
    ├── Long-term viability
    └── Security track record

Reduce:
→ Weighted scoring matrix
→ Trade-off summary
→ Recommendation with rationale
```

## Research Output Template

```markdown
## Investigation: [Topic/Question]

### Summary
[2-3 sentence executive summary]

### Methodology
[How the investigation was conducted]

### Findings

#### [Finding Category 1]
- **Evidence**: [file:line references, logs, metrics]
- **Analysis**: [interpretation of evidence]
- **Confidence**: [High | Medium | Low]

#### [Finding Category 2]
[...]

### Synthesis
[How findings connect, overall picture]

### Recommendations
1. [Actionable recommendation with rationale]
2. [...]

### Open Questions
- [Areas needing further investigation]

### References
- [file paths, documentation, external sources]
```

## Research Best Practices

### Evidence Standards

| Confidence | Criteria |
|------------|----------|
| **High** | Multiple corroborating sources, verified through testing |
| **Medium** | Single reliable source, logically consistent |
| **Low** | Inference from partial evidence, requires verification |

### Citation Approach

Always include:
- File paths with line numbers
- Commit references when relevant
- Documentation links
- External source URLs

### Uncertainty Handling

Be explicit about:
- What is known vs inferred
- Confidence levels
- Alternative interpretations
- Areas needing further investigation
