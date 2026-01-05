# Orchestration Plugin

Transform complex requests into coordinated multi-agent execution with elegant result synthesis.

## Overview

This plugin enables Claude to operate as **the Conductor** - orchestrating parallel agent workstreams to handle complex requests efficiently. Instead of sequential execution, work is decomposed into parallel tasks that execute simultaneously.

## Core Concept

```
Traditional: A → B → C → D (sequential, slow)

Orchestrated:
├── A ───┐
├── B ───┼──> Synthesize → Result (parallel, fast)
└── C ───┘
```

## Key Features

- **Parallel Execution** - Multiple agents work simultaneously
- **Task Graph Management** - Dependencies handled automatically
- **Result Synthesis** - Outputs merged into coherent responses
- **Domain-Specific Patterns** - Optimized workflows for different task types

## Orchestration Patterns

| Pattern | Use Case |
|---------|----------|
| **Fan-Out** | Independent parallel analysis |
| **Pipeline** | Sequential processing stages |
| **Map-Reduce** | Distribute work, aggregate results |
| **Speculative** | Try multiple approaches, pick best |
| **Background** | Long-running + immediate work |

## Domain Guides

Pre-built patterns for common workflows:

- **Software Development** - Feature implementation, bug fixing, refactoring
- **Code Review** - Multi-dimensional PR analysis
- **Research** - Codebase exploration, root cause analysis
- **Testing** - Test generation, coverage, maintenance
- **Documentation** - API docs, READMEs, architecture docs
- **DevOps** - CI/CD, deployment, infrastructure
- **Data Analysis** - Exploration, quality, reporting
- **Project Management** - Epic breakdown, sprint planning

## Skill Structure

```
orchestration/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── orchestration/
│       ├── SKILL.md           # Main skill definition
│       └── references/
│           ├── guide.md       # User guide
│           ├── patterns.md    # Orchestration patterns
│           ├── tools.md       # Tool usage reference
│           ├── examples.md    # Real-world examples
│           └── domains/       # Domain-specific guides
│               ├── software-development.md
│               ├── code-review.md
│               ├── research.md
│               ├── testing.md
│               ├── documentation.md
│               ├── devops.md
│               ├── data-analysis.md
│               └── project-management.md
└── README.md
```

## Usage

The skill activates automatically for complex multi-component requests. For explicit activation:

```
/orchestration [your complex request]
```

## Example

```
User: "Review this PR for issues and add tests for uncovered code"

Claude (orchestrating):
├── Agent 1: Code quality review
├── Agent 2: Security analysis
├── Agent 3: Performance check
├── Agent 4: Coverage analysis
└── Agent 5: Generate tests

→ Synthesized review with prioritized findings and new tests
```

## Key Principles

1. **Decompose** - Break work into independent tasks
2. **Parallelize** - Execute unblocked tasks simultaneously
3. **Synthesize** - Merge results into coherent output
4. **Hide Machinery** - Users see magic, not implementation
