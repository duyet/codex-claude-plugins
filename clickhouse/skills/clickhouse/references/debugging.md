# ClickHouse Debugging

Query debugging, merge issues, mutations, replication problems, and troubleshooting.

## Query Debugging

### Enable Query Log

```sql
-- Check if enabled
SELECT * FROM system.settings
WHERE name = 'log_queries';

-- Enable query logging
SYSTEM STOP DISTRIBUTED SENDS query_log;
ALTER TABLE system.query_log MODIFY TTL query_start_time + INTERVAL 30 DAY;
SYSTEM START DISTRIBUTED SENDS query_log;
```

### Analyze Slow Queries

```sql
-- Find slow queries
SELECT
    query,
    query_duration_ms / 1000 as seconds,
    memory_usage,
    read_rows,
    read_bytes
FROM system.query_log
WHERE type = 'QueryFinish'
  AND query_duration_ms > 1000
ORDER BY query_duration_ms DESC
LIMIT 10;

-- Find expensive queries by memory
SELECT
    query,
    formatReadableSize(memory_usage) as memory,
    query_duration_ms
FROM system.query_log
WHERE type = 'QueryFinish'
ORDER BY memory_usage DESC
LIMIT 10;
```

### Check Query Plan

```sql
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

### Debug Hanging Queries

```sql
-- Show running queries
SELECT
    query_id,
    user,
    query,
    elapsed,
    memory_usage,
    read_rows
FROM system.processes
WHERE elapsed > 10
ORDER BY elapsed DESC;

-- Kill query
KILL QUERY WHERE query_id = 'query-id';

-- Cancel mutation
KILL MUTATION WHERE mutation_id = 'mutation-id';
```

## Merge Debugging

### Active Merges

```sql
-- Active merges
SELECT
    database,
    table,
    elapsed,
    progress,
    bytes_read_uncompressed,
    rows_read,
    is_mutation
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
```

### Merge Queue Size

```sql
-- Tables with too many parts (need optimization)
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

### Common Merge Issues

| Issue | Symptom | Solution |
|-------|---------|----------|
| Too many parts | Slow queries, high memory | `OPTIMIZE TABLE table FINAL` |
| Slow merges | High CPU, disk usage | Reduce insert frequency, increase `max_bytes_to_merge_at_max_space_usage` |
| Merge bottleneck | Queries slow | Check `background_pool` settings |
| Parts not merging | Parts count increasing | Check `max_bytes_to_merge_at_once` |

## Mutation Debugging

### Show Mutations

```sql
-- All mutations
SELECT * FROM system.mutations;

-- Active mutations
SELECT
    database,
    table,
    command,
    is_done,
    parts_to_do,
    parts_to_do_names
FROM system.mutations
WHERE is_done = 0;
```

### Mutation Progress

```sql
-- Mutation progress details
SELECT
    table,
    command,
    is_done,
    parts_to_do - parts_to_do_names as parts_remaining,
    elapsed,
    formatReadableSize(bytes_read_uncompressed) as bytes_processed
FROM system.mutations
WHERE is_done = 0
ORDER BY parts_to_do DESC;
```

### Common Mutation Issues

| Issue | Symptom | Solution |
|-------|---------|----------|
| Mutation stuck | `is_done = 0` for long time | Check `system.merges`, use `OPTIMIZE FINAL` |
| Slow mutation | Low `parts_to_do_names` progress | Reduce concurrent mutations, increase `background_pool` |
| Mutation failed | `is_fail = 1` | Check `exception_text`, fix issue, retry |

## Replication Debugging

### Replication Status

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

-- Replication queue
SELECT * FROM system.replication_queue
WHERE delay > 5
ORDER BY delay DESC;
```

### ZooKeeper Health

```sql
-- ZooKeeper connection
SELECT * FROM system.zookeeper WHERE path = '/';

-- Check ZK queue
SELECT count() FROM system.zookeeper
WHERE path = '/clickhouse/queues';

-- ZK exceptions
SELECT * FROM system.zookeeper_log
WHERE type = 'ERROR'
ORDER BY event_time DESC
LIMIT 10;
```

### Common Replication Issues

| Issue | Symptom | Solution |
|-------|---------|----------|
| Replication lag | `absolute_delay > 5` | Check network, ZooKeeper, disk I/O |
| ZK connection lost | `is_readonly = 1` | Check ZooKeeper, increase `session_timeout` |
| Queue growing | `queue_size` increasing | Check merge performance, reduce insert rate |
| ZK expired | Cluster down | Check ZK connection, restart ClickHouse |

## Data Issues

### Check Parts Count

```sql
-- Parts per partition
SELECT
    partition,
    count() as parts,
    sum(rows) as total_rows
FROM system.parts
WHERE active = 1
  AND table = 'my_table'
GROUP BY partition
HAVING parts > 1000
ORDER BY parts DESC;
```

### Check for Duplicates

```sql
-- Check for duplicates in ReplacingMergeTree
SELECT
    user_id,
    count() as cnt
FROM ReplacingMergeTree_table
GROUP BY user_id
HAVING cnt > 1;
```

### Data Distribution

```sql
-- Data skew
SELECT
    user_id,
    count() as cnt
FROM events
GROUP BY user_id
ORDER BY cnt DESC
LIMIT 10;
```

## Common Issues & Solutions

### Issue: Too Many Parts

**Symptoms:**
- Slow queries
- High memory usage
- Large merge queue

**Solutions:**
```sql
-- Force merge
OPTIMIZE TABLE table FINAL;

-- Check partitioning
SELECT partition, count() as parts
FROM system.parts
WHERE active = 1 AND table = 'my_table'
GROUP BY partition;

-- Consider larger partitions
-- Monthly instead of daily
```

### Issue: Mutation Stuck

**Symptoms:**
- `ALTER UPDATE/DELETE` not completing
- `is_done = 0` in `system.mutations`

**Solutions:**
```sql
-- Check mutation progress
SELECT * FROM system.mutations WHERE is_done = 0;

-- Cancel and retry
KILL MUTATION WHERE mutation_id = '...';

-- Force with OPTIMIZE
OPTIMIZE TABLE table FINAL;
```

### Issue: OOM on Queries

**Symptoms:**
- Query killed with memory limit
- `"Memory limit exceeded"` error

**Solutions:**
```sql
-- Increase memory limit
SET max_memory_usage = 10000000000;

-- Optimize query
-- - Select fewer columns
-- - Add filters
-- - Use SAMPLE

-- Check query memory usage
SELECT
    query,
    formatReadableSize(memory_usage) as memory
FROM system.query_log
WHERE type = 'QueryFinish'
ORDER BY memory_usage DESC
LIMIT 10;
```

### Issue: Replication Lag

**Symptoms:**
- Data not replicating
- High `absolute_delay` in `system.replicas`

**Solutions:**
```sql
-- Check replication queue
SELECT * FROM system.replication_queue;

-- Check ZooKeeper
SELECT * FROM system.zookeeper WHERE path = '/clickhouse/tables';

-- Check network/disk
-- Verify connectivity between replicas
-- Check disk I/O performance
```

## Debugging Workflow

1. **Identify the problem**
   - Query slow? Check `system.processes`
   - Data missing? Check replication status
   - High memory? Check `system.query_log`

2. **Gather information**
   - Use `EXPLAIN` for query plans
   - Check `system.merges` for merge issues
   - Check `system.mutations` for mutation progress

3. **Apply fixes**
   - `OPTIMIZE TABLE` for merge issues
   - Adjust settings for performance
   - Fix network/ZooKeeper for replication

4. **Verify**
   - Re-run query
   - Check metrics again
   - Monitor for recurrence

## See Also

- `../SKILL.md` - Main skill entry point
- `monitoring.md` - Health checks and monitoring queries
- `cluster-management.md` - Replication setup and configuration
