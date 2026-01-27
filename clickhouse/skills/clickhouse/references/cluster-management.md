# ClickHouse Cluster Management

Distributed tables, replication, sharding, and cluster operations.

## Cluster Configuration

### Define Cluster

```xml
<!-- /etc/clickhouse-server/config.d/remote-servers.xml -->
<clickhouse>
    <remote_servers>
        <my_cluster>
            <shard>
                <replica>
                    <host>node1.example.com</host>
                    <port>9000</port>
                </replica>
            </shard>
            <shard>
                <replica>
                    <host>node2.example.com</host>
                    <port>9000</port>
                </replica>
            </shard>
        </my_cluster>
    </remote_servers>
</clickhouse>
```

### Cluster Macros

```xml
<!-- /etc/clickhouse-server/config.d/macros.xml -->
<clickhouse>
    <macros>
        <shard>01</shard>
        <replica>replica_1</replica>
    </macros>
</clickhouse>
```

## Distributed Tables

### Create Distributed Table

```sql
-- Create local table on each shard
CREATE TABLE local_events ON CLUSTER my_cluster (
    timestamp DateTime,
    user_id UInt32,
    event String
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (user_id, timestamp);

-- Create distributed table (sharding)
CREATE TABLE distributed_events ON CLUSTER my_cluster AS local_events
ENGINE = Distributed(
    'my_cluster',     -- Cluster name
    currentDatabase(), -- Database
    'local_events',   -- Local table name
    rand()            -- Sharding key
);

-- Query distributed table
SELECT * FROM distributed_events;
```

### Sharding Strategies

```sql
-- Random sharding
ENGINE = Distributed(cluster, db, table, rand())

-- By user ID (consistent)
ENGINE = Distributed(cluster, db, table, intHash32(user_id))

-- By date
ENGINE = Distributed(cluster, db, table, toYYYYMM(date))

-- Composite sharding
ENGINE = Distributed(cluster, db, table, (tenant_id, user_id))

-- No sharding (all data on all shards)
ENGINE = Distributed(cluster, db, table, const)
```

### Distributed DDL

```sql
-- Create table on all shards
CREATE TABLE table_name ON CLUSTER my_cluster (
    id UInt32,
    value String
)
ENGINE = MergeTree()
ORDER BY id;

-- Drop table on all shards
DROP TABLE table_name ON CLUSTER my_cluster;

-- Alter table on all shards
ALTER TABLE table_name ON CLUSTER my_cluster ADD COLUMN new_col String;
```

## Replication

### ReplicatedMergeTree Setup

```sql
-- On replica 1
CREATE TABLE events ON CLUSTER my_cluster (
    timestamp DateTime,
    user_id UInt32
)
ENGINE = ReplicatedMergeTree(
    '/clickhouse/tables/{shard}/events',  -- ZooKeeper path
    '{replica}'                           -- Replica name
)
PARTITION BY toYYYYMM(timestamp)
ORDER BY (user_id, timestamp);

-- On replica 2 (same DDL, macros handle replica name)
-- {replica} macro resolves to 'replica_2'
```

### Add Replica to Existing Table

```sql
-- Stop replication sends
SYSTEM STOP REPLICATED SENDS database.table;

-- Copy data to new replica
-- (rsync or clickhouse-backup)

-- Start replication
SYSTEM START REPLICATED SENDS database.table;
```

### Replica Management

```sql
-- Check replica status
SELECT
    database,
    table,
    is_leader,
    is_readonly,
    queue_size,
    absolute_delay
FROM system.replicas;

-- Check replication queue
SELECT * FROM system.replication_queue
WHERE delay > 5
ORDER BY delay DESC;
```

## Cluster Operations

### Cluster Information

```sql
-- Show all clusters
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

### Query Across Cluster

```sql
-- Query all shards
SELECT * FROM clusterAllReplicas(
    'my_cluster',
    system.functions
) LIMIT 1;

-- Execute on all nodes
SELECT * FROM remote(
    'node1, node2, node3',
    system.dictionaries
);

-- Query specific shard
SELECT * FROM cluster(
    'my_cluster',
    1,  -- shard
    0,  -- replica
    system.query_log
) LIMIT 1;
```

### Distributed INSERT

```sql
-- Insert into distributed table (shards data)
INSERT INTO distributed_events VALUES (now(), 123, 'login');

-- Insert into distributed table with specific shard
INSERT INTO distributed_events SHARD 1 VALUES (now(), 456, 'logout');
```

## Cross-Replication

### Multi-Datacenter Setup

```sql
-- Multiple datacenters
CREATE TABLE events (
    ...
)
ENGINE = ReplicatedMergeTree(
    '/clickhouse/tables/{shard}/events',
    '{replica}'
)
-- On DC1: shards 1-2, replicas a-b
-- On DC2: shards 1-2, replicas c-d
```

**Configuration:**
```xml
<remote_servers>
    <dc_cluster>
        <shard>
            <internal_replication>true</internal_replication>
            <replica>
                <host>dc1-node1</host>
            </replica>
            <replica>
                <host>dc2-node1</host>
            </replica>
        </shard>
    </dc_cluster>
</remote_servers>
```

## Load Balancing

### Load Balancing Settings

```sql
-- Load balancing modes
SET load_balancing = 'random';           -- Random replica
SET load_balancing = 'nearest_hostname';  -- Hostname-based
SET load_balancing = 'in_order';          -- Sequential

-- Failover settings
set failover = 1;                    -- Enable failover
set failover_by_hostname = 1;       -- Hostname-based failover

-- Defaults for distributed table
SETTINGS
    load_balancing = 'random',
    weights_by_node = 'dc1=1,dc2=1';  -- Weight distribution
```

## Cluster Monitoring

### Cluster Health

```sql
-- Comprehensive cluster health
SELECT
    host_address() as host,
    'uptime' as metric,
    toString(uptime()) as value
UNION ALL
SELECT host_address(), 'version', version()
UNION ALL
SELECT host_address(), 'replicas_lagging', toString(count())
FROM system.replication_queue WHERE delay > 5
UNION ALL
SELECT host_address(), 'mutations_running', toString(count())
FROM system.mutations WHERE is_done = 0;

-- All cluster nodes status
SELECT * FROM cluster('my_cluster', all, 1, system.replicas);
```

### Replication Lag Monitoring

```sql
-- Replication lag across cluster
SELECT
    host_address() as host,
    database,
    table,
    max(delay) as max_lag
FROM system.replication_queue
WHERE delay > 0
GROUP BY host, database, table;
```

## Cluster Maintenance

### Add Shard

```sql
-- 1. Install ClickHouse on new node
-- 2. Add to remote_servers config
-- 3. Create local tables on new shard
-- 4. Restart cluster
-- 5. Redistribute data (manual or using clickhouse-copier)
```

### Remove Shard

```sql
-- 1. Drop data from shard
-- 2. Remove from remote_servers config
-- 3. Restart cluster
-- 4. Update distributed tables
```

### Data Migration

```sql
-- Using clickhouse-copier for data migration
-- Config file:
<source>
    <host>old-cluster</host>
    <port>9000</port>
</source>
<destination>
    <host>new-cluster</host>
    <port>9000</port>
</destination>

<tables>
    <table>
        <source_database>db</source_database>
        <source_table>table</source_table>
        <destination_database>db</destination_database>
        <destination_table>table</destination_table>
    </table>
</tables>
```

## Best Practices

1. **Always use ReplicatedMergeTree** for production
2. **Configure proper sharding keys** for even distribution
3. **Monitor replication lag** (alert if > 5s)
4. **Use `GLOBAL JOIN`** for distributed queries with dimension tables
5. **Set up ZooKeeper monitoring** (ZK outage = read-only)
6. **Test failover** regularly
7. **Document cluster topology** (shard/replica mapping)

## See Also

- `../SKILL.md` - Main skill entry point
- `core-concepts.md` - Architecture and data model
- `debugging.md` - Replication troubleshooting
- `monitoring.md` - Cluster health checks
