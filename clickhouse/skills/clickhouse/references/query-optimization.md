# ClickHouse Query Optimization

Techniques for optimizing ClickHouse query performance.

## EXPLAIN

Use EXPLAIN to understand query execution:

```sql
-- Basic explain
EXPLAIN SELECT * FROM events WHERE user_id = 123;

-- Readable query plan
EXPLAIN PLAN SELECT * FROM events WHERE user_id = 123;

-- Pipeline details
EXPLAIN PIPELINE SELECT * FROM events WHERE user_id = 123;

-- With estimates
EXPLAIN ESTIMATE SELECT * FROM events WHERE user_id = 123;
```

**Key indicators:**
- `"Filter"` → Not using index (full scan)
- `"Index"` → Using index marks
- `"Projection"` → Pre-computed data
- `"Filter with index"` → Using skip index

## JOIN Optimization

### Rule: Smaller Table on RIGHT

```sql
-- ✅ Good: Smaller table on RIGHT
SELECT *
FROM large_table lt
RIGHT JOIN small_table st ON lt.id = st.id;

-- ❌ Bad: Large table on RIGHT
SELECT *
FROM small_table st
LEFT JOIN large_table lt ON lt.id = st.id;
```

**Why?** ClickHouse sends RIGHT table to all shards. Smaller RIGHT = less network transfer.

### GLOBAL JOIN for Distributed Queries

```sql
-- For distributed queries, use GLOBAL
SELECT *
FROM large_table lt
GLOBAL RIGHT JOIN small_table st ON lt.id = st.id;

-- GLOBAL ensures right table is sent once to each shard
```

### ASOF JOIN for Time-Series

```sql
-- As-of join for time-series (latest value before timestamp)
SELECT *
FROM ticks t
ASOF LEFT JOIN quotes q
ON t.symbol = q.symbol
AND t.time <= q.time;
```

## GROUP BY Optimization

### WITH ROLLUP

```sql
-- Hierarchical aggregation
SELECT
    user_id,
    event_type,
    count() as cnt
FROM events
GROUP BY user_id, event_type WITH ROLLUP;
-- Results: (user, type), (user, NULL), (NULL, NULL)
```

### WITH CUBE

```sql
-- All combinations
SELECT
    user_id,
    event_type,
    count() as cnt
FROM events
GROUP BY user_id, event_type WITH CUBE;
-- Results: All 4 combinations
```

## Projections (Pre-computed Aggregations)

Projections automatically speed up common aggregations:

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

**When projections are used:**
- Query GROUP BY matches projection GROUP BY
- Query SELECT matches projection SELECT
- Automatic (no query changes needed)

## Skip Indexes

Skip indexes allow data skipping during reads:

```sql
-- Bloom filter for exact match
CREATE TABLE events (
    user_id UInt32,
    email String,
    timestamp DateTime
)
ENGINE = MergeTree()
ORDER BY (user_id, timestamp)
INDEX idx_email email TYPE bloom_filter GRANULARITY 1;

-- Minmax for range queries
INDEX idx_time timestamp TYPE minmax GRANULARITY 4;

-- Set for IN queries
INDEX idx_user user_id TYPE set(1000) GRANULARITY 1;

-- Tokenbf for string search
INDEX idx_msg message TYPE tokenbf_v1(512, 3, 0) GRANULARITY 1;
```

**Skip index types:**
- `minmax`: Min/max values per granule
- `set`: Set of values (good for IN queries)
- `bloom_filter`: Probabilistic exact match
- `tokenbf_v1`: Token-based bloom filter for text search

**Check if index used:**
```sql
EXPLAIN SELECT * FROM events WHERE email = 'user@example.com';
-- Look for "Index" or "Filter with index" in output
```

## Common Query Pitfalls

```sql
-- ❌ SELECT * reads all columns (expensive in columnar store)
SELECT * FROM events;

-- ✅ Select only needed columns
SELECT user_id, timestamp, event_type FROM events;

-- ❌ Suboptimal WHERE (function on column)
SELECT * FROM events WHERE toDate(timestamp) = today();

-- ✅ Use date functions on literal
SELECT * FROM events
WHERE timestamp >= today() AND timestamp < tomorrow();

-- ❌ String comparison for dates
SELECT * FROM events WHERE toString(timestamp) LIKE '2024-01-01%';

-- ✅ Use date range
SELECT * FROM events
WHERE timestamp >= toDateTime('2024-01-01 00:00:00')
  AND timestamp < toDateTime('2024-01-02 00:00:00');
```

## Window Functions

```sql
-- Ranking
SELECT
    user_id,
    event_timestamp,
    row_number() OVER (PARTITION BY user_id ORDER BY event_timestamp) as rn
FROM events;

-- Running totals
SELECT
    date,
    revenue,
    sum(revenue) OVER (ORDER BY date) as running_total
FROM daily_revenue;

-- Lag/Lead
SELECT
    date,
    revenue,
    lag(revenue, 1) OVER (ORDER BY date) as prev_revenue,
    lead(revenue, 1) OVER (ORDER BY date) as next_revenue
FROM daily_revenue;
```

## Performance Tuning Settings

```sql
-- Increase memory limit
SET max_memory_usage = 10000000000;

-- Parallel processing
SET max_threads = 8;

-- Block size
SET max_block_size = 65536;

-- Disable query cache
SET use_uncompressed_cache = 0;
```

## Query Profiling Checklist

- [ ] Used EXPLAIN to verify index usage
- [ ] Selected only needed columns (no SELECT *)
- [ ] Used date range filters instead of functions on columns
- [ ] Smaller table on RIGHT side of JOIN
- [ ] Used GLOBAL JOIN for distributed queries
- [ ] Added skip indexes for frequent filters
- [ ] Considered projections for common aggregations
- [ ] Set appropriate max_memory_usage

## See Also

- `../SKILL.md` - Main skill entry point
- `sql-reference.md` - Complete SQL dialect
- `table-design.md` - ORDER BY and indexing strategies
