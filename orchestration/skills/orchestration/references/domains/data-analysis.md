# Data Analysis Orchestration

Patterns for exploring data, ensuring quality, and generating insights.

## Core Philosophy

Data yields insights faster when explored in parallel. Multiple dimensions, simultaneous analysis, clear story.

## Exploratory Analysis

### Pattern: Multi-Dimensional Discovery

```
Fan-Out (parallel exploration):
├── Agent 1: Schema Analysis
│   ├── Table structures
│   ├── Column types
│   └── Relationships
│
├── Agent 2: Statistical Profile
│   ├── Distributions
│   ├── Central tendencies
│   └── Outliers
│
├── Agent 3: Missing Data Analysis
│   ├── Null patterns
│   ├── Empty values
│   └── Implicit missingness
│
└── Agent 4: Cardinality Check
    ├── Unique values
    ├── Value frequencies
    └── Key candidates

Reduce:
→ Data quality score
→ Key insights
→ Recommended next steps
```

### Analysis Workflow

```
1. Initial scan (fast, parallel)
├── Row counts
├── Column inventory
└── Quick distributions

2. Deep dive (focused, parallel)
├── Interesting columns
├── Anomalous patterns
└── Relationship hypotheses

3. Synthesis (sequential)
├── Connect findings
├── Form narrative
└── Identify actions
```

## Data Quality

### Pattern: Six-Dimension Audit

```
Fan-Out (quality dimensions):
├── Agent 1: Completeness
│   ├── Missing values percentage
│   ├── Required fields coverage
│   └── Record completeness
│
├── Agent 2: Accuracy
│   ├── Value validity
│   ├── Range checks
│   └── Format compliance
│
├── Agent 3: Consistency
│   ├── Cross-field rules
│   ├── Referential integrity
│   └── Duplicate detection
│
├── Agent 4: Timeliness
│   ├── Data freshness
│   ├── Update frequency
│   └── Latency metrics
│
├── Agent 5: Uniqueness
│   ├── Key uniqueness
│   ├── Near-duplicates
│   └── Identity matching
│
└── Agent 6: Validity
    ├── Domain constraints
    ├── Business rules
    └── External validation

Reduce:
→ Quality scorecard
→ Issue priority list
→ Remediation plan
```

### Quality Remediation

```
After issues identified:

Fan-Out (parallel fixes):
├── Agent 1: Missing value imputation
├── Agent 2: Outlier handling
├── Agent 3: Duplicate resolution
└── Agent 4: Format standardization

Verification:
→ Re-run quality checks
→ Compare before/after metrics
→ Document decisions
```

## Report Generation

### Pattern: Section-Parallel

```
Fan-Out (parallel sections):
├── Agent 1: Executive summary
├── Agent 2: Methodology
├── Agent 3: Key findings
├── Agent 4: Detailed analysis
├── Agent 5: Visualizations
└── Agent 6: Recommendations

Integration:
→ Consistent formatting
→ Cross-references
→ Narrative flow
```

### Report Template

```markdown
## Data Analysis Report: [Topic]

### Executive Summary
[Key findings in 3 bullets]

### Data Overview
| Metric | Value |
|--------|-------|
| Records | [count] |
| Time range | [start] - [end] |
| Sources | [list] |

### Methodology
[How analysis was conducted]

### Key Findings

#### Finding 1: [Title]
[Description with supporting data]
[Visualization]

#### Finding 2: [Title]
[...]

### Recommendations
1. [Actionable recommendation]
2. [...]

### Appendix
[Detailed tables, additional charts]
```

## ETL Development

### Pattern: Explore-Plan-Build

```
Phase 1: Exploration (parallel)
├── Agent 1: Source system analysis
├── Agent 2: Target schema review
├── Agent 3: Transformation requirements
└── Agent 4: Data volume assessment

Phase 2: Planning
→ Mapping document
→ Transformation logic
→ Error handling strategy

Phase 3: Implementation (parallel)
├── Agent 1: Extraction logic
├── Agent 2: Transformation code
├── Agent 3: Loading procedures
└── Agent 4: Validation rules

Phase 4: Verification
├── Unit tests
├── Integration tests
└── Data reconciliation
```

## Statistical Analysis

### Pattern: Hypothesis-Driven

```
Phase 1: Exploratory
├── Descriptive statistics
├── Distribution analysis
└── Correlation matrix

Phase 2: Hypothesis Testing (parallel)
├── Agent 1: Test hypothesis A
├── Agent 2: Test hypothesis B
└── Agent 3: Test hypothesis C

Phase 3: Modeling (if applicable)
├── Feature selection
├── Model training
├── Validation

Phase 4: Conclusions
→ Statistical significance
→ Effect sizes
→ Confidence intervals
```

### Statistical Output

```markdown
## Statistical Analysis: [Question]

### Hypothesis
H0: [Null hypothesis]
H1: [Alternative hypothesis]

### Method
[Test used and why]

### Results
| Metric | Value |
|--------|-------|
| Test statistic | [value] |
| p-value | [value] |
| Effect size | [value] |
| 95% CI | [range] |

### Interpretation
[What the results mean]

### Limitations
[Caveats and assumptions]
```

## Best Practices

### Analysis Principles

| Do | Don't |
|----|-------|
| State assumptions explicitly | Hide methodology |
| Report confidence levels | Overstate certainty |
| Visualize distributions | Only show averages |
| Check for sampling bias | Assume representativeness |
| Document transformations | Apply undocumented filters |

### Reproducibility

```
For every analysis:
├── Document data sources
├── Version control code
├── Record random seeds
├── Save intermediate results
└── Note environment details
```

### Query Performance

```
For large datasets:

Background:
└── Long-running aggregations

Foreground:
├── Quick summary queries
├── Sample-based exploration
└── Interactive refinement

Caching:
├── Precompute common aggregates
└── Materialize intermediate views
```
