# ClickHouse Table Design

ORDER BY design, partitioning strategies, column selection, and sampling.

## ORDER BY Design (CRITICAL)

The ORDER BY clause defines **data layout on disk** - the most important schema decision!

### ORDER BY Design Principles

1. **Match query WHERE patterns**: Most selective filter first
2. **Time-series**: Timestamp as second column (after dimension)
3. **High-cardinality first**: user_id before event_type
4. **Limit to 3-4 columns**: More columns = larger index

### Examples

```sql
-- ✅ GOOD: ORDER BY matches query pattern
CREATE TABLE events (
    user_id UInt32,
    event_timestamp DateTime,
    event_type String
)
ENGINE = MergeTree()
ORDER BY (user_id, event_timestamp);

-- Query leverages index (reads contiguous data)
SELECT * FROM events
WHERE user_id = 123
  AND event_timestamp >= now() - INTERVAL 1 DAY;

-- ❌ BAD: ORDER BY doesn't match queries
CREATE TABLE events (
    user_id UInt32,
    event_timestamp DateTime,
    event_type String
)
ENGINE = MergeTree()
ORDER BY (event_timestamp);

-- Query scans all data (timestamp-ordered, but filtering by user_id)
SELECT * FROM events WHERE user_id = 123;
```

### Primary Key vs Sorting Key

```sql
-- Sorting key: defines data layout on disk
ORDER BY (user_id, event_timestamp, event_type)

-- Primary key: subset of ORDER BY for row-level index
PRIMARY KEY (user_id, event_timestamp)

-- Effect:
-- - Data on disk: sorted by (user_id, timestamp, event_type)
-- - Primary index: only (user_id, timestamp)
-- - Queries filtering by user_id + timestamp use index
-- - Queries scanning event_type read more data
```

**When to use different PRIMARY KEY:**
- Want to optimize for queries that filter on subset of ORDER BY
- Reduce primary key size (faster index scans)
- Note: PRIMARY KEY must be prefix of ORDER BY

### Common ORDER BY Patterns

```sql
-- Time-series by user
ORDER BY (user_id, timestamp)

-- Time-series by sensor
ORDER BY (sensor_id, timestamp)

-- Multi-tenant time-series
ORDER BY (tenant_id, user_id, timestamp)

-- Event log
ORDER BY (timestamp, event_type)

-- Metrics
ORDER BY (metric_name, timestamp, labels_hash)
```

## Partition Strategy

Partitions enable fast data drop and TTL operations:

### Time-Based Partitioning (Most Common)

```sql
-- Monthly partitions (recommended for 10GB+ per day)
PARTITION BY toYYYYMM(timestamp);
-- Results: partitions like '202401', '202402', ...

-- Daily partitions (for high-volume, 1GB+ per day)
PARTITION BY toDate(timestamp);
-- Results: one partition per day
```

### Custom Partitioning

```sql
-- By tenant (multi-tenant cleanup)
PARTITION BY tenant_id;
-- Drop all data for tenant: ALTER TABLE DROP PARTITION 'tenant_123';

-- Composite (use carefully - too many partitions!)
PARTITION BY (tenant_id, toYYYYMM(timestamp));
-- Results: 'tenant_123_202401', 'tenant_123_202402', ...
```

### Partitioning Guidelines

| Data Volume | Recommended Partitioning |
|-------------|---------------------------|
| < 1GB/day | No partitioning or monthly |
| 1-10GB/day | Monthly partitions |
| 10-100GB/day | Daily partitions |
| > 100GB/day | Daily + sharding |

**Key principles:**
- Aim for 100-1000 parts total across all partitions
- Monthly partitions: Good for 10GB+ per day
- Daily partitions: Good for 1GB+ per day
- Too many partitions = slow queries, high merge overhead

### Partition Operations

```sql
-- Drop partition (instant, no mutation)
ALTER TABLE events DROP PARTITION '202401';

-- Detach/Attach partition
ALTER TABLE events DETACH PARTITION '202401';
ALTER TABLE events ATTACH PARTITION '202401';

-- Freeze partition (for backup)
ALTER TABLE events FREEZE PARTITION '202401';

-- Check partition sizes
SELECT
    partition,
    sum(rows) as total_rows,
    formatReadableSize(sum(bytes)) as size
FROM system.parts
WHERE active = 1 AND table = 'events'
GROUP BY partition
ORDER BY partition DESC;
```

## Column Selection

Choose smallest sufficient type:

### Numeric Types

```sql
-- Use smallest integer type
UInt8   -- 0-255
UInt16  -- 0-65,535
UInt32  -- 0-4,294,967,295
UInt64  -- 0-18,446,744,073,709,551,615

-- Decimal for currency
Decimal(18, 2)  -- Up to 999 trillion
Decimal(10, 2)  -- Smaller range, faster
```

### Temporal Types

```sql
timestamp Date           -- 2 bytes (days since epoch)
timestamp DateTime       -- 4 bytes (seconds since epoch)
timestamp DateTime64(3)  -- 8 bytes (milliseconds)
```

### String Types

```sql
-- LowCardinality for enum-like strings (< 10k distinct values)
event_type LowCardinality(String)

-- Nullable vs default values
status Nullable(String)   -- Has overhead (special NULL marker)
status String DEFAULT ''  -- Better: Use default value
```

## Sampling Key

Enable SAMPLE queries for approximate analytics:

```sql
-- Enable sampling
CREATE TABLE events (
    user_id UInt32,
    event_timestamp DateTime,
    data String
)
ENGINE = MergeTree()
ORDER BY (user_id, event_timestamp)
SAMPLE BY user_id;  -- Must be column in ORDER BY

-- Query with sampling (10% of data)
SELECT * FROM events SAMPLE 0.1;

-- Sampling with interpolation
SELECT
    user_id,
    count() * 10 as estimated_count  -- Multiply by 1/sampling_rate
FROM events
SAMPLE 0.1
GROUP BY user_id;
```

**Use cases for sampling:**
- Exploratory analytics (fast approximate results)
- Testing queries on large datasets
- Dashboard previews (refresh faster)

## Codecs

Apply compression to individual columns:

```sql
-- ZSTD compression (good default)
CREATE TABLE events (
    data String CODEC(ZSTD)
)
ENGINE = MergeTree()
ORDER BY user_id;

-- Compression levels
CODEC(ZSTD(3))   -- Fast, less compression
CODEC(ZSTD(15))  -- Slower, more compression

-- No compression (for already compressed data)
CODEC(NONE)

-- Multiple codecs
CODEC(Delta, ZSTD)

-- LZ4 (faster than ZSTD, less compression)
CODEC(LZ4)
```

**Codec guidelines:**
- Use ZSTD for most data (good balance)
- Use NONE for already-compressed data (images, encrypted data)
- Use Delta for monotonically increasing values (timestamps, IDs)
- Higher compression levels = slower queries

## Skip Indexes

Data skipping indexes allow ClickHouse to skip data during reads:

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

**Index types:**
- `minmax`: Min/max values per granule
- `set`: Set of values (good for IN queries)
- `bloom_filter`: Probabilistic exact match
- `tokenbf_v1`: Token-based bloom filter for text search

**Granularity:**
- Lower = more precise index, larger index size
- Higher = less precise index, smaller index size
- Default: 1 (most precise)

## Table Settings

```sql
CREATE TABLE events (
    timestamp DateTime,
    user_id UInt32
)
ENGINE = MergeTree()
ORDER BY (user_id, timestamp)
SETTINGS
    index_granularity = 8192,        -- Rows per mark (default)
    index_granularity_bytes = 10485760, -- Bytes per mark
    enable_mixed_granularity_parts = 1,  -- Adaptive marks
    min_rows_for_wide_part = 0,       -- Always use wide parts
    merge_max_block_size = 1048544,   -- Block size for merges
    storage_policy = 'default';       -- Storage policy
```

## See Also

- `../SKILL.md` - Main skill entry point
- `core-concepts.md` - MergeTree internals
- `table-engines.md` - Complete table engine reference
- `schema-design.md` - Database engines and migrations
