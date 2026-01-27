# ClickHouse Monitoring

Query monitoring, health checks, system queries, and metrics.

## Current Query Monitoring

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

### Kill Query

```sql
-- Kill specific query
KILL QUERY WHERE query_id = 'query-id';

-- Kill all queries from user
KILL QUERY WHERE user = 'username';

-- Kill long-running queries
KILL QUERY WHERE elapsed > 3600;
```

## Query History

### Recent Queries

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
```

### Slow Queries

```sql
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
```

### Failed Queries

```sql
-- Failed queries with errors
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

## Table Usage

### Most Accessed Tables

```sql
-- Most queried tables
SELECT
    database,
    table,
    count() as query_count,
    sum(read_rows) as total_rows,
    avg(query_duration_ms) as avg_duration_ms
FROM system.query_log
WHERE type = 'QueryFinish'
  AND event_date = today()
GROUP BY database, table
ORDER BY query_count DESC
LIMIT 20;
```

### Table Sizes

```sql
-- Tables by size
SELECT
    database,
    table,
    formatReadableSize(sum(bytes)) as size,
    sum(rows) as total_rows,
    count() as parts
FROM system.parts
WHERE active = 1
GROUP BY database, table
ORDER BY sum(bytes) DESC
LIMIT 20;
```

### Column Compression

```sql
-- Column compression ratios
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
```

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
```

### Merge Performance

```sql
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
```

### Merge Queue

```sql
-- Tables needing optimization
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

## Mutation Monitoring

```sql
-- Active mutations
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

-- Mutation history
SELECT
    table,
    command,
    is_done,
    created_at,
    finished_at
FROM system.mutations
ORDER BY created_at DESC
LIMIT 50;
```

## Cluster Health

### Basic Health

```sql
-- Quick health check
SELECT
    'uptime' as metric,
    toString(uptime()) as value
UNION ALL
SELECT 'version', version()
UNION ALL
SELECT 'running_queries', toString(count())
FROM system.processes
UNION ALL
SELECT 'active_merges', toString(count())
FROM system.merges
UNION ALL
SELECT 'mutations_running', toString(count())
FROM system.mutations WHERE is_done = 0;
```

### Cluster Status

```sql
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
```

### Replica Status

```sql
-- All replicas
SELECT
    database,
    table,
    is_leader,
    is_readonly,
    queue_size,
    absolute_delay
FROM system.replicas
ORDER BY absolute_delay DESC;
```

### Replication Lag

```sql
-- Lagging replicas
SELECT
    database,
    table,
    replica_name,
    is_leader,
    is_readonly,
    queue_size,
    delay * 1000 as lag_ms
FROM system.replication_queue
WHERE delay > 5
ORDER BY delay DESC;
```

## Disk and Memory Health

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
```

### Memory Usage

```sql
-- Memory by dictionaries
SELECT
    formatReadableSize(sum(bytes_allocated)) as allocated,
    formatReadableSize(sum(bytes_used)) as used
FROM system.dictionaries;

-- Current memory metrics
SELECT
    formatReadableSize(os_userspace_memory) as userspace,
    formatReadableSize(os_committed_memory) as committed
FROM system.asynchronous_metrics
WHERE metric LIKE '%memory%';
```

## Performance Metrics

### Query Statistics

```sql
-- Query statistics by type
SELECT
    type,
    count() as count,
    avg(query_duration_ms) as avg_duration_ms
FROM system.query_log
WHERE event_date = today()
GROUP BY type
ORDER BY count DESC;
```

### Top Consumers

```sql
-- Most memory-intensive queries
SELECT
    query,
    formatReadableSize(memory_usage) as memory,
    query_duration_ms / 1000 as seconds
FROM system.query_log
WHERE type = 'QueryFinish'
  AND event_date = today()
ORDER BY memory_usage DESC
LIMIT 10;

-- Most row-intensive queries
SELECT
    query,
    formatReadableQuantity(read_rows) as rows_read,
    query_duration_ms / 1000 as seconds
FROM system.query_log
WHERE type = 'QueryFinish'
  AND event_date = today()
ORDER BY read_rows DESC
LIMIT 10;
```

## Alerting Queries

### Critical Alerts

```sql
-- Replicas lagging > 30s
SELECT
    'CRITICAL: Replication lag' as alert,
    database,
    table,
    delay as lag_seconds
FROM system.replication_queue
WHERE delay > 30;

-- Too many parts
SELECT
    'WARNING: Too many parts' as alert,
    database,
    table,
    count() as parts
FROM system.parts
WHERE active = 1
GROUP BY database, table
HAVING parts > 5000;

-- Long-running queries
SELECT
    'WARNING: Long-running query' as alert,
    query_id,
    elapsed / 60 as minutes,
    substring(query, 1, 100) as query_preview
FROM system.processes
WHERE elapsed > 1800;  -- 30 minutes
```

## Asynchronous Metrics

```sql
-- System metrics
SELECT
    metric,
    formatReadableSize(value) as value
FROM system.asynchronous_metrics
WHERE metric LIKE '%bytes%'
ORDER BY metric;

-- Load average
SELECT
    metric,
    value
FROM system.asynchronous_metrics
WHERE metric LIKE '%load%';
```

## Prometheus Integration

### Export Metrics

```sql
-- ClickHouse exposes metrics on port 9363
# Enable in config.xml
<prometheus>
    <endpoint>/metrics</endpoint>
    <port>9363</port>
</prometheus>

# Scrape config
scrape_configs:
  - job_name: 'clickhouse'
    static_configs:
      - targets: ['localhost:9363']
```

### Key Metrics

```
# Query metrics
clickhouse_queries_total
clickhouse_query_duration_seconds
clickhouse_query_memory_usage_bytes

# Merge metrics
clickhouse_merges_total
clickhouse_merge_duration_seconds

# Replication metrics
clickhouse_replication_queue_size
clickhouse_replication_lag_seconds

# Table metrics
clickhouse_table_rows{table="events"}
clickhouse_table_size_bytes{table="events"}
```

## Grafana Dashboard

### Recommended Panels

1. **Query Performance**
   - Queries per second
   - Average query duration
   - Memory usage

2. **Merge Health**
   - Active merges
   - Merge queue size
   - Parts count

3. **Replication**
   - Replication lag
   - Queue size
   - Replica status

4. **Table Sizes**
   - Top 10 tables by size
   - Growth rate

5. **System Resources**
   - CPU usage
   - Memory usage
   - Disk usage

## See Also

- `../SKILL.md` - Main skill entry point
- `debugging.md` - Troubleshooting issues
- `system-queries.md` - Ready-to-use monitoring queries
