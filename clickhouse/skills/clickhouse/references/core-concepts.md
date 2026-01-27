# ClickHouse Core Concepts

## Architecture Overview

### Columnar Storage

ClickHouse stores data by columns, not rows:

**Benefits:**
- Read only needed columns (10-100x faster for analytical queries)
- Excellent compression (similar data types stored together)
- Efficient for wide tables (100+ columns) with selective reads

**Trade-offs:**
- Slower single-row reads (must read all columns)
- Not optimal for point queries or OLTP

### Two-Level Index Structure

```
┌─────────────────────────────────────┐
│  Sparse Index (one mark per 8192 rows) │
├─────────────────────────────────────┤
│  Mark Files (point to data blocks)   │
├─────────────────────────────────────┤
│  Compressed Column Data              │
└─────────────────────────────────────┘
```

- **Sparse index**: One mark per 8192 rows (configurable via `index_granularity`)
- **Mark files**: Point to compressed data blocks
- **Query execution**: Uses marks to skip irrelevant data

```sql
-- Check index granularity setting
SELECT index_granularity FROM system.tables
WHERE database = currentDatabase() AND table = 'my_table';

-- Adjust index granularity (affects mark count)
CREATE TABLE ... SETTINGS index_granularity = 4096;
```

### Merge Process

Background merges continuously organize data:

**Merge Lifecycle:**
1. New data inserted as small parts
2. Background merges combine parts (exponential backoff)
3. Parts grow from MB → GB → TB
4. Merges can be CPU/disk intensive

**Monitoring Merges:**
```sql
-- Active merges
SELECT table, elapsed, bytes_read_uncompressed, rows_read
FROM system.merges
ORDER BY elapsed DESC;

-- Merge queue size
SELECT database, table, count() as parts
FROM system.parts
WHERE active = 1 AND rows > 0
GROUP BY database, table
HAVING parts > 1000;
```

### Distributed Query Execution

```
┌─────────────┐
│ Coordinator │
└──────┬──────┘
       │
       ├── Shard 1 ── Query Local Data
       ├── Shard 2 ── Query Local Data
       └── Shard 3 ── Query Local Data
       │
       └── Merge Results
```

- Coordinator node shards query across replicas
- Each shard processes local data in parallel
- Coordinator merges and returns results

## Data Model

### Append-First Design

ClickHouse is optimized for appends, not in-place updates:

**Characteristics:**
- No in-place updates (mutations are expensive rewrite operations)
- Data organized as immutable parts
- Parts merge over time (background process)

**Parts vs Partitions:**
- **Partition**: Logical division (e.g., monthly `202401`, `202402`)
- **Part**: Physical data file on disk
- Typical: 100-1000 parts per partition
- Too many parts = slow queries, high merge overhead

### MVCC and Versioning

ClickHouse offers several patterns for versioned data:

**ReplacingMergeTree**: Keeps latest version per ORDER BY key
```sql
CREATE TABLE user_profiles (
    user_id UInt32,
    updated_at DateTime,
    profile String
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY user_id;
```

**CollapsingMergeTree**: Uses sign column for insert/delete
```sql
CREATE TABLE changes (
    id UInt32,
    sign Int8,  -- 1 = insert, -1 = delete
    data String
)
ENGINE = CollapsingMergeTree(sign)
ORDER BY id;
```

### ZooKeeper Coordination

ReplicatedMergeTree uses ZooKeeper for coordination:

**ZooKeeper stores:**
- Schema metadata
- Part metadata
- Replication status
- Merge queue

**ZooKeeper considerations:**
- ZK outage = read-only cluster (can't insert)
- High ZK load can impact performance
- Monitor ZK connection health

```sql
-- Check ZK connection
SELECT * FROM system.zookeeper WHERE path = '/';

-- Check replication queue
SELECT * FROM system.replication_queue;
```

## When ClickHouse Shines

### Ideal Use Cases

✅ **Wide tables** (100+ columns), read few columns
✅ **Time-series** with time-based filters
✅ **Aggregations** over billions of rows
✅ **Append-only workloads** (events, logs, metrics)
✅ **Real-time analytics** (sub-second responses)
✅ **Histograms** and quantiles over large datasets

### Example Workloads

```sql
-- Events/analytics (ideal)
SELECT user_id, count() as events
FROM events
WHERE timestamp >= today() - INTERVAL 7 DAY
GROUP BY user_id;

-- Time-series (ideal)
SELECT toDate(timestamp) as date, sum(revenue)
FROM events
WHERE timestamp >= now() - INTERVAL 30 DAY
GROUP BY date
ORDER BY date;

-- Aggregations (ideal)
SELECT percentile(duration, [50, 90, 99]) as p50_p90_p99
FROM requests
WHERE timestamp >= today();
```

## When to Avoid ClickHouse

### Poor Use Cases

❌ **Point updates/deletes**: Use row store (PostgreSQL, MySQL)
❌ **Heavy JOINs** on non-sorted keys: Consider data warehouse
❌ **Complex transactions**: No ACID support
❌ **Low-latency OLTP**: Use row store
❌ **Unstructured data**: Use document store (MongoDB)
❌ **Single-row lookups**: Use key-value store (Redis)

### Anti-Patterns

```sql
-- ❌ Point updates (expensive mutation)
UPDATE events SET status = 'done' WHERE event_id = 123;

-- ✅ Use TTL or new table instead
ALTER TABLE events MODIFY TTL timestamp + INTERVAL 90 DAY;
-- OR
INSERT INTO events_done SELECT * FROM events WHERE status = 'done';

-- ❌ Single-row lookup
SELECT * FROM events WHERE event_id = 123;

-- ✅ Use row store or Redis for point queries
```

## Performance Characteristics

### Query Performance

| Query Type | ClickHouse | Row Store |
|------------|------------|-----------|
| Full table scan | ⚡ Fast | 🐌 Slow |
| Column-selective | ⚡ Very Fast | 🐌 Slow |
| Row-selective | 🐌 Slow | ⚡ Fast |
| Point lookup | 🐌 Slow | ⚡ Fast |
| Aggregation | ⚡ Very Fast | 🐌 Slow |

### Data Types Performance

| Type | Size | Compression | Use Case |
|------|------|-------------|----------|
| UInt8 | 1 byte | High | Enums, flags |
| UInt32 | 4 bytes | Medium | IDs, counters |
| UInt64 | 8 bytes | Low | Large IDs |
| String | Variable | Medium | Text data |
| LowCardinality(String) | Integer | Very High | < 10k distinct values |

## See Also

- `../SKILL.md` - Main skill entry point
- `schema-design.md` - Database engines and schema organization
- `table-design.md` - ORDER BY and partitioning strategies
- `query-optimization.md` - Query performance tuning
