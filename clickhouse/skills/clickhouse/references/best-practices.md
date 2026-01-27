# ClickHouse Best Practices

Comprehensive checklist and anti-patterns for ClickHouse.

## Schema Design Checklist

- [ ] **ORDER BY matches query WHERE patterns**
  - Most selective filter first
  - Time-series: timestamp as second column
  - Limit to 3-4 columns

- [ ] **Partitioning aligned with TTL/DROP needs**
  - Time-based: Monthly or daily partitions
  - Aim for 100-1000 parts total
  - Use `toYYYYMM()` for monthly

- [ ] **Primary key is subset of ORDER BY**
  - Reduces primary key size
  - Must be prefix of ORDER BY

- [ ] **Used smallest sufficient types**
  - UInt8 vs UInt32 vs UInt64
  - Date vs DateTime (2 bytes vs 4 bytes)
  - Decimal for currency

- [ ] **Used LowCardinality for enum-like strings**
  - < 10k distinct values
  - Significant compression

- [ ] **Avoided Nullable when possible**
  - Use default values instead
  - Nullable has overhead

- [ ] **Avoided MODIFY/DROP COLUMN**
  - Use ADD COLUMN only
  - Create new tables for schema changes

## Query Writing Checklist

- [ ] **Smaller table on RIGHT side of JOIN**
  - ClickHouse sends RIGHT table to all shards
  - Minimize network transfer

- [ ] **Used GLOBAL JOIN for distributed queries**
  - Prevents sending right table multiple times

- [ ] **Added skip indexes for frequent filters**
  - Bloom filter for exact match
  - Minmax for range queries
  - Set for IN queries

- [ ] **Leveraged projections for common aggregations**
  - Pre-computed aggregations
  - Automatic usage

- [ ] **Avoided SELECT ***
  - Reads all columns (columnar penalty)
  - Select only needed columns

- [ ] **Used EXPLAIN to verify index usage**
  - Look for "Index" in output
  - Avoid "Filter" (full scan)

- [ ] **Set reasonable max_memory_usage**
  - Prevent OOM errors
  - Tune based on available memory

- [ ] **Used SAMPLE for exploratory queries**
  - Fast approximate results
  - `SELECT ... SAMPLE 0.1`

## Performance Checklist

- [ ] **Monitored merges (system.merges)**
  - Active merges impact performance
  - Check merge queue size

- [ ] **Checked mutation progress**
  - Mutations are expensive
  - Monitor `system.mutations`

- [ ] **Used TTL instead of DELETE**
  - Automatic data lifecycle
  - No mutation overhead

- [ ] **Preferred INSERT over UPDATE/DELETE**
  - Append-first design
  - Mutations rewrite all data

- [ ] **Set appropriate max_block_size**
  - Default: 65536
  - Larger for bulk inserts

- [ ] **Enabled async_insert for frequent small inserts**
  - Reduces merge overhead
  - `async_insert = 1`

- [ ] **Configured appropriate index_granularity**
  - Default: 8192
  - Smaller = larger index

- [ ] **Used AggregatingMergeTree for pre-aggregation**
  - Materialize aggregations on write
  - Fast query performance

## Operations Checklist

- [ ] **Automated backups (clickhouse-backup)**
  - Daily backups
  - Offsite storage (S3)

- [ ] **Monitoring dashboards (Grafana)**
  - Query performance
  - Merge queue
  - Replication lag

- [ ] **Alert on replication lag > 5s**
  - Check `system.replication_queue`
  - ZooKeeper health

- [ ] **Alert on merge queue > 1000**
  - Too many parts
  - Consider `OPTIMIZE FINAL`

- [ ] **Tested disaster recovery**
  - Backup restore procedure
  - Documented RTO/RPO

- [ ] **Documented partition retention policy**
  - TTL configuration
  - DROP PARTITION schedule

- [ ] **Configured ZooKeeper session timeout**
  - Prevent expiration
  - Default: 30 seconds

- [ ] **Set up query logging**
  - `system.query_log`
  - TTL for log retention

## Cluster Management Checklist

- [ ] **Used ReplicatedMergeTree for production**
  - Data replication
  - Automatic failover

- [ ] **Configured proper sharding keys**
  - Even data distribution
  - Consider query patterns

- [ ] **Set up distributed tables**
  - Query across cluster
  - Transparent to application

- [ ] **Monitored cluster health**
  - All replicas online
  - Replication lag minimal

- [ ] **Configured load balancing**
  - Round-robin or random
  - `load_balancing` setting

- [ ] **Set up cross-DC replication**
  - Disaster recovery
  - Geographic distribution

- [ ] **Documented cluster topology**
  - Shard/replica mapping
  - Network configuration

- [ ] **Automated failover testing**
  - Replica failure
  - ZooKeeper failure

## Anti-Patterns

### Schema Anti-Patterns

| Anti-Pattern | Why It's Bad | Better Approach |
|--------------|--------------|-----------------|
| Updating/deleting single rows | Mutations rewrite all data | Use TTL or new tables |
| Too many partitions | Slow queries, high overhead | Aim for 100-1000 parts |
| SELECT * | Reads all columns | Select only needed columns |
| ORDER BY not matching queries | Can't leverage index | Match query WHERE patterns |
| Ignoring merge performance | Background merges impact queries | Monitor system.merges |
| Using mutations for bulk changes | Expensive rewrites | Use INSERT + new tables |
| String comparison for dates | Full scan | Use date functions on column |
| Suboptimal JOIN order | Larger network transfer | Smaller table on RIGHT |

### Query Anti-Patterns

| Anti-Pattern | Why It's Bad | Better Approach |
|--------------|--------------|-----------------|
| Function on column in WHERE | Can't use index | Apply function to literal |
| Large table on RIGHT of JOIN | More network transfer | Smaller table on RIGHT |
| No GLOBAL JOIN on distributed | Repeated data transfer | Add GLOBAL keyword |
| SELECT * for wide tables | Reads all columns | Select specific columns |
| Suboptimal date filtering | Full scan | Use date range: `>= today() AND < tomorrow()` |

### Operations Anti-Patterns

| Anti-Pattern | Why It's Bad | Better Approach |
|--------------|--------------|-----------------|
| No backups | Data loss risk | Automate with clickhouse-backup |
| Ignoring merge queue | Performance degradation | Monitor and optimize |
| No replication | Single point of failure | Use ReplicatedMergeTree |
| Skipping ZooKeeper monitoring | Cluster can go read-only | Monitor ZK health |
| No query logging | Can't debug issues | Enable query_log |

## Code Examples

### Good Schema

```sql
-- ✅ Good: Matches query patterns
CREATE TABLE events (
    timestamp DateTime,
    user_id UInt32,
    event_type LowCardinality(String),
    revenue Decimal(18, 2) DEFAULT 0
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)  -- Monthly partitions
ORDER BY (user_id, timestamp)     -- Matches queries
SAMPLE BY user_id                  -- Enable sampling
TTL timestamp + INTERVAL 90 DAY;  -- Auto cleanup
```

### Bad Schema

```sql
-- ❌ Bad: ORDER BY doesn't match queries
CREATE TABLE events (
    timestamp DateTime,
    user_id UInt32,
    event_type String,
    revenue Nullable(Decimal(18, 2))
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (timestamp);  -- Queries filter by user_id first!
```

### Good Query

```sql
-- ✅ Good: Uses index, selective columns
SELECT
    user_id,
    count() as events,
    sum(revenue) as total_revenue
FROM events
WHERE timestamp >= today() AND timestamp < tomorrow()
  AND user_id = 123
GROUP BY user_id;
```

### Bad Query

```sql
-- ❌ Bad: Function on column, SELECT *
SELECT * FROM events
WHERE toDate(timestamp) = today();
```

## Monitoring Queries

```sql
-- Health check
SELECT 'uptime' as metric, toString(uptime()) as value
UNION ALL SELECT 'version', version()
UNION ALL SELECT 'replicas_lagging', toString(count())
FROM system.replication_queue WHERE delay > 5
UNION ALL SELECT 'mutations_running', toString(count())
FROM system.mutations WHERE is_done = 0;

-- Merge queue
SELECT database, table, count() as parts
FROM system.parts
WHERE active = 1
GROUP BY database, table
HAVING parts > 1000;
```

## See Also

- `../SKILL.md` - Main skill entry point
- `schema-design.md` - Database engines and schema organization
- `query-optimization.md` - Query performance tuning
- `monitoring.md` - Health checks and monitoring queries
