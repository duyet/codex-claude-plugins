# DevOps Orchestration

Patterns for infrastructure deployment, CI/CD, and operational tasks.

## CI/CD Pipeline

### Pattern: Parallel Stages

```
Fan-Out (parallel validation):
├── Agent 1: Lint and format check
├── Agent 2: Type checking
├── Agent 3: Unit tests
├── Agent 4: Security scan
└── Agent 5: Build verification

Sequential gates:
Validation → Build → Test → Deploy Staging → Deploy Production
```

### Pipeline Configuration

```yaml
# Example structure
stages:
  - validate   # Parallel checks
  - build      # Single artifact
  - test       # Parallel test suites
  - deploy-stg # Staging deployment
  - approve    # Manual gate
  - deploy-prd # Production deployment
```

## Deployment

### Pattern: Zero-Downtime Deployment

```
Phase 1: Preparation (parallel)
├── Agent 1: Build and push new image
├── Agent 2: Validate configuration
├── Agent 3: Prepare rollback artifacts
└── Agent 4: Notify stakeholders

Phase 2: Deploy (sequential)
├── Health check current state
├── Deploy canary (10% traffic)
├── Monitor metrics
├── Gradual rollout (25% → 50% → 100%)
└── Verify completion

Phase 3: Post-Deploy (parallel)
├── Smoke tests
├── Performance validation
├── Documentation update
└── Notification
```

### Rollback Strategy

```
Trigger conditions:
├── Error rate > threshold
├── Latency > threshold
├── Health check failures
└── Manual trigger

Rollback steps:
├── Immediate: Redirect traffic to previous version
├── Short-term: Investigate issue
├── Resolution: Fix and redeploy
```

## Infrastructure as Code

### Pattern: Layer-by-Layer

```
Phase 1: Foundation (sequential)
├── Network configuration
├── Security groups
└── IAM roles

Phase 2: Compute (parallel)
├── Agent 1: Kubernetes cluster
├── Agent 2: Database instances
├── Agent 3: Cache clusters
└── Agent 4: Queue services

Phase 3: Application (parallel)
├── Agent 1: Deploy services
├── Agent 2: Configure ingress
└── Agent 3: Set up monitoring
```

### Terraform Structure

```
infrastructure/
├── modules/           # Reusable modules
│   ├── networking/
│   ├── compute/
│   └── database/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
└── shared/           # Cross-environment resources
```

## Kubernetes Operations

### Pattern: Resource-Parallel

```
Fan-Out (parallel by resource type):
├── Agent 1: Deployment configurations
├── Agent 2: Service definitions
├── Agent 3: ConfigMaps and Secrets
├── Agent 4: Ingress rules
└── Agent 5: RBAC policies

Verification:
├── Resource syntax validation
├── Dry-run application
└── Health check post-apply
```

### Scaling Operations

```
Analysis (parallel):
├── Current resource utilization
├── Historical patterns
├── Cost implications
└── Performance requirements

Decision:
├── Horizontal (replicas)
├── Vertical (resources)
└── Auto-scaling rules
```

## Monitoring & Observability

### Pattern: Multi-Pillar Setup

```
Fan-Out (parallel configuration):
├── Agent 1: Metrics collection (Prometheus)
├── Agent 2: Log aggregation (ELK/Loki)
├── Agent 3: Tracing setup (Jaeger/Zipkin)
└── Agent 4: Alerting rules (PagerDuty/Slack)

Each pillar:
├── Collection configuration
├── Storage setup
├── Query/dashboard creation
└── Alert definition
```

### Alert Tuning

```
Analysis:
├── Current alert frequency
├── False positive rate
├── Response times
└── Coverage gaps

Tuning (parallel):
├── Agent 1: Adjust thresholds
├── Agent 2: Add context to alerts
├── Agent 3: Create runbooks
└── Agent 4: Configure escalation paths
```

## Incident Response

### Pattern: Parallel Triage

```
Fan-Out (rapid diagnosis):
├── Agent 1: Log analysis
├── Agent 2: Metrics examination
├── Agent 3: Recent deployment check
├── Agent 4: Dependency health
└── Agent 5: Database status

Synthesis:
→ Root cause hypothesis
→ Impact assessment
→ Mitigation priority

Resolution:
├── Immediate mitigation
├── Communication
├── Fix implementation
└── Post-incident review
```

### Incident Template

```markdown
## Incident Report

**Severity**: [P1-P4]
**Duration**: [start] - [end]
**Impact**: [description of user impact]

### Timeline
| Time | Event |
|------|-------|
| HH:MM | Incident detected |
| HH:MM | Investigation started |
| HH:MM | Root cause identified |
| HH:MM | Mitigation applied |
| HH:MM | All clear |

### Root Cause
[Technical description]

### Resolution
[What was done to fix]

### Prevention
[Changes to prevent recurrence]
```

## Security Hardening

### Pattern: Checklist-Parallel

```
Fan-Out (security domains):
├── Agent 1: Network security
│   ├── Firewall rules
│   ├── Network policies
│   └── TLS configuration
│
├── Agent 2: Access control
│   ├── IAM policies
│   ├── RBAC configuration
│   └── Service accounts
│
├── Agent 3: Secrets management
│   ├── Secret rotation
│   ├── Vault integration
│   └── Environment variables
│
└── Agent 4: Vulnerability management
    ├── Image scanning
    ├── Dependency audit
    └── Compliance checks

Consolidation:
→ Security posture report
→ Priority remediation list
→ Compliance status
```

## Best Practices

### Safety-First Principles

```
1. Always have rollback ready
2. Deploy to staging before production
3. Use feature flags for risky changes
4. Monitor aggressively during rollouts
5. Document runbooks for common issues
```

### Change Management

| Change Type | Validation Required | Approval |
|-------------|---------------------|----------|
| Config only | Automated tests | Team lead |
| Code change | Full CI + staging | Team lead |
| Infrastructure | Plan review + staging | Platform team |
| Database | Backup + staging test | DBA + team lead |
| Security | Security review | Security team |
