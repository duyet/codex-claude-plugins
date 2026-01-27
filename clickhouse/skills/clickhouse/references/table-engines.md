# ClickHouse Table Engines - Complete Reference

## MergeTree Family Decision Tree

```
Need to store data?
├── < 1M rows, dimension table → Memory engine
└── ≥ 1M rows → MergeTree family
    ├── Need deduplication? → ReplacingMergeTree(version)
    │   └── Keeps latest row per ORDER BY key
    ├── Need changelog (insert/delete)? → CollapsingMergeTree(sign)
    │   └── Uses sign column: 1=insert, -1=delete
    ├── Need changelog with versions? → VersionedCollapsingMergeTree(sign, version)
    │   └── Multiple versions per key
    ├── Need pre-aggregation? → AggregatingMergeTree()
    │   └── Custom aggregation functions
    ├── Need numeric summation? → SummingMergeTree()
    │   └── Sums numeric columns on merge
    ├── Graphite metrics? → GraphiteMergeTree()
    │   └── Optimized for Graphite rollups
    ├── Need replication? → ReplicatedMergeTree(...)
    │   └── All MergeTree features + replication
    └── Default → MergeTree()
        └── Append-only, general-purpose
```

## 1. MergeTree (Default)

**Use cases**: Append-only time series, general analytics, default choice

**Key features:**
- Append-only (no in-place updates)
- Automatic background merges
- Sparse index (8192 rows per mark)
- Supports TTL, partitions, projections

```sql
CREATE TABLE events (
    timestamp DateTime,
    user_id UInt32,
    event_type String,
    metadata String
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (user_id, timestamp)
SETTINGS index_granularity = 8192;

-- Insert data
INSERT INTO events VALUES
    (now(), 123, 'login', '{"ip":"1.2.3.4"}'),
    (now(), 456, 'logout', '{"ip":"5.6.7.8"}');
```

**When to use:**
- Time-series data (events, logs, metrics)
- Append-only workloads
- General analytics

## 2. ReplacingMergeTree

**Use cases**: Upsert-like behavior, latest version wins

**Key features:**
- Deduplicates by ORDER BY on merge
- Async: doesn't guarantee immediate deduplication
- Use version column to control which row to keep
- Requires FINAL for guaranteed deduplication

```sql
CREATE TABLE user_profiles (
    user_id UInt32,
    updated_at DateTime,
    profile_json String
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY user_id;

-- Insert initial profile
INSERT INTO user_profiles VALUES (123, now(), '{"name":"Alice"}');

-- Update profile (insert new version)
INSERT INTO user_profiles VALUES (123, now(), '{"name":"Alice Smith"}');

-- Force final deduplication (expensive!)
SELECT * FROM user_profiles FINAL WHERE user_id = 123;

-- Without FINAL: might return both rows (not merged yet)
```

**Important notes:**
- Deduplication happens during merge (async, not immediate)
- Use FINAL only when necessary (expensive!)
- Better: Design queries to handle duplicates (GROUP BY, argMax)

## 3. CollapsingMergeTree

**Use cases**: Changelog, append-only data with deletes

**Key features:**
- Sign column: 1 = insert, -1 = delete
- Collapses rows on merge
- Must use FINAL for correct results

```sql
CREATE TABLE changes (
    id UInt32,
    sign Int8,  -- MUST be Int8
    data String
)
ENGINE = CollapsingMergeTree(sign)
ORDER BY id;

-- Insert row
INSERT INTO changes VALUES (1, 1, 'data_v1');

-- Update row (insert + delete)
INSERT INTO changes VALUES (1, 1, 'data_v2');  -- New version
INSERT INTO changes VALUES (1, -1, 'data_v1'); -- Delete old

-- Delete row
INSERT INTO changes VALUES (1, -1, '');

-- Query with FINAL (correct results)
SELECT * FROM changes FINAL;
```

## 4. VersionedCollapsingMergeTree

**Use cases**: Multiple versions of same row before collapse

**Key features:**
- Sign column + version column
- Collapses to latest version per sign
- Handles out-of-order inserts

```sql
CREATE TABLE versioned_changes (
    id UInt32,
    version UInt32,
    sign Int8,
    data String
)
ENGINE = VersionedCollapsingMergeTree(sign, version)
ORDER BY (id, version);

-- Insert version 1
INSERT INTO versioned_changes VALUES (1, 1, 1, 'v1');

-- Insert version 2
INSERT INTO versioned_changes VALUES (1, 2, 1, 'v2');

-- Collapse version 1
INSERT INTO versioned_changes VALUES (1, 1, -1, '');
```

## 5. SummingMergeTree

**Use cases**: Pre-aggregation, numeric summation

**Key features:**
- Sums numeric columns on merge
- Leaves first non-numeric value
- Good for incremental counters

```sql
CREATE TABLE daily_counters (
    date Date,
    user_id UInt32,
    page_views UInt64,
    sessions UInt64
)
ENGINE = SummingMergeTree()
PARTITION BY date
ORDER BY (date, user_id);

-- Insert counter data
INSERT INTO daily_counters VALUES (today(), 123, 10, 2);
INSERT INTO daily_counters VALUES (today(), 123, 5, 1);

-- After merge: page_views = 15, sessions = 3
```

## 6. AggregatingMergeTree

**Use cases**: Custom aggregation functions, pre-computed states

**Key features:**
- Stores aggregate function states
- Requires -State/-Merge combinators

```sql
CREATE TABLE daily_stats (
    date Date,
    user_id UInt32,
    hits AggregateFunction(count, UInt32),
    unique_users AggregateFunction(uniqCombined, UInt32)
)
ENGINE = AggregatingMergeTree()
ORDER BY (date, user_id);

-- Insert with state functions
INSERT INTO daily_stats VALUES
    (today(), 123, countState(toUInt32(1)), uniqCombinedState(toUInt32(456)));

-- Query with merge functions
SELECT
    user_id,
    countMerge(hits) as total_hits,
    uniqCombinedMerge(unique_users) as unique_users
FROM daily_stats
WHERE date = today()
GROUP BY user_id;
```

## 7. GraphiteMergeTree

**Use cases**: Graphite monitoring data

```sql
CREATE TABLE graphite (
    path String,
    value Float64,
    timestamp UInt32,
    date Date
)
ENGINE = GraphiteMergeTree('graphite_rollup')
PARTITION BY toYYYYMM(date)
ORDER BY (path, timestamp);
```

## 8. ReplicatedMergeTree

**Use cases**: Production clusters, data replication

**Key features:**
- ZooKeeper-based replication
- Automatic failover
- All MergeTree features + replication

```sql
CREATE TABLE events (
    timestamp DateTime,
    user_id UInt32
)
ENGINE = ReplicatedMergeTree(
    '/clickhouse/tables/{shard}/events',  -- ZooKeeper path
    '{replica}'                           -- Replica name
)
PARTITION BY toYYYYMM(timestamp)
ORDER BY (user_id, timestamp);
```

**Configuration:**
```xml
<!-- /etc/clickhouse-server/config.d/macros.xml -->
<clickhouse>
    <macros>
        <shard>01</shard>
        <replica>replica_1</replica>
    </macros>
</clickhouse>
```

## Special Engines

### Memory

**Use cases**: Small dimension tables, caching

```sql
CREATE TABLE dim_users (
    user_id UInt32,
    name String
)
ENGINE = Memory;
```

### Dictionary

```sql
CREATE TABLE users_dict (
    user_id UInt32,
    email String
)
ENGINE = Dictionary(user_dictionary);
```

### File/URL/S3/HDFS

```sql
-- S3 table
CREATE TABLE s3_data (...)
ENGINE = S3('https://bucket.s3.amazonaws.com/data/*.csv', 'CSV');

-- URL table
CREATE TABLE url_data (...)
ENGINE = URL('https://example.com/data.csv', 'CSV');
```

### Join

```sql
CREATE TABLE users_right (
    user_id UInt32,
    name String
)
ENGINE = Join(ANY, LEFT, user_id);

-- Usage
SELECT * FROM events LEFT JOIN users_right USING (user_id);
```

### Kafka

```sql
CREATE TABLE kafka_events (
    timestamp DateTime,
    data String
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'localhost:9092',
    kafka_topic_list = 'events',
    kafka_group_name = 'clickhouse',
    kafka_format = 'JSONEachRow';
```

## See Also

- `../SKILL.md` - Main skill entry point
- `core-concepts.md` - MergeTree internals and architecture
- `table-design.md` - ORDER BY and partitioning strategies
