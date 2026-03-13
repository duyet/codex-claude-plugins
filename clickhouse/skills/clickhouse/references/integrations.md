# ClickHouse Integrations

Kafka, S3, PostgreSQL, MySQL, RabbitMQ, and BI tools.

> ⚠️ **Credential Security**: All credentials in examples below (`password123`, `AKIAIOSFODNN7EXAMPLE`, etc.) are **placeholders only**. Never use these in production. Use proper secret management:
> - Environment variables
> - Secret managers (AWS Secrets Manager, HashiCorp Vault, etc.)
> - Kubernetes secrets (for K8s deployments)
> - ClickHouse named collections with external configuration

## Kafka Integration

### Kafka Table Engine

```sql
CREATE TABLE kafka_queue (
    timestamp UInt64,
    level String,
    message String
)
ENGINE = Kafka()
SETTINGS
    kafka_broker_list = 'broker1:9092,broker2:9092',
    kafka_topic_list = 'logs',
    kafka_group_name = 'clickhouse_consumer',
    kafka_format = 'JSONEachRow',
    kafka_num_consumers = 2,
    kafka_max_block_size = 65536,
    kafka_skip_broken_messages = 100;
```

### Virtual Columns

Kafka tables provide virtual columns:

```sql
-- Virtual columns available
SELECT
    _topic,      -- Kafka topic
    _key,        -- Message key
    _offset,     -- Message offset
    _partition,  -- Partition number
    _timestamp   -- Message timestamp
FROM kafka_queue;
```

### Materialized View for Streaming

```sql
-- Create target table
CREATE TABLE logs (
    timestamp DateTime,
    level String,
    message String
)
ENGINE = MergeTree()
ORDER BY (timestamp, level);

-- Create materialized view to consume continuously
CREATE MATERIALIZED VIEW consumer TO logs
AS SELECT
    toDateTime(timestamp) as timestamp,
    level,
    message
FROM kafka_queue;

-- Data automatically flows from Kafka → MV → target table
```

### Kafka Settings

| Setting | Description | Default |
|---------|-------------|---------|
| `kafka_broker_list` | Comma-separated brokers | Required |
| `kafka_topic_list` | Comma-separated topics | Required |
| `kafka_group_name` | Consumer group | Required |
| `kafka_format` | Input format | Required |
| `kafka_num_consumers` | Number of consumers | 1 |
| `kafka_max_block_size` | Block size for poll | 65536 |
| `kafka_skip_broken_messages` | Skip N broken messages | 0 |

### Consumer Lag Monitoring

```sql
SELECT
    topic,
    partition,
    max_offset,
    lag
FROM system.kafka_consumers;
```

## S3 Integration

### S3 Table Engine

```sql
CREATE TABLE s3_table (
    id UInt32,
    data String,
    timestamp DateTime
)
ENGINE = S3(
    'https://my-bucket.s3.amazonaws.com/data/*.parquet',
    'AWS_ACCESS_KEY',
    'AWS_SECRET_KEY',
    'Parquet'
);
```

### S3 Table Function

```sql
-- Query S3 directly
SELECT * FROM s3(
    'https://bucket.s3.amazonaws.com/data/*.csv',
    'access_key',
    'secret_key',
    'CSV'
);

-- With wildcards
SELECT * FROM s3(
    'https://bucket.s3.amazonaws.com/data/file-{000..999}.csv',
    'CSV'
);

-- With compression
SELECT * FROM s3(
    'https://bucket.s3.amazonaws.com/data/*.csv.gz',
    'CSV',
    'access_key',
    'secret_key'
);
```

### S3 Disk (Tiered Storage)

```sql
-- Configuration in config.xml
<storage_configuration>
    <disks>
        <hot_ssd>
            <path>/mnt/ssd/clickhouse/</path>
        </hot_ssd>
        <s3_cold>
            <type>s3</type>
            <endpoint>https://bucket.s3.amazonaws.com/clickhouse/</endpoint>
            <!-- ⚠️ Use AWS IAM roles or environment variables in production -->
            <access_key_id>AKIAIOSFODNN7EXAMPLE</access_key_id>
            <secret_access_key>wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY</secret_access_key>
        </s3_cold>
    </disks>

    <policies>
        <hot_cold>
            <volumes>
                <hot>
                    <disk>hot_ssd</disk>
                </hot>
                <cold>
                    <disk>s3_cold</disk>
                </cold>
            </volumes>
        </hot_cold>
    </policies>
</storage_configuration>

-- Usage with TTL
CREATE TABLE events (
    timestamp DateTime,
    data String
)
ENGINE = MergeTree()
ORDER BY timestamp
SETTINGS storage_policy = 'hot_cold'
TTL timestamp + INTERVAL 7 DAY TO DISK 's3_cold';
```

**Production S3 Configuration:** Use IAM roles or externalized secrets:
```xml
<s3_cold>
    <type>s3</type>
    <endpoint>https://bucket.s3.amazonaws.com/clickhouse/</endpoint>
    <!-- Use environment variable: ${S3_ACCESS_KEY} -->
    <access_key_id>${S3_ACCESS_KEY}</access_key_id>
    <secret_access_key>${S3_SECRET_KEY}</secret_access_key>
</s3_cold>
```

### S3 Caching

```sql
-- Enable filesystem cache
SELECT * FROM s3(...)
SETTINGS
    filesystem_cache_name = 's3_cache',
    enable_filesystem_cache = 1;
```

## PostgreSQL Integration

### PostgreSQL Table Engine

```sql
CREATE TABLE pg_table (
    id Int32,
    name String,
    created_at DateTime
)
ENGINE = PostgreSQL(
    'localhost:5432',
    'mydb',
    'users',
    'postgres',
    'password'
);
```

### PostgreSQL Table Function

```sql
-- Query PostgreSQL directly
SELECT * FROM postgresql(
    'localhost:5432',
    'mydb',
    'users',
    'postgres',
    'password'
)
WHERE active = true;
```

### PostgreSQL Dictionary

```sql
CREATE DICTIONARY pg_users (
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
    user 'postgres'
    password 'password'
))
LIFETIME(60)
LAYOUT(HASHED());
```

### Named Collections

```xml
<named_collections>
    <pg_connection>
        <host>localhost</host>
        <port>5432</port>
        <user>postgres</user>
        <password>secret</password>
    </pg_connection>
</named_collections>
```

```sql
-- Use named collection
SELECT * FROM postgresql(
    'pg_connection',
    'mydb',
    'users'
);
```

## MySQL Integration

### MySQL Table Engine

```sql
CREATE TABLE mysql_table (
    id Int32,
    name String
)
ENGINE = MySQL(
    'localhost:3306',
    'mydb',
    'users',
    'mysql_user',
    'mysql_pass'
);
```

### MySQL Table Function

```sql
SELECT * FROM mysql(
    'localhost:3306',
    'mydb',
    'users',
    'mysql_user',
    'mysql_pass'
);
```

### MySQL Dictionary

```sql
CREATE DICTIONARY mysql_users (
    user_id UInt32,
    email String
)
PRIMARY KEY user_id
SOURCE(MYSQL(
    port 3306
    host 'localhost'
    db 'mydb'
    table 'users'
    user 'mysql_user'
    password 'mysql_pass'
))
LIFETIME(60)
LAYOUT(HASHED());
```

## RabbitMQ Integration

```sql
CREATE TABLE rabbitmq_queue (
    timestamp DateTime,
    data String
)
ENGINE = RabbitMQ()
SETTINGS
    amqp_exchange = 'events',
    amqp_exchange_type = 'fanout',
    amqp_routing_key_list = 'events',
    amqp_queue_base = 'clickhouse_consumer',
    amqp_format = 'JSONEachRow',
    amqp_host = 'localhost',
    amqp_port = 5672,
    amqp_user = 'guest',
    amqp_password = 'guest';
```

## MongoDB Integration

```sql
SELECT * FROM mongodb(
    'localhost:27017',
    'mydb',
    'mycollection',
    'user',
    'password'
);
```

## Redis Integration

### Redis Dictionary

```sql
CREATE DICTIONARY redis_dict (
    key String,
    value String
)
PRIMARY KEY key
SOURCE(REDIS(
    host 'localhost'
    port 6379
    db 0
    password 'password'
))
LIFETIME(60)
LAYOUT(HASHED());
```

### Redis Table Function

```sql
SELECT * FROM redis(
    'localhost',
    6379,
    'mykey'
);
```

## BI Tools Integration

### Tableau

```bash
# Install ODBC driver
# Download from: https://github.com/ClickHouse/clickhouse-odbc

# Configure DSN in /etc/odbcinst.ini
[ClickHouse]
Description = ClickHouse ODBC Driver
Driver = /usr/lib/libclickhouseodbc.so
Setup = /usr/lib/libclickhouseodbc_s.so
```

### Grafana

```bash
# Install ClickHouse data source plugin
grafana-cli plugins install clickhouse-datasource

# Configure in Grafana UI:
# - Host: http://clickhouse-server:8123
# - Database: default
# - User: default
# - Password: (empty)
```

### Metabase

```sql
-- Native ClickHouse support
-- Add connection in Metabase UI:
-- - Database type: ClickHouse
# - Host: clickhouse-server
# - Port: 8123
# - Database: mydb
# - Username: default
```

### Superset

```python
# Install ClickHouse SQLAlchemy dialect
pip install clickhouse-sqlalchemy

# Configure in Superset:
# Connection string:
# clickhouse+native://default:@clickhouse-server:9000/mydb
```

### Looker

```yaml
# Looker connection configuration
connection:
  dialect: clickhouse
  host: clickhouse-server
  port: 8123
  database: analytics
  username: default
  password: ""
  ssl: false
```

## Data Import Tools

### clickhouse-import

```bash
# Import from CSV
clickhouse-import --query="INSERT INTO table FORMAT CSV" < data.csv

# Import from JSON
clickhouse-import --query="INSERT INTO table FORMAT JSONEachRow" < data.json
```

### clickhouse-copier

```bash
# Copy data between clusters
clickhouse-copier \
  --config=config.xml \
  --base-dir=/tmp/ \
  --src-cluster=production \
  --dst-cluster=staging \
  --tables=events
```

## See Also

- `../SKILL.md` - Main skill entry point
- `cluster-management.md` - Distributed queries and sharding
- `monitoring.md` - Data pipeline monitoring
