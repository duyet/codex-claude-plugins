# ClickHouse Plugin for Claude Code

ClickHouse knowledge base with 28 atomic review rules and 15+ deep reference files. Compiled from [ClickHouse/agent-skills](https://github.com/ClickHouse/agent-skills) (Apache-2.0), Altinity Knowledge Base (200+ articles), and official ClickHouse documentation.

## Overview

This plugin provides deep expertise in ClickHouse, a high-performance columnar OLAP database. It combines actionable, citable rules for schema/query/insert review with reference files covering cluster management, Kubernetes, backups, monitoring, and integrations.

## What's Included

### 28 Atomic Rules (`skills/clickhouse/rules/`)

Structured review rules with YAML frontmatter, incorrect/correct examples, and official doc references:

| Prefix | Count | Focus | Impact |
|--------|-------|-------|--------|
| `schema-pk-*` | 4 | Primary key selection and cardinality | CRITICAL |
| `schema-types-*` | 5 | Data types, LowCardinality, Nullable | CRITICAL |
| `schema-partition-*` | 4 | Partitioning and lifecycle management | HIGH |
| `schema-json-*` | 1 | JSON type usage | MEDIUM |
| `query-join-*` | 5 | JOIN algorithms and filtering | CRITICAL |
| `query-index-*` | 1 | Data skipping indices | HIGH |
| `query-mv-*` | 2 | Materialized views (incremental + refreshable) | HIGH |
| `insert-batch-*` | 1 | Batch sizing (10K-100K rows) | CRITICAL |
| `insert-async-*` | 2 | Async inserts and data formats | HIGH |
| `insert-mutation-*` | 2 | Mutation avoidance (UPDATE/DELETE) | CRITICAL |
| `insert-optimize-*` | 1 | OPTIMIZE FINAL avoidance | HIGH |

### 15+ Reference Files (`skills/clickhouse/references/`)

Deep-dive files covering topics beyond the rules:

- **Core Concepts** — Architecture, data model, MergeTree internals
- **Schema & Table Design** — Database engines, migrations, ORDER BY, partitioning
- **Table Engines** — Complete MergeTree family reference
- **SQL Reference** — Full SQL dialect with data types and functions
- **Query Optimization** — EXPLAIN, JOINs, projections, skip indexes
- **Advanced Features** — Materialized views, mutations, TTL, dictionaries
- **Debugging** — Query debugging, merge issues, replication problems
- **Cluster Management** — Distributed tables, replication, sharding
- **Kubernetes Operator** — K8s deployment with Altinity operator
- **Backup & Restore** — Backup strategies and disaster recovery
- **Monitoring** — Query monitoring, health checks, system queries
- **Integrations** — Kafka, S3, PostgreSQL, MySQL, BI tools
- **Best Practices** — Complete checklist and anti-patterns
- **System Queries** — Ready-to-use operations queries

## File Structure

```
clickhouse/
├── .claude-plugin/
│   └── plugin.json
├── .github/
│   └── workflows/
│       ├── sync-rules.yml       # Auto-sync from ClickHouse/agent-skills
│       └── README.md            # Workflow documentation
├── skills/
│   └── clickhouse/
│       ├── SKILL.md              # Review framework + rule index
│       ├── rules/                # 28 atomic rules + meta files
│       │   ├── _sections.md      # Section definitions (schema/query/insert)
│       │   ├── _template.md      # Template for new rules
│       │   ├── schema-pk-*.md    # Primary key rules (4)
│       │   ├── schema-types-*.md # Data type rules (5)
│       │   ├── schema-partition-*.md  # Partitioning rules (4)
│       │   ├── schema-json-*.md  # JSON rules (1)
│       │   ├── query-join-*.md   # JOIN rules (5)
│       │   ├── query-index-*.md  # Index rules (1)
│       │   ├── query-mv-*.md     # Materialized view rules (2)
│       │   ├── insert-batch-*.md # Batch sizing rules (1)
│       │   ├── insert-async-*.md # Async insert rules (2)
│       │   ├── insert-mutation-*.md   # Mutation rules (2)
│       │   └── insert-optimize-*.md   # Optimize rules (1)
│       └── references/           # 15+ deep reference files
│           ├── core-concepts.md
│           ├── schema-design.md
│           ├── table-design.md
│           ├── table-engines.md
│           ├── sql-reference.md
│           ├── query-optimization.md
│           ├── advanced-features.md
│           ├── debugging.md
│           ├── cluster-management.md
│           ├── backup-restore.md
│           ├── monitoring.md
│           ├── integrations.md
│           ├── best-practices.md
│           ├── external.md
│           └── system-queries.md
└── README.md
```

## Auto-Activation Triggers

The skill automatically activates when questions contain:

- `clickhouse`
- `merge.*tree` (e.g., "MergeTree engine")
- `olap` (online analytical processing)
- `columnar.*database`
- `ch\.` (ClickHouse abbreviation)
- `replicated.*merge`

## Usage

When reviewing ClickHouse code, the skill:

1. Checks applicable rules from `rules/` and cites them (e.g., "Per `schema-pk-cardinality-order`...")
2. Falls back to `references/` for deeper topic coverage
3. Provides structured review output with violations, compliance, and recommendations

## Attribution

- **Rules**: Synced from [ClickHouse/agent-skills](https://github.com/ClickHouse/agent-skills) by ClickHouse Inc (Apache-2.0 license)
- **References**: Compiled from Altinity Knowledge Base (200+ articles) and ClickHouse Official Documentation

## Automation

### GitHub Actions Sync

This plugin uses GitHub Actions to automatically sync rule files from the official ClickHouse/agent-skills repository:

- **Workflow**: `.github/workflows/sync-rules.yml`
- **Specification**: `spec/spec-process-cicd-sync-rules.md`
- **Schedule**: Weekly (Sunday at midnight UTC)
- **Trigger**: Manual trigger available from Actions tab

The sync workflow:
1. Fetches latest rules from ClickHouse/agent-skills
2. Updates `skills/clickhouse/rules/` directory
3. Auto-increments version number
4. Creates a pull request for review

**Custom content preserved**: Our extended `references/` directory is never modified by the sync.

See [Workflow Specification](spec/spec-process-cicd-sync-rules.md) for detailed requirements, error handling, and validation criteria.

### Manual Sync

To manually trigger a sync:
```bash
# Via GitHub UI:
# 1. Go to Actions tab
# 2. Select "Sync Rules from ClickHouse/agent-skills"
# 3. Click "Run workflow"

# Via CLI (gh CLI):
gh workflow run sync-rules.yml
```

## Version

**Current Version**: 1.3.0

**Version History**:
- 1.3.0 — Synced rules from ClickHouse/agent-skills
- 1.2.0 — Added security considerations
- 1.1.0 — Initial release with extended references

## License

MIT (plugin code) + Apache-2.0 (rules adapted from ClickHouse/agent-skills)

## Author

duyetbot
