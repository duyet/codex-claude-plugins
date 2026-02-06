---
name: clickhouse-best-practices
description: MUST USE when reviewing ClickHouse schemas, queries, or configurations. Contains 28 rules that MUST be checked before providing recommendations. Always read relevant rule files and cite specific rules in responses.
---

# ClickHouse Best Practices

Guidance for ClickHouse covering schema design, query optimization, and data ingestion. Contains 28 atomic rules across 3 categories (schema, query, insert), prioritized by impact. Extended with 15+ reference files covering cluster management, Kubernetes, backups, monitoring, and integrations.

> **Official docs:** [ClickHouse Best Practices](https://clickhouse.com/docs/best-practices)

## IMPORTANT: How to Apply This Skill

**Before answering ClickHouse questions, follow this priority order:**

1. **Check for applicable rules** in the `rules/` directory
2. **If rules exist:** Apply them and cite them in your response using "Per `rule-name`..."
3. **If no rule exists:** Check `references/` for deeper topic coverage
4. **If neither covers it:** Use general ClickHouse knowledge or search documentation
5. **Always cite your source:** rule name, reference file, or URL

**Why rules take priority:** ClickHouse has specific behaviors (columnar storage, sparse indexes, merge tree mechanics) where general database intuition can be misleading. The rules encode validated, ClickHouse-specific guidance.

---

## Review Procedures

### For Schema Reviews (CREATE TABLE, ALTER TABLE)

**Read these rule files in order:**

1. `rules/schema-pk-plan-before-creation.md` — ORDER BY is immutable
2. `rules/schema-pk-cardinality-order.md` — Column ordering in keys
3. `rules/schema-pk-prioritize-filters.md` — Filter column inclusion
4. `rules/schema-pk-filter-on-orderby.md` — Query filter alignment
5. `rules/schema-types-native-types.md` — Proper type selection
6. `rules/schema-types-minimize-bitwidth.md` — Numeric type sizing
7. `rules/schema-types-lowcardinality.md` — LowCardinality usage
8. `rules/schema-types-avoid-nullable.md` — Nullable vs DEFAULT
9. `rules/schema-types-enum.md` — Enum for finite value sets
10. `rules/schema-partition-low-cardinality.md` — Partition count limits
11. `rules/schema-partition-lifecycle.md` — Partitioning purpose
12. `rules/schema-partition-query-tradeoffs.md` — Partition pruning trade-offs
13. `rules/schema-partition-start-without.md` — Start without partitioning
14. `rules/schema-json-when-to-use.md` — JSON type usage

**Check for:**
- [ ] PRIMARY KEY / ORDER BY column order (low-to-high cardinality)
- [ ] Data types match actual data ranges
- [ ] LowCardinality applied to appropriate string columns
- [ ] Partition key cardinality bounded (100-1,000 values)
- [ ] ReplacingMergeTree has version column if used

### For Query Reviews (SELECT, JOIN, aggregations)

**Read these rule files:**

1. `rules/query-join-choose-algorithm.md` — Algorithm selection
2. `rules/query-join-use-any.md` — ANY vs regular JOIN
3. `rules/query-join-filter-before.md` — Pre-join filtering
4. `rules/query-join-consider-alternatives.md` — Dictionaries/denormalization
5. `rules/query-join-null-handling.md` — join_use_nulls setting
6. `rules/query-index-skipping-indices.md` — Secondary index usage
7. `rules/query-mv-incremental.md` — Incremental materialized views
8. `rules/query-mv-refreshable.md` — Refreshable materialized views

**Check for:**
- [ ] Filters use ORDER BY prefix columns
- [ ] JOINs filter tables before joining (not after)
- [ ] Correct JOIN algorithm for table sizes
- [ ] Skipping indices for non-ORDER BY filter columns

### For Insert Strategy Reviews (data ingestion, updates, deletes)

**Read these rule files:**

1. `rules/insert-batch-size.md` — Batch sizing requirements
2. `rules/insert-async-small-batches.md` — Async insert usage
3. `rules/insert-format-native.md` — Native format for performance
4. `rules/insert-mutation-avoid-update.md` — UPDATE alternatives
5. `rules/insert-mutation-avoid-delete.md` — DELETE alternatives
6. `rules/insert-optimize-avoid-final.md` — OPTIMIZE TABLE risks

**Check for:**
- [ ] Batch size 10K-100K rows per INSERT
- [ ] No ALTER TABLE UPDATE for frequent changes
- [ ] ReplacingMergeTree or CollapsingMergeTree for update patterns
- [ ] Async inserts enabled for high-frequency small batches

---

## Output Format

Structure review responses as follows:

```
## Rules Checked
- `rule-name-1` — Compliant / Violation found
- `rule-name-2` — Compliant / Violation found
...

## Findings

### Violations
- **`rule-name`**: Description of the issue
  - Current: [what the code does]
  - Required: [what it should do]
  - Fix: [specific correction]

### Compliant
- `rule-name`: Brief note on why it's correct

## Recommendations
[Prioritized list of changes, citing rules]
```

---

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Count |
|----------|----------|--------|--------|-------|
| 1 | Primary Key Selection | CRITICAL | `schema-pk-` | 4 |
| 2 | Data Type Selection | CRITICAL | `schema-types-` | 5 |
| 3 | JOIN Optimization | CRITICAL | `query-join-` | 5 |
| 4 | Insert Batching | CRITICAL | `insert-batch-` | 1 |
| 5 | Mutation Avoidance | CRITICAL | `insert-mutation-` | 2 |
| 6 | Partitioning Strategy | HIGH | `schema-partition-` | 4 |
| 7 | Skipping Indices | HIGH | `query-index-` | 1 |
| 8 | Materialized Views | HIGH | `query-mv-` | 2 |
| 9 | Async Inserts | HIGH | `insert-async-` | 2 |
| 10 | OPTIMIZE Avoidance | HIGH | `insert-optimize-` | 1 |
| 11 | JSON Usage | MEDIUM | `schema-json-` | 1 |

---

## Quick Reference

### Schema Design — Primary Key (CRITICAL)

- `schema-pk-plan-before-creation` — Plan ORDER BY before table creation (immutable)
- `schema-pk-cardinality-order` — Order columns low-to-high cardinality
- `schema-pk-prioritize-filters` — Include frequently filtered columns
- `schema-pk-filter-on-orderby` — Query filters must use ORDER BY prefix

### Schema Design — Data Types (CRITICAL)

- `schema-types-native-types` — Use native types, not String for everything
- `schema-types-minimize-bitwidth` — Use smallest numeric type that fits
- `schema-types-lowcardinality` — LowCardinality for <10K unique strings
- `schema-types-enum` — Enum for finite value sets with validation
- `schema-types-avoid-nullable` — Avoid Nullable; use DEFAULT instead

### Schema Design — Partitioning (HIGH)

- `schema-partition-low-cardinality` — Keep partition count 100-1,000
- `schema-partition-lifecycle` — Use partitioning for data lifecycle, not queries
- `schema-partition-query-tradeoffs` — Understand partition pruning trade-offs
- `schema-partition-start-without` — Consider starting without partitioning

### Schema Design — JSON (MEDIUM)

- `schema-json-when-to-use` — JSON for dynamic schemas; typed columns for known

### Query Optimization — JOINs (CRITICAL)

- `query-join-choose-algorithm` — Select algorithm based on table sizes
- `query-join-use-any` — ANY JOIN when only one match needed
- `query-join-filter-before` — Filter tables before joining
- `query-join-consider-alternatives` — Dictionaries/denormalization vs JOIN
- `query-join-null-handling` — join_use_nulls=0 for default values

### Query Optimization — Indices (HIGH)

- `query-index-skipping-indices` — Skipping indices for non-ORDER BY filters

### Query Optimization — Materialized Views (HIGH)

- `query-mv-incremental` — Incremental MVs for real-time aggregations
- `query-mv-refreshable` — Refreshable MVs for complex joins

### Insert Strategy — Batching (CRITICAL)

- `insert-batch-size` — Batch 10K-100K rows per INSERT

### Insert Strategy — Async (HIGH)

- `insert-async-small-batches` — Async inserts for high-frequency small batches
- `insert-format-native` — Native format for best performance

### Insert Strategy — Mutations (CRITICAL)

- `insert-mutation-avoid-update` — ReplacingMergeTree instead of ALTER UPDATE
- `insert-mutation-avoid-delete` — Lightweight DELETE or DROP PARTITION

### Insert Strategy — Optimization (HIGH)

- `insert-optimize-avoid-final` — Let background merges work

---

## Quick Decision Guides

### Which Table Engine?

```
Need to store data?
├── < 1M rows, dimension → Memory
└── ≥ 1M rows → MergeTree family
    ├── Deduplication? → ReplacingMergeTree(version)
    ├── Changelog? → CollapsingMergeTree(sign)
    ├── Pre-aggregation? → AggregatingMergeTree()
    ├── Replication? → ReplicatedMergeTree(...)
    └── Default → MergeTree()
```

See `references/table-engines.md` for complete reference.

### Common Issues & Quick Fixes

| Issue | Quick Fix |
|-------|-----------|
| Too many parts | `OPTIMIZE TABLE table FINAL` (see `insert-optimize-avoid-final`) |
| Slow query | `EXPLAIN SELECT ...` to check index usage |
| Mutation stuck | Check `system.mutations`, consider alternatives per `insert-mutation-avoid-update` |
| Replication lag | Check `system.replication_queue`, ZooKeeper |
| OOM on query | Increase `max_memory_usage`, optimize query |

See `references/debugging.md` for detailed troubleshooting.

---

## Deep Reference Files

For topics beyond the 28 rules, see the `references/` directory:

### Schema & Table Design
- `references/core-concepts.md` — Architecture, data model, internals
- `references/schema-design.md` — Database engines, migrations, version control
- `references/table-design.md` — ORDER BY, partitioning, column selection
- `references/table-engines.md` — Complete MergeTree family reference

### Query & Performance
- `references/sql-reference.md` — Complete SQL dialect, data types
- `references/query-optimization.md` — EXPLAIN, JOINs, projections, skip indexes
- `references/advanced-features.md` — Materialized views, mutations, TTL, dictionaries

### Operations & Cluster
- `references/debugging.md` — Query debugging, merges, mutations, replication
- `references/cluster-management.md` — Distributed tables, replication, sharding
- `references/kubernetes-operator.md` — K8s deployment and operations
- `references/backup-restore.md` — Backup strategies, disaster recovery
- `references/monitoring.md` — Query monitoring, health checks, system queries

### Integration & Best Practices
- `references/integrations.md` — Kafka, S3, PostgreSQL, MySQL, BI tools
- `references/best-practices.md` — Complete checklist and anti-patterns
- `references/external.md` — Altinity KB links, official docs
- `references/system-queries.md` — Ready-to-use queries for operations

---

**Version**: 1.1.0
**Rules**: Adapted from [ClickHouse/agent-skills](https://github.com/ClickHouse/agent-skills) (Apache-2.0)
**References**: Altinity Knowledge Base (200+ articles) + ClickHouse Official Docs
