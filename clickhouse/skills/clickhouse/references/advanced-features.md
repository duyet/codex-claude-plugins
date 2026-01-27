# ClickHouse Advanced Features

Materialized views, mutations, TTL, dictionaries, and other advanced capabilities.

## Materialized Views

Materialized views automatically process data on INSERT:

### Basic Materialized View

```sql
-- Pre-aggregate on write
CREATE MATERIALIZED VIEW mv_daily_stats
ENGINE = AggregatingMergeTree()
ORDER BY (date, user_id)
AS SELECT
    toDate(timestamp) as date,
    user_id,
    countState() as hits,
    sumState(revenue) as total_revenue
FROM events
GROUP BY date, user_id;

-- Query MV (fast - already aggregated!)
SELECT
    user_id,
    countMerge(hits) as total_hits,
    sumMerge(total_revenue) as revenue
FROM mv_daily_stats
WHERE date = today()
GROUP BY user_id;
```

### Materialized View to Target Table

```sql
-- Create target table
CREATE TABLE daily_stats (
    date Date,
    user_id UInt32,
    hits UInt64,
    revenue Decimal(18, 2)
)
ENGINE = AggregatingMergeTree()
ORDER BY (date, user_id);

-- Create MV that populates target table
CREATE MATERIALIZED VIEW mv_populate_daily_stats
TO daily_stats
AS SELECT
    toDate(timestamp) as date,
    user_id,
    count() as hits,
    sum(revenue) as revenue
FROM events
GROUP BY date, user_id;
```

### POPULATE Option

```sql
-- Create MV and backfill existing data
CREATE MATERIALIZED VIEW mv_daily_stats
ENGINE = AggregatingMergeTree()
ORDER BY (date, user_id)
POPULATE  -- Backfill existing data
AS SELECT
    toDate(timestamp) as date,
    user_id,
    count() as hits
FROM events
GROUP BY date, user_id;
```

### Drop Materialized View

```sql
-- Drop MV (target table data remains)
DROP TABLE mv_daily_stats;
```

**Materialized view use cases:**
- Pre-aggregation (sum, count, avg)
- Rollup data (hourly → daily)
- Data routing (INSERT → multiple tables)
- Real-time analytics

## Mutations

Mutations are async UPDATE/DELETE operations:

### UPDATE

```sql
-- UPDATE (async, expensive - rewrites all data)
ALTER TABLE events UPDATE status = 'done'
WHERE event_id = 123;

-- Multiple columns
ALTER TABLE events UPDATE
    status = 'done',
    processed_at = now()
WHERE event_id = 123;
```

### DELETE

```sql
-- DELETE (async, expensive - rewrites all data)
ALTER TABLE events DELETE
WHERE timestamp < now() - INTERVAL 90 DAY;
```

### Monitor Mutations

```sql
-- Show all mutations
SELECT * FROM system.mutations;

-- Active mutations
SELECT
    database,
    table,
    command,
    is_done,
    parts_to_do,
    parts_to_do_names,
    elapsed
FROM system.mutations
WHERE is_done = 0;

-- Mutation progress
SELECT
    table,
    command,
    is_done,
    parts_to_do - parts_to_do_names as parts_remaining
FROM system.mutations
ORDER BY parts_to_do DESC;
```

### Force Mutation Completion

```sql
-- Wait for mutation to complete
SYSTEM STOP MERGES;
ALTER TABLE ... UPDATE ...;
OPTIMIZE TABLE ... FINAL;
SYSTEM START MERGES;
```

**Mutation characteristics:**
- Async: Doesn't block table
- Expensive: Rewrites all data
- Can be slow on large tables
- Better: Use TTL or new tables

## TTL (Time To Live)

TTL automatically manages data lifecycle:

### Delete Old Data

```sql
-- Delete old data
CREATE TABLE events (
    timestamp DateTime,
    data String
)
ENGINE = MergeTree()
ORDER BY timestamp
TTL timestamp + INTERVAL 90 DAY;
```

### Recompress Old Data

```sql
-- Change compression over time
CREATE TABLE events (
    timestamp DateTime,
    data String
)
ENGINE = MergeTree()
ORDER BY timestamp
TTL
    timestamp + INTERVAL 7 DAY TO VOLUME 'cold',
    timestamp + INTERVAL 30 DAY TO DISK 's3';
```

### Column TTL

```sql
-- Column-level TTL
CREATE TABLE events (
    timestamp DateTime,
    data String,
    metadata String TTL timestamp + INTERVAL 30 DAY DELETE
)
ENGINE = MergeTree()
ORDER BY timestamp;
```

### Modify TTL

```sql
-- Modify table TTL
ALTER TABLE events
MODIFY TTL timestamp + INTERVAL 180 DAY;

-- Modify column TTL
ALTER TABLE events
MODIFY COLUMN metadata TTL timestamp + INTERVAL 60 DAY DELETE;
```

### Drop Partition (Instant)

```sql
-- Drop entire partition (instant, no mutation)
ALTER TABLE events DROP PARTITION '202401';
```

**TTL operations:**
- Delete old data
- Move to cold storage
- Change compression codec
- Drop partition (instant)

## Dictionaries

Dictionaries provide fast in-memory lookups:

### PostgreSQL Dictionary

```sql
-- Create dictionary
CREATE DICTIONARY users_dict (
    user_id UInt32,
    email String,
    name String,
    created_at DateTime
)
PRIMARY KEY user_id
SOURCE(POSTGRESQL(
    port 5432
    host 'localhost'
    db 'mydb'
    table 'users'
    user 'user'
    password 'pass'
))
LIFETIME(60)  -- Refresh every 60 seconds
LAYOUT(HASHED());

-- Use in query
SELECT
    e.user_id,
    dictGet('users_dict', 'email', e.user_id) as email,
    dictGet('users_dict', 'name', e.user_id) as name
FROM events e;
```

### Cache Dictionary

```sql
CREATE DICTIONARY users_cache (
    user_id UInt32,
    email String
)
PRIMARY KEY user_id
SOURCE(POSTGRESQL(...))
LIFETIME(300)
LAYOUT(CACHE(SIZE_IN_CELLS 10000));  -- LRU cache
```

### Dictionary Functions

```sql
-- Get value
dictGet('dict_name', 'attribute_type', key)
dictGetOrDefault('dict_name', 'attribute_type', key, default_value)
dictHas('dict_name', key)

-- Check dictionary status
SELECT * FROM system.dictionaries WHERE name = 'users_dict';
```

### Dictionary Layouts

| Layout | Use Case | Description |
|--------|----------|-------------|
| FLAT | Small dictionaries (< 1M keys) | Fastest, array-based |
| HASHED | Medium dictionaries (1M-10M keys) | Hash table |
| CACHE | Large dictionaries, rare lookups | LRU cache |
| RANGE | Numeric range lookups | Range queries |
| COMPLEX_KEY | Composite keys | Tuple keys |
| IP_TRIE | IP address lookups | CIDR matching |

## Projections

Projections are materialized views at part level:

```sql
-- Create projection
ALTER TABLE events ADD PROJECTION pr_user_daily (
    SELECT
        user_id,
        toDate(timestamp) as date,
        count() as events,
        sum(revenue) as total_revenue
    GROUP BY user_id, date
);

-- Query automatically uses projection (fast!)
SELECT
    user_id,
    date,
    count() as events,
    sum(revenue) as total_revenue
FROM events
GROUP BY user_id, date;

-- Drop projection
ALTER TABLE events DROP PROJECTION pr_user_daily;
```

**Projection benefits:**
- Automatic usage (no query changes)
- Faster than materialized views
- Maintained per-part (smaller overhead)

## FINAL Clause

FINAL forces application of mutations:

```sql
-- Force deduplication (expensive!)
SELECT * FROM ReplacingMergeTree_table FINAL WHERE user_id = 123;

-- Check what FINAL does
EXPLAIN SELECT * FROM table FINAL;

-- Better: Design queries to handle duplicates
SELECT
    user_id,
    argMax(profile, updated_at) as latest_profile
FROM user_profiles
GROUP BY user_id;
```

## See Also

- `../SKILL.md` - Main skill entry point
- `table-engines.md` - Complete table engine reference
- `debugging.md` - Mutation monitoring and troubleshooting
