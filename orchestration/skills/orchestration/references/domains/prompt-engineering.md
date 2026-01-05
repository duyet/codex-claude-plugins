# Prompt Engineering Orchestration

Patterns for designing, testing, and optimizing prompts for LLM applications.

## Core Philosophy

Effective prompts are iteratively refined through systematic testing. Parallel experimentation accelerates discovery.

## Prompt Design

### Pattern: Multi-Perspective Drafting

```
Fan-Out (parallel approaches):
├── Agent 1: Direct instruction approach
│   ├── Clear, imperative commands
│   ├── Step-by-step structure
│   └── Explicit constraints
│
├── Agent 2: Few-shot example approach
│   ├── Input/output examples
│   ├── Edge case demonstrations
│   └── Format templates
│
├── Agent 3: Chain-of-thought approach
│   ├── Reasoning scaffolding
│   ├── Intermediate steps
│   └── Self-verification
│
└── Agent 4: Role-based approach
    ├── Persona definition
    ├── Expertise framing
    └── Context setting

Reduce:
→ Compare effectiveness
→ Hybrid best elements
→ Final optimized prompt
```

### Prompt Structure Template

```markdown
## [Task Name] Prompt

### System Context
[Role, capabilities, constraints]

### Task Definition
[Clear objective with success criteria]

### Input Format
[Expected input structure]

### Output Format
[Required output structure with examples]

### Examples (if few-shot)
Input: [example input]
Output: [example output]

### Constraints
[Boundaries, forbidden actions, edge cases]

### Evaluation Criteria
[How to measure success]
```

## Prompt Testing

### Pattern: Parallel Evaluation

```
Fan-Out (test dimensions):
├── Agent 1: Correctness testing
│   ├── Expected outputs match
│   ├── Edge cases handled
│   └── Error cases graceful
│
├── Agent 2: Robustness testing
│   ├── Input variations
│   ├── Adversarial inputs
│   └── Boundary conditions
│
├── Agent 3: Consistency testing
│   ├── Same input → same output
│   ├── Temperature sensitivity
│   └── Model version stability
│
└── Agent 4: Performance testing
    ├── Token efficiency
    ├── Latency impact
    └── Cost analysis

Reduce:
→ Test report with pass/fail
→ Failure analysis
→ Improvement recommendations
```

### Test Suite Structure

```
tests/
├── correctness/
│   ├── basic_functionality.json
│   ├── edge_cases.json
│   └── expected_outputs.json
├── robustness/
│   ├── input_variations.json
│   ├── adversarial.json
│   └── malformed_inputs.json
├── consistency/
│   ├── determinism_tests.json
│   └── version_compatibility.json
└── performance/
    ├── token_counts.json
    └── latency_benchmarks.json
```

## Prompt Optimization

### Pattern: Iterative Refinement

```
Phase 1: Baseline Measurement
├── Run current prompt on test suite
├── Record metrics (accuracy, tokens, latency)
└── Identify failure patterns

Phase 2: Hypothesis Generation (parallel)
├── Agent 1: Analyze failure patterns
├── Agent 2: Research similar prompts
├── Agent 3: Generate variations
└── Agent 4: Propose structural changes

Phase 3: A/B Testing (parallel)
├── Test variation A
├── Test variation B
├── Test variation C
└── Compare against baseline

Phase 4: Selection
→ Statistical significance analysis
→ Select best performer
→ Document learnings
```

### Optimization Techniques

| Technique | When to Use | Impact |
|-----------|-------------|--------|
| **Instruction clarity** | Ambiguous outputs | High |
| **Few-shot examples** | Format issues | High |
| **Chain-of-thought** | Reasoning errors | Medium-High |
| **Output constraints** | Format violations | Medium |
| **Context pruning** | Token efficiency | Medium |
| **Role prompting** | Tone/style issues | Low-Medium |

## System Prompt Design

### Pattern: Layered Architecture

```
Layer 1: Core Identity
├── Role definition
├── Primary capabilities
└── Fundamental constraints

Layer 2: Behavioral Guidelines
├── Communication style
├── Decision-making approach
└── Error handling

Layer 3: Domain Knowledge
├── Specific expertise areas
├── Tool usage patterns
└── Integration points

Layer 4: Output Formatting
├── Response structure
├── Code formatting
└── Citation style
```

### System Prompt Template

```markdown
# [Agent Name]

## Identity
You are [role] specialized in [domain]. Your purpose is [objective].

## Capabilities
You can:
- [Capability 1]
- [Capability 2]
- [Capability 3]

## Constraints
You must:
- [Constraint 1]
- [Constraint 2]

You must never:
- [Forbidden action 1]
- [Forbidden action 2]

## Communication Style
[Tone, verbosity, formatting preferences]

## Tool Usage
When using [tool], always:
- [Guideline 1]
- [Guideline 2]

## Output Format
[Default response structure]
```

## Chain-of-Thought Design

### Pattern: Reasoning Scaffolding

```
Fan-Out (reasoning approaches):
├── Agent 1: Step-by-step decomposition
│   └── "Let's break this down step by step..."
│
├── Agent 2: Question-driven reasoning
│   └── "First, what do we know? What do we need?"
│
├── Agent 3: Analogy-based reasoning
│   └── "This is similar to... so we can..."
│
└── Agent 4: Verification-integrated
    └── "Let me verify each step..."

Reduce:
→ Test each on reasoning tasks
→ Select best for use case
→ Combine if complementary
```

### CoT Templates

```markdown
## Zero-Shot CoT
"Let's think through this step by step:
1. First, I'll identify...
2. Then, I'll analyze...
3. Finally, I'll conclude..."

## Self-Consistency CoT
"I'll approach this multiple ways:
Approach 1: [reasoning path A]
Approach 2: [reasoning path B]
Consensus: [synthesized answer]"

## Verification CoT
"My reasoning:
Step 1: [reasoning]
Verification: [check step 1]
Step 2: [reasoning]
Verification: [check step 2]
Final answer: [conclusion]"
```

## Multi-Agent Prompt Systems

### Pattern: Coordinated Agents

```
Orchestrator Prompt:
├── Task decomposition logic
├── Agent selection criteria
├── Result synthesis rules
└── Error handling

Worker Agent Prompts:
├── Specialized capabilities
├── Scope limitations
├── Output format requirements
└── Handoff protocols

Communication Protocol:
├── Input/output contracts
├── Status signaling
├── Error reporting
└── Completion criteria
```

### Agent Coordination Template

```markdown
## Orchestrator System Prompt

You coordinate multiple specialized agents. For each request:

1. ANALYZE the request complexity
2. DECOMPOSE into subtasks
3. ASSIGN to appropriate agents
4. SYNTHESIZE results

### Agent Selection
- [Agent A]: Use for [capability A]
- [Agent B]: Use for [capability B]
- [Agent C]: Use for [capability C]

### Synthesis Rules
- Prioritize by [criteria]
- Resolve conflicts by [method]
- Format output as [structure]
```

## Evaluation Frameworks

### Pattern: Multi-Metric Assessment

```
Fan-Out (evaluation dimensions):
├── Agent 1: Task completion
│   ├── Objective achieved
│   ├── Requirements met
│   └── Success rate
│
├── Agent 2: Quality metrics
│   ├── Accuracy
│   ├── Coherence
│   └── Relevance
│
├── Agent 3: Efficiency metrics
│   ├── Token usage
│   ├── Latency
│   └── Cost per query
│
└── Agent 4: Safety metrics
    ├── Harmful content
    ├── Bias detection
    └── Hallucination rate

Reduce:
→ Weighted scorecard
→ Comparison to baseline
→ Improvement recommendations
```

### Evaluation Rubric

| Dimension | Excellent (5) | Good (4) | Fair (3) | Poor (2) | Fail (1) |
|-----------|---------------|----------|----------|----------|----------|
| Accuracy | 100% correct | Minor issues | Some errors | Major errors | Wrong |
| Relevance | Perfectly on-topic | Mostly relevant | Partially relevant | Tangential | Off-topic |
| Format | Perfect adherence | Minor deviations | Some issues | Major issues | Ignored |
| Efficiency | Minimal tokens | Reasonable | Some waste | Verbose | Excessive |

## Best Practices

### Prompt Development Workflow

```
1. Define clear success criteria
2. Start with simple, direct prompt
3. Test on diverse examples
4. Identify failure modes
5. Iterate based on evidence
6. A/B test improvements
7. Document final prompt with rationale
```

### Common Anti-Patterns

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Vague instructions | Inconsistent outputs | Be specific and explicit |
| Over-prompting | Token waste, confusion | Prune unnecessary context |
| No examples | Format issues | Add 2-3 clear examples |
| Ignoring edge cases | Failures in production | Test adversarial inputs |
| No constraints | Unwanted behaviors | Add explicit boundaries |

### Version Control

```
prompts/
├── v1.0.0/
│   ├── system.md
│   ├── test_results.json
│   └── changelog.md
├── v1.1.0/
│   ├── system.md
│   ├── test_results.json
│   └── changelog.md
└── current -> v1.1.0
```
