---
name: clickhouse
description: ClickHouse columnar OLAP database expertise. Schema design, MergeTree engines, query optimization, cluster management, backups, monitoring, and integrations. Compiled from Altinity KB (200+ articles) + official docs.
---

# ClickHouse Database Expert

Comprehensive ClickHouse knowledge base for working with high-performance columnar OLAP databases.

## When to Invoke This Skill

Use this skill when:
- Designing ClickHouse schemas (tables, partitions, ORDER BY)
- Choosing table engines (MergeTree family decision tree)
- Writing and optimizing ClickHouse SQL queries
- Managing ClickHouse clusters (replication, sharding)
- Debugging query performance or merge issues
- Setting up backups and monitoring
- Integrating ClickHouse with Kafka, S3, or other systems
- Operating ClickHouse on Kubernetes

## What is ClickHouse?

ClickHouse is a columnar OLAP database designed for real-time analytics on large datasets.

**Key Characteristics:**
- **Columnar storage**: Read only needed columns (10-100x faster than row stores for analytical queries)
- **MergeTree engine family**: Automatic background merges for data organization
- **SQL dialect with extensions**: Arrays, tuples, lambdas, specialized functions
- **Append-first design**: Optimized for high-volume inserts, not point updates

## Golden Rules

1. **Always use MergeTree** (except tiny dimensions → Memory engine)
2. **Sort key = query filter**: ORDER BY defines data layout on disk
3. **Partition by time**: For TTL and efficient DROP PARTITION operations
4. **Avoid mutations**: Use INSERT + new data instead of UPDATE/DELETE
5. **Monitor merges**: Background merges impact performance significantly

## Quick Start Examples

### Minimal Working Schema

```sql
-- Basic events table with best practices
CREATE TABLE events (
    timestamp DateTime,
    user_id UInt32,
    event_type LowCardinality(String),
    session_id UUID,
    metadata String,
    revenue Decimal(18, 2) DEFAULT 0
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)  -- Monthly partitions
ORDER BY (user_id, timestamp)     -- Data layout matches query pattern
SETTINGS index_granularity = 8192;
```

### Common Query Patterns

```sql
-- Effective time range filter
SELECT * FROM events
WHERE timestamp >= today() AND timestamp < tomorrow();

-- Optimize JOIN (smaller table on RIGHT)
SELECT * FROM large_table RIGHT JOIN small_table ON large_table.id = small_table.id;

-- Check query plan
EXPLAIN SELECT * FROM events WHERE user_id = 123;
```

### Monitoring Queries

```sql
-- Running queries
SELECT query_id, user, query, elapsed FROM system.processes ORDER BY elapsed DESC;

-- Table sizes
SELECT database, table, formatReadableSize(sum(bytes)) as size
FROM system.parts WHERE active = 1
GROUP BY database, table ORDER BY sum(bytes) DESC;

-- Active merges
SELECT table, elapsed, bytes_read_uncompressed FROM system.merges ORDER BY elapsed DESC;
```

## Common Pitfalls

| Pitfall | Why It's Bad | Better Approach |
|---------|--------------|-----------------|
| Modifying columns (MODIFY/DROP) | Triggers expensive mutation | Use ADD COLUMN only |
| Updating/deleting rows | Mutations rewrite all data | Use TTL or new tables |
| Bad ORDER BY | Can't leverage index | Match query WHERE patterns |
| Too many partitions | Slow queries, high overhead | Aim for 100-1000 parts total |
| SELECT * | Reads all columns (columnar penalty) | Select only needed columns |
| String date comparison | Full scan | Use date functions on column |

## ClickHouse Architecture Overview

### Data Model

- **Append-first**: No in-place updates (mutations are expensive)
- **Parts and partitions**: Parts merge into larger parts (background process)
- **Two-level index**: Sparse index (8192 rows/mark) + mark files

### When ClickHouse Shines

✅ Wide tables (100+ columns), read few columns
✅ Time-series with time-based filters
✅ Aggregations over billions of rows
✅ Append-only workloads (events, logs, metrics)

### When to Avoid ClickHouse

❌ Point updates/deletes (use row store like PostgreSQL)
❌ Heavy JOINs on non-sorted keys
❌ Complex transactions (no ACID support)
❌ Low-latency OLTP (use row store)

## Key Topics by Reference

### Schema & Table Design

| Topic | Reference | Description |
|-------|-----------|-------------|
| Core Concepts | `references/core-concepts.md` | Architecture, data model, internals |
| Schema Design | `references/schema-design.md` | Database engines, migrations, version control |
| Table Design | `references/table-design.md` | ORDER BY, partitioning, column selection |
| Table Engines | `references/table-engines.md` | Complete MergeTree family reference |

### Query & Performance

| Topic | Reference | Description |
|-------|-----------|-------------|
| SQL Reference | `references/sql-reference.md` | Complete SQL dialect, data types |
| Query Optimization | `references/query-optimization.md` | EXPLAIN, JOINs, projections, skip indexes |
| Advanced Features | `references/advanced-features.md` | Materialized views, mutations, TTL, dictionaries |

### Operations & Cluster

| Topic | Reference | Description |
|-------|-----------|-------------|
| Debugging | `references/debugging.md` | Query debugging, merges, mutations, replication |
| Cluster Management | `references/cluster-management.md` | Distributed tables, replication, sharding |
| Kubernetes Operator | `references/kubernetes-operator.md` | K8s deployment and operations |
| Backup & Restore | `references/backup-restore.md` | Backup strategies, disaster recovery |
| Monitoring | `references/monitoring.md` | Query monitoring, health checks, system queries |

### Integration & Best Practices

| Topic | Reference | Description |
|-------|-----------|-------------|
| Integrations | `references/integrations.md` | Kafka, S3, PostgreSQL, MySQL, BI tools |
| Best Practices | `references/best-practices.md` | Complete checklist, anti-patterns |
| External References | `references/external.md` | Altinity KB links, official docs |

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
| Too many parts | `OPTIMIZE TABLE table FINAL` |
| Slow query | `EXPLAIN SELECT ...` to check index usage |
| Mutation stuck | Check `system.mutations`, use `OPTIMIZE FINAL` |
| Replication lag | Check `system.replication_queue`, ZooKeeper |
| OOM on query | Increase `max_memory_usage`, optimize query |

See `references/debugging.md` for detailed troubleshooting.

## See Also

### Core References
- `references/core-concepts.md` - Architecture, data model, MergeTree internals
- `references/schema-design.md` - Database engines, schema organization, migrations
- `references/table-design.md` - ORDER BY design, partitioning strategies, column selection
- `references/table-engines.md` - Complete guide to all MergeTree family engines
- `references/sql-reference.md` - Full SQL dialect with data types and functions

### Query & Performance
- `references/query-optimization.md` - EXPLAIN, JOIN optimization, projections, skip indexes
- `references/advanced-features.md` - Materialized views, mutations, TTL, dictionaries
- `references/debugging.md` - Query debugging, merge issues, replication problems

### Operations
- `references/cluster-management.md` - Distributed tables, replication, sharding
- `references/kubernetes-operator.md` - K8s deployment with Altinity operator
- `references/backup-restore.md` - Backup strategies and disaster recovery
- `references/monitoring.md` - Query monitoring, health checks, system queries

### Integration & Best Practices
- `references/integrations.md` - Kafka, S3, PostgreSQL, MySQL, BI tools
- `references/best-practices.md` - Comprehensive checklist and anti-patterns
- `references/external.md` - Altinity KB (200+ articles) and official docs

### System Queries
- `references/system-queries.md` - Ready-to-use queries for operations and monitoring

---

**Version**: 1.0.0
**Sources**: Altinity Knowledge Base (200+ articles) + ClickHouse Official Docs
