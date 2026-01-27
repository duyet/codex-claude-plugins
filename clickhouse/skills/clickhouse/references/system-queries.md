# ClickHouse System Queries

Useful queries for monitoring, debugging, and managing ClickHouse databases.

---

## Table Information

### Table Sizes

```sql
-- All tables with sizes
SELECT
    database,
    table,
    formatReadableSize(sum(bytes)) as size,
    sum(rows) as total_rows,
    count() as parts
FROM system.parts
WHERE active = 1
GROUP BY database, table
ORDER BY sum(bytes) DESC;

-- Top 20 largest tables
SELECT
    database,
    table,
    formatReadableSize(sum(bytes)) as size,
    sum(rows) as total_rows
FROM system.parts
WHERE active = 1
GROUP BY database, table
ORDER BY sum(bytes) DESC
LIMIT 20;

-- Tables by row count
SELECT
    database,
    table,
    sum(rows) as total_rows,
    formatReadableQuantity(sum(rows)) as readable_rows
FROM system.parts
WHERE active = 1
GROUP BY database, table
ORDER BY sum(rows) DESC
LIMIT 20;
```

### Column Information

```sql
-- Column sizes and compression
SELECT
    database,
    table,
    column,
    type,
    formatReadableSize(sum(data_uncompressed_bytes)) as uncompressed,
    formatReadableSize(sum(data_compressed_bytes)) as compressed,
    sum(data_compressed_bytes) / sum(data_uncompressed_bytes) as ratio
FROM system.columns
WHERE database != 'system'
GROUP BY database, table, column, type
ORDER BY sum(data_uncompressed_bytes) DESC
LIMIT 50;

-- All columns in a table
SELECT
    name,
    type,
    default_kind,
    default_expression,
    comment
FROM system.columns
WHERE database = 'my_database'
  AND table = 'my_table'
ORDER BY position;
```

### Partition Information

```sql
-- Partition details
SELECT
    partition,
    sum(rows) as total_rows,
    count() as parts,
    formatReadableSize(sum(bytes)) as size,
    min(min_timestamp) as min_time,
    max(max_timestamp) as max_time
FROM system.parts
WHERE active = 1
  AND table = 'my_table'
  AND database = currentDatabase()
GROUP BY partition
ORDER BY partition DESC;

-- Large partitions (many parts)
SELECT
    partition,
    count() as parts,
    sum(rows) as total_rows
FROM system.parts
WHERE active = 1
  AND table = 'my_table'
GROUP BY partition
HAVING parts > 100
ORDER BY parts DESC;
```

---

## Query Monitoring

### Running Queries

```sql
-- All running queries
SELECT
    query_id,
    user,
    query,
    elapsed,
    formatReadableSize(memory_usage) as memory,
    formatReadableQuantity(read_rows) as rows_read,
    formatReadableSize(read_bytes) as bytes_read
FROM system.processes
ORDER BY elapsed DESC;

-- Long-running queries (> 1 minute)
SELECT
    query_id,
    user,
    query,
    elapsed / 60 as minutes_elapsed,
    formatReadableSize(memory_usage) as memory
FROM system.processes
WHERE elapsed > 60
ORDER BY elapsed DESC;

-- Queries by user
SELECT
    user,
    count() as query_count,
    sum(memory_usage) as total_memory
FROM system.processes
GROUP BY user
ORDER BY total_memory DESC;
```

### Query History

```sql
-- Recent queries (last hour)
SELECT
    type,
    substring(query, 1, 100) as query_preview,
    query_duration_ms / 1000 as seconds,
    formatReadableSize(memory_usage) as memory,
    event_time
FROM system.query_log
WHERE event_time > now() - INTERVAL 1 HOUR
ORDER BY event_time DESC
LIMIT 100;

-- Slow queries (> 5 seconds)
SELECT
    query,
    query_duration_ms / 1000 as seconds,
    formatReadableSize(memory_usage) as memory,
    formatReadableQuantity(read_rows) as rows_read,
    event_time
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query_duration_ms > 5000
ORDER BY query_duration_ms DESC
LIMIT 20;

-- Most expensive by memory
SELECT
    query,
    formatReadableSize(memory_usage) as memory,
    query_duration_ms / 1000 as seconds
FROM system.query_log
WHERE type = 'QueryFinish'
ORDER BY memory_usage DESC
LIMIT 10;

-- Failed queries
SELECT
    query,
    exception_code,
    exception_text,
    event_time
FROM system.query_log
WHERE type = 'Exception'
  AND event_time > now() - INTERVAL 1 DAY
ORDER BY event_time DESC
LIMIT 50;
```

### Query Statistics by Table

```sql
-- Most accessed tables
SELECT
    database,
    table,
    count() as query_count,
    sum(read_rows) as total_rows_read,
    avg(query_duration_ms) as avg_duration_ms
FROM system.query_log
WHERE type = 'QueryFinish'
  AND event_date = today()
GROUP BY database, table
ORDER BY query_count DESC
LIMIT 20;

-- Queries by type
SELECT
    type,
    count() as count,
    avg(query_duration_ms) as avg_duration_ms
FROM system.query_log
WHERE event_date = today()
GROUP BY type
ORDER BY count DESC;
```

---

## Merge Monitoring

### Active Merges

```sql
-- Current merges
SELECT
    database,
    table,
    elapsed,
    progress,
    formatReadableSize(bytes_read_uncompressed) as bytes_read,
    rows_read,
    is_mutation,
    merge_type
FROM system.merges
ORDER BY elapsed DESC;

-- Merge performance by day
SELECT
    table,
    count() as merge_count,
    avg(bytes_read_uncompressed) as avg_size,
    sum(rows_read) as total_rows
FROM system.merges
WHERE event_date = today()
GROUP BY table
ORDER BY merge_count DESC;

-- Merge queue size
SELECT
    database,
    table,
    count() as parts_to_merge,
    sum(bytes) as total_bytes
FROM system.parts
WHERE active = 1
  AND rows > 0
GROUP BY database, table
HAVING parts_to_merge > 100
ORDER BY parts_to_merge DESC;
```

### Merge Statistics

```sql
-- Merge performance over time
SELECT
    toStartOfHour(event_time) as hour,
    count() as merge_count,
    avg(bytes_read_uncompressed) as avg_size,
    sum(rows_read) as total_rows
FROM system.part_log
WHERE event_time > now() - INTERVAL 1 DAY
  AND event_type = 'MergeParts'
GROUP BY hour
ORDER BY hour;
```

---

## Mutation Monitoring

### Active Mutations

```sql
-- Current mutations
SELECT
    database,
    table,
    command,
    is_done,
    parts_to_do,
    parts_to_do_names,
    formatReadableSize(bytes_read_uncompressed) as bytes_processed
FROM system.mutations
WHERE is_done = 0;

-- Mutation progress
SELECT
    table,
    command,
    is_done,
    parts_to_do - parts_to_do_names as parts_remaining,
    elapsed
FROM system.mutations
ORDER BY parts_to_do DESC;

-- All mutations history
SELECT
    database,
    table,
    command,
    is_done,
    created_at,
    finished_at
FROM system.mutations
ORDER BY created_at DESC
LIMIT 50;
```

---

## Replication Monitoring

### Replica Status

```sql
-- All replicas
SELECT
    database,
    table,
    is_leader,
    is_readonly,
    queue_size,
    absolute_delay,
    delay * 1000 as lag_ms
FROM system.replicas
ORDER BY absolute_delay DESC;

-- Replication queue
SELECT * FROM system.replication_queue
WHERE delay > 5
ORDER BY delay DESC;

-- Replication lag by table
SELECT
    database,
    table,
    replica_name,
    is_leader,
    is_readonly,
    queue_size,
    absolute_delay
FROM system.replicas
WHERE absolute_delay > 10
ORDER BY absolute_delay DESC;
```

### ZooKeeper Status

```sql
-- ZooKeeper connection
SELECT * FROM system.zookeeper WHERE path = '/';

-- Check ZooKeeper path
SELECT
    name,
    value,
    data
FROM system.zookeeper
WHERE path = '/clickhouse/tables';
```

---

## Disk and Storage

### Disk Usage

```sql
-- All disks
SELECT
    name,
    path,
    formatReadableSize(free_space) as free,
    formatReadableSize(total_space) as total,
    formatReadableSize(keep_free_space) as keep_free,
    (free_space / total_space) * 100 as percent_free
FROM system.disks;

-- Disk usage by table
SELECT
    disk_name,
    database,
    table,
    formatReadableSize(sum(bytes_on_disk)) as size
FROM system.parts
WHERE active = 1
GROUP BY disk_name, database, table
ORDER BY sum(bytes_on_disk) DESC
LIMIT 20;
```

### Storage Policies

```sql
-- All storage policies
SELECT * FROM system.storage_policies;

-- Volumes in storage policies
SELECT * FROM system.disks;
```

---

## Cluster Information

### Cluster Status

```sql
-- All clusters
SELECT * FROM system.clusters;

-- Cluster nodes
SELECT
    cluster,
    shard_num,
    replica_num,
    host_name,
    port,
    user
FROM system.clusters
WHERE cluster = 'my_cluster';

-- Cluster health
SELECT
    cluster,
    sum(error_count) as errors,
    sum(num_requests) as requests
FROM system.clusters
GROUP BY cluster;
```

---

## Database Information

### All Databases

```sql
-- All databases
SELECT
    name,
    engine,
    data_path,
    metadata_path
FROM system.databases
ORDER BY name;

-- Database engine types
SELECT
    engine,
    count() as count
FROM system.databases
GROUP BY engine
ORDER BY count DESC;
```

---

## User and Security

### User Information

```sql
-- All users
SELECT * FROM system.users;

-- User quotas
SELECT * FROM system.quotas;

-- Current roles
SELECT * FROM system.current_roles;
```

### Access Control

```sql
-- Row policies
SELECT * FROM system.row_policies;

-- Grants
SELECT * FROM system.grants;
```

---

## System Health

### General Health

```sql
-- Server info
SELECT version(), uptime(), now() as current_time;

-- Memory usage
SELECT
    formatReadableSize(sum(bytes_allocated)) as allocated,
    formatReadableSize(sum(bytes_used)) as used
FROM system.dictionaries;

-- Load average
SELECT * FROM system.asynchronous_metrics
WHERE metric LIKE '%load%';
```

### Settings

```sql
-- All settings
SELECT * FROM system.settings
ORDER BY name;

-- Current settings
SELECT * FROM system.settings
WHERE changed == 1;
```

---

## Dictionary Information

### All Dictionaries

```sql
-- Dictionary status
SELECT
    name,
    status,
    origin,
    type,
    element_count,
    bytes_allocated
FROM system.dictionaries
ORDER BY name;

-- Loading dictionaries
SELECT
    name,
    status,
    loading_start_time,
    loading_duration_seconds
FROM system.dictionaries
WHERE status != 'LOADED';
```

---

## Formatted Queries

### Human-Readable Output

```sql
-- Size formatted
SELECT
    database,
    table,
    formatReadableSize(sum(bytes)) as size,
    formatReadableQuantity(sum(rows)) as rows,
    formatReadableSize(sum(bytes_on_disk)) as on_disk
FROM system.parts
WHERE active = 1
GROUP BY database, table
ORDER BY sum(bytes) DESC
LIMIT 20;

-- Time formatted
SELECT
    query,
    formatDateTime(query_start_time, '%Y-%m-%d %H:%M:%S') as started,
    formatDuration(query_duration_ms / 1000) as duration
FROM system.query_log
WHERE type = 'QueryFinish'
ORDER BY query_start_time DESC
LIMIT 10;
```

---

## Quick Diagnostic Queries

### One-Liner Health Checks

```sql
-- Quick health check
SELECT 'uptime' as metric, toString(uptime()) as value
UNION ALL SELECT 'version', version()
UNION ALL SELECT 'running_queries', toString(count())
FROM system.processes
UNION ALL SELECT 'active_merges', toString(count())
FROM system.merges
UNION ALL SELECT 'replication_lag', toString(count())
FROM system.replication_queue WHERE delay > 5;

-- Table count by database
SELECT database, count() as tables
FROM system.tables
WHERE database != 'system'
GROUP BY database
ORDER BY tables DESC;

-- Parts count (health check)
SELECT
    database,
    table,
    count() as parts,
    sum(rows) as total_rows
FROM system.parts
WHERE active = 1
GROUP BY database, table
HAVING parts > 1000
ORDER BY parts DESC;
```

---

## Useful Subqueries

### Find Problematic Queries

```sql
-- Queries with exceptions
SELECT
    query,
    exception_text,
    count() as error_count
FROM system.query_log
WHERE type = 'Exception'
  AND event_date = today()
GROUP BY query, exception_text
ORDER BY error_count DESC
LIMIT 20;

-- Queries reading too much data
SELECT
    query,
    read_rows,
    formatReadableQuantity(read_rows) as readable_rows,
    read_bytes,
    formatReadableSize(read_bytes) as readable_bytes
FROM system.query_log
WHERE type = 'QueryFinish'
  AND event_date = today()
  AND read_rows > 1000000000
ORDER BY read_rows DESC
LIMIT 20;
```

### Table Growth Over Time

```sql
-- Daily table growth
SELECT
    toStartOfDay(event_time) as day,
    database,
    table,
    formatReadableSize(sum(bytes)) as size
FROM system.part_log
WHERE event_type = 'NewPart'
  AND event_time > now() - INTERVAL 7 DAY
GROUP BY day, database, table
ORDER BY day DESC, sum(bytes) DESC;
```

---

**Tips**:
- Use `formatReadableSize()` for human-readable byte sizes
- Use `formatReadableQuantity()` for human-readable row counts
- Filter `WHERE active = 1` to see only active parts
- Use `currentDatabase()` to refer to current database
- Most `system.*` tables have `event_date` for partitioning
