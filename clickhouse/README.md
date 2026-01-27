# ClickHouse Plugin for Claude Code

Comprehensive ClickHouse knowledge base compiled from Altinity Knowledge Base (200+ articles) and official ClickHouse documentation.

## Overview

This plugin provides deep expertise in ClickHouse, a high-performance columnar OLAP database. It covers everything from basic schema design to advanced cluster management, query optimization, and production operations.

## What's Included

### Core Skill (`skills/clickhouse/SKILL.md`)

A comprehensive 3000+ line guide covering 17 major topics:

1. **Quick Start** - Golden rules, minimal schema, common pitfalls
2. **Core Concepts** - Architecture, data model, when to use/avoid ClickHouse
3. **Database Schema Design** - Database engines, schema organization, migrations
4. **Table Design** - Column selection, ORDER BY design, partitioning, sampling
5. **Table Engines** - Complete reference for all MergeTree family and special engines
6. **ClickHouse SQL** - Complete SQL dialect reference with all data types
7. **Query Optimization** - EXPLAIN, JOIN optimization, projections, skip indexes
8. **Advanced Features** - Materialized views, mutations, TTL, dictionaries
9. **Debugging** - Query debugging, merges, mutations, replication issues
10. **Cluster Management** - Distributed tables, replication, sharding
11. **ClickHouse Operator** - Kubernetes deployment and operations
12. **Backup & Restore** - Backup strategies, disaster recovery
13. **Monitoring Queries** - Current queries, history, performance analysis
14. **Health Checks** - Comprehensive health check queries
15. **Integrations** - Kafka, S3, PostgreSQL, MySQL, BI tools
16. **Best Practices** - Complete checklist for schema, queries, operations
17. **External References** - Links to Altinity KB and official docs

### System Queries (`knowledge/topics/clickhouse-queries/system-queries.md`)

Ready-to-use queries for:
- Table information (sizes, columns, partitions)
- Query monitoring (running queries, history, statistics)
- Merge monitoring (active merges, performance)
- Mutation monitoring (progress, history)
- Replication monitoring (replica status, ZooKeeper)
- Disk and storage (usage, policies)
- Cluster information (status, health)
- System health (memory, load average)

## Auto-Activation Triggers

The skill automatically activates when your questions contain:

- `clickhouse`
- `merge.*tree` (e.g., "MergeTree engine")
- `olap` (online analytical processing)
- `columnar.*database`
- `ch\.` (ClickHouse abbreviation)
- `replicated.*merge`

## Key Topics Covered

### Schema Design

```sql
-- Optimal ORDER BY design
CREATE TABLE events (
    timestamp DateTime,
    user_id UInt32,
    event_type LowCardinality(String)
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (user_id, timestamp);  -- Matches query WHERE pattern
```

### Table Engines

Complete reference for all engines:
- MergeTree (default, append-only)
- ReplacingMergeTree (upsert behavior)
- CollapsingMergeTree (changelog)
- AggregatingMergeTree (pre-aggregation)
- ReplicatedMergeTree (production clusters)
- Memory, Dictionary, Kafka, S3, and more

### Query Optimization

```sql
-- Check query plan
EXPLAIN SELECT * FROM events WHERE user_id = 123;

-- Optimize JOINs (small table on RIGHT)
SELECT * FROM large_table RIGHT JOIN small_table ON large_table.id = small_table.id;

-- Use projections for common aggregations
ALTER TABLE events ADD PROJECTION pr_user_daily (
    SELECT user_id, toDate(timestamp) as date, count() as events
    GROUP BY user_id, date
);
```

### Cluster Operations

```sql
-- Create distributed table
CREATE TABLE distributed_events AS local_events
ENGINE = Distributed('cluster_name', 'database', 'local_events', user_id);

-- ReplicatedMergeTree setup
CREATE TABLE events (...) ENGINE = ReplicatedMergeTree(
    '/clickhouse/tables/1/events',
    'replica1'
);
```

### Monitoring

```sql
-- Running queries
SELECT query_id, user, query, elapsed FROM system.processes;

-- Slow queries
SELECT query, query_duration_ms FROM system.query_log
WHERE type = 'QueryFinish' AND query_duration_ms > 5000;

-- Merge performance
SELECT table, elapsed, bytes_read_uncompressed FROM system.merges;
```

## Best Practices

The skill includes a comprehensive best practices checklist covering:

- **Schema Design**: ORDER BY design, partitioning, primary keys, column types
- **Query Writing**: JOIN order, GLOBAL joins, skip indexes, projections
- **Performance**: Merge monitoring, mutation avoidance, TTL usage
- **Operations**: Backups, monitoring, alerting, disaster recovery
- **Cluster Management**: Replication, sharding, load balancing, failover

## Anti-Patterns to Avoid

❌ Updating/deleting single rows (use TTL or new tables)
❌ Too many partitions (> 10k total)
❌ SELECT * (reads all columns)
❌ ORDER BY not matching queries
❌ Ignoring merge performance
❌ Using mutations for bulk changes
❌ String comparison for dates
❌ Suboptimal JOIN order

## External References

Comprehensive links to:
- **Altinity Knowledge Base** (200+ articles)
- **Official ClickHouse Documentation**
- **ClickHouse Operator** (Kubernetes)

## Quick Examples

### Create a production-ready table

```sql
CREATE TABLE events (
    timestamp DateTime,
    user_id UInt32,
    event_type LowCardinality(String) DEFAULT 'unknown',
    session_id UUID DEFAULT generateUUIDv4(),
    metadata String DEFAULT '',
    revenue Decimal(18, 2) DEFAULT 0.00
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (user_id, timestamp)
SAMPLE BY user_id
TTL timestamp + INTERVAL 90 DAY
SETTINGS index_granularity = 8192;
```

### Optimize a slow query

```sql
-- Check query plan
EXPLAIN SELECT * FROM events WHERE user_id = 123;

-- Add skip index
ALTER TABLE events ADD INDEX idx_user user_id TYPE set(1000) GRANULARITY 1;

-- Use projection for common aggregation
ALTER TABLE events ADD PROJECTION pr_user_daily (
    SELECT user_id, toDate(timestamp) as date, count() as events
    GROUP BY user_id, date
);
```

### Monitor cluster health

```sql
-- Quick health check
SELECT 'uptime' as metric, toString(uptime()) as value
UNION ALL SELECT 'version', version()
UNION ALL SELECT 'replicas_lagging', toString(count())
FROM system.replication_queue WHERE delay > 5;

-- Table sizes
SELECT database, table, formatReadableSize(sum(bytes)) as size
FROM system.parts WHERE active = 1
GROUP BY database, table ORDER BY sum(bytes) DESC;
```

## Version

**Current Version**: 1.0.0

**Last Updated**: 2024-01-27

**Sources**:
- Altinity Knowledge Base (200+ articles)
- ClickHouse Official Documentation
- Production best practices

## License

MIT

## Author

duyetbot

---

For detailed usage, see the [SKILL.md](skills/clickhouse/SKILL.md) file.
