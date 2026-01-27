# ClickHouse Schema Design

Database engines, schema organization, and migration strategies.

## Database Engines

ClickHouse supports multiple database engines for different use cases:

### Ordinary (Default)

```sql
CREATE DATABASE my_db ENGINE = Ordinary;
```

Simple database with no special features. Default engine for basic use.

### Atomic (Recommended for Production)

```sql
CREATE DATABASE my_db ENGINE = Atomic;
```

**Features:**
- Supports non-blocking DDL operations
- Atomic table exchange (zero-downtime schema changes)
- Transactional DDL

**Table Exchange:**
```sql
-- Zero-downtime schema change
EXCHANGE TABLES events AND events_v2;

-- Atomic swap - instant, no downtime
```

### Lazy

```sql
CREATE DATABASE my_db ENGINE = Lazy
SETTINGS lazy_database_ttl = 60;
```

**Features:**
- Loaded on first access
- Unloaded after timeout
- Useful for rarely-used databases

### Replicated

```sql
CREATE DATABASE my_db ENGINE = Replicated(
    'zk_path',
    'replica_name'
);
```

**Features:**
- Multi-datacenter setups
- Automatic replication
- ZooKeeper-based coordination

### Dictionary

```sql
CREATE DATABASE my_db ENGINE = Dictionary(dictionaries_db_name);
```

For in-memory dictionary tables.

### PostgreSQL/MySQL (Proxy)

```sql
CREATE DATABASE my_db ENGINE = PostgreSQL(
    'postgres-host:5432',
    'postgres_db',
    'postgres_user',
    'postgres_password'
);
```

Proxy to external databases for queries.

## Schema Organization

Organize databases by environment and purpose:

```sql
-- Environment structure
CREATE DATABASE analytics_raw;      -- Staging tables
CREATE DATABASE analytics_staging;  -- Cleaned data
CREATE DATABASE analytics_prod;     -- Production tables
CREATE DATABASE analytics_mvs;      -- Materialized views
CREATE DATABASE analytics_dicts;    -- Dictionary definitions
```

### Naming Conventions

```sql
-- Tables: snake_case, plural
events, user_sessions, daily_metrics

-- Columns: snake_case
event_timestamp, user_id, session_id

-- Partitions: YYYYMM format
PARTITION BY toYYYYMM(timestamp)

-- Engines: Explicit ENGINE = clause
ENGINE = MergeTree()
```

## Schema Migration Strategy

### Safe Operations (No Data Rewrite)

```sql
-- Add column (safe, metadata-only)
ALTER TABLE events ADD COLUMN new_column UInt32 DEFAULT 0;

-- Add index (safe, background)
ALTER TABLE events ADD INDEX idx_new_column new_column TYPE bloom_filter GRANULARITY 1;

-- Add projection (safe, background)
ALTER TABLE events ADD PROJECTION pr_summary (
    SELECT user_id, count() as cnt
    GROUP BY user_id
);
```

### Unsafe Operations (Require Data Rewrite)

```sql
-- These trigger mutations (expensive!)
ALTER TABLE events DROP COLUMN old_column;
ALTER TABLE events MODIFY COLUMN col Type;
ALTER TABLE events RENAME COLUMN old_name TO new_name;
ALTER TABLE events DELETE WHERE expr;
ALTER TABLE events UPDATE col = expr WHERE expr;
```

### Zero-Downtime Schema Change

```sql
-- 1. Create new table with new schema
CREATE TABLE events_v2 (
    timestamp DateTime,
    user_id UInt32,
    new_column String
)
ENGINE = MergeTree()
ORDER BY (user_id, timestamp);

-- 2. Backfill data
INSERT INTO events_v2 SELECT * FROM events;

-- 3. Verify data
SELECT count() FROM events;
SELECT count() FROM events_v2;

-- 4. Swap tables (atomic, instantaneous)
EXCHANGE TABLES events AND events_v2;

-- 5. Drop old table after validation
DROP TABLE events_v2;
```

### Schema Version Control

**Best practices:**
- Store all DDL in version control (Git)
- Use migration tools: `clickhouse-migrate`, `golang-migrate`
- Document table relationships and dependencies
- Track migration order to support rollbacks
- Test migrations on staging first

```sql
-- Example migration tracking table
CREATE TABLE schema_migrations (
    version UInt32,
    description String,
    applied_at DateTime,
    checksum String
)
ENGINE = MergeTree()
ORDER BY version;
```

## Database Configuration

### Settings

```sql
-- Database-level settings
ALTER DATABASE my_db MODIFY SETTING max_bytes = 10000000000;

-- Check database settings
SELECT * FROM system.databases WHERE name = 'my_db';
```

### Quotas

```sql
CREATE QUOTA my_quota
KEYED BY user_name
FOR INTERVAL 1 hour
MAX queries = 1000
MAX errors = 100
MAX result_rows = 1000000000
MAX result_bytes = 10000000000
MAX read_rows = 10000000000
MAX read_bytes = 100000000000
MAX execution_time = 60
TO user_name;
```

## See Also

- `../SKILL.md` - Main skill entry point
- `core-concepts.md` - Architecture and data model
- `table-design.md` - ORDER BY and partitioning strategies
