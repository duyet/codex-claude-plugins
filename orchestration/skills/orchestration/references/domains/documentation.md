# Documentation Orchestration

Patterns for generating comprehensive documentation using parallel processing.

## Core Philosophy

Good documentation is parallel-friendly. Multiple sections generated simultaneously, synthesized into coherent narrative.

## API Documentation

### Pattern: Three-Phase Generation

```
Phase 1: Discovery (parallel)
├── Agent 1: Scan route definitions
├── Agent 2: Extract request/response schemas
├── Agent 3: Identify authentication requirements
└── Agent 4: Catalog error responses

Phase 2: Generation (parallel by domain)
├── Agent 1: /users/* endpoints
├── Agent 2: /products/* endpoints
├── Agent 3: /orders/* endpoints
└── Agent 4: /auth/* endpoints

Phase 3: Compilation
→ Unified OpenAPI/Swagger spec
→ Consistent formatting
→ Cross-reference verification
```

### OpenAPI Structure

```yaml
# Generated structure
openapi: 3.0.0
paths:
  /users:
    get:
      summary: List users
      parameters: [...]
      responses:
        200:
          description: Success
          content:
            application/json:
              schema: [...]
        401:
          description: Unauthorized
```

## Code Documentation

### Pattern: Batch Generation

```
Fan-Out (parallel by module):
├── Agent 1: Document services/
├── Agent 2: Document utils/
├── Agent 3: Document components/
└── Agent 4: Document hooks/

Per Agent:
├── Extract function signatures
├── Analyze usage patterns
├── Generate JSDoc/docstrings
└── Add inline comments for complex logic

Verification:
→ Consistency check across modules
→ Link verification
→ Example validation
```

### Documentation Standards

```typescript
/**
 * Authenticates a user with email and password.
 *
 * @param email - User's email address
 * @param password - Plain text password (hashed internally)
 * @returns Authentication result with token and user data
 * @throws {AuthError} When credentials are invalid
 * @throws {RateLimitError} When too many attempts
 *
 * @example
 * ```typescript
 * const result = await authenticate('user@example.com', 'password123');
 * if (result.success) {
 *   setToken(result.token);
 * }
 * ```
 */
async function authenticate(email: string, password: string): Promise<AuthResult>
```

## README Generation

### Pattern: Parallel Information Gathering

```
Fan-Out (parallel exploration):
├── Agent 1: Project structure & organization
├── Agent 2: Dependencies & requirements
├── Agent 3: Scripts & commands
└── Agent 4: Configuration & environment

Synthesis:
→ Installation instructions
→ Quick start guide
→ Configuration reference
→ Contributing guidelines
```

### README Structure

```markdown
# Project Name

[One-line description]

## Quick Start
[3-step getting started]

## Installation
[Detailed setup instructions]

## Usage
[Common use cases with examples]

## Configuration
[Environment variables, config files]

## Development
[Local setup, testing, contributing]

## Architecture
[High-level system overview]

## API Reference
[Link to detailed docs]

## License
[License info]
```

## Architecture Documentation

### Pattern: C4 Model Approach

```
Fan-Out (abstraction levels):
├── Agent 1: Context (system in environment)
├── Agent 2: Containers (major components)
├── Agent 3: Components (internal structure)
└── Agent 4: Code (key implementation details)

Each level documents:
├── Visual diagram (Mermaid/PlantUML)
├── Component descriptions
├── Interactions and data flows
└── Technology choices
```

### C4 Templates

```markdown
## Level 1: System Context
[Diagram showing system and external actors]

### External Systems
| System | Description | Integration |
|--------|-------------|-------------|
| Payment Gateway | Handles transactions | REST API |

## Level 2: Container Diagram
[Diagram showing major containers]

### Containers
| Container | Technology | Purpose |
|-----------|------------|---------|
| Web App | Next.js | User interface |
| API | Express | Business logic |
| Database | PostgreSQL | Data storage |

## Level 3: Component Diagram
[Diagram showing internal components]

## Level 4: Code
[Key classes/modules with relationships]
```

## User Guides

### Pattern: Feature-Parallel

```
Fan-Out (parallel by feature):
├── Agent 1: Authentication guide
├── Agent 2: Dashboard guide
├── Agent 3: Settings guide
└── Agent 4: Admin guide

Each guide includes:
├── Feature overview
├── Step-by-step instructions
├── Screenshots/examples
├── Common issues
└── FAQ section

Consolidation:
→ Unified table of contents
→ Cross-references
→ Troubleshooting appendix
```

## Quality Assurance

### Pattern: Consistency Audit

```
Fan-Out (parallel checks):
├── Agent 1: Terminology consistency
├── Agent 2: Formatting standards
├── Agent 3: Code example validation
└── Agent 4: Link verification

Issues categorized:
├── Terminology: Inconsistent terms
├── Formatting: Style violations
├── Code: Broken examples
└── Links: Dead references
```

### Freshness Check

```
Fan-Out (parallel validation):
├── Agent 1: Check examples against current code
├── Agent 2: Verify configuration options
├── Agent 3: Validate API endpoint descriptions
└── Agent 4: Check version references

Flag:
├── Outdated examples
├── Deprecated features still documented
├── Missing new features
└── Version mismatches
```

## Documentation Output Template

```markdown
## [Document Title]

### Overview
[Purpose and audience]

### [Section 1]
[Content with examples]

#### Subsection
[Detailed content]

```code
[Working example]
```

### [Section 2]
[Content]

### Troubleshooting
| Issue | Cause | Solution |
|-------|-------|----------|
| [problem] | [reason] | [fix] |

### Related
- [Link to related doc]
- [External resource]

---
Last updated: [date]
```

## Best Practices

### Writing Guidelines

| Do | Don't |
|----|-------|
| Use active voice | Use passive voice |
| Show working examples | Show theoretical examples |
| Keep sentences short | Write long paragraphs |
| Use consistent terms | Use synonyms freely |
| Link to related docs | Duplicate information |

### Maintenance Strategy

```
Regular cadence:
├── Weekly: Link checking
├── Monthly: Example validation
├── Quarterly: Full content review
└── Per release: Update for changes
```
