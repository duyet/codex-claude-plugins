# ClickHouse SQL Reference

Complete SQL dialect reference for ClickHouse.

## Data Types

### Numeric Types

```sql
-- Unsigned integers
UInt8   -- 0 to 255
UInt16  -- 0 to 65,535
UInt32  -- 0 to 4,294,967,295
UInt64  -- 0 to 18,446,744,073,709,551,615
UInt128 -- Very large unsigned
UInt256 -- Extremely large unsigned

-- Signed integers
Int8    -- -128 to 127
Int16   -- -32,768 to 32,767
Int32   -- -2,147,483,648 to 2,147,483,647
Int64   -- -9,223,372,036,854,775,808 to 9,223,372,036,854,775,807

-- Floating point
Float32 -- Single precision (7 decimal digits)
Float64 -- Double precision (16 decimal digits)

-- Decimal (precise decimal arithmetic)
Decimal32(S)  -- 1-9 significant digits
Decimal64(S)  -- 10-18 significant digits
Decimal128(S) -- 19-38 significant digits
Decimal256(S) -- 39-76 significant digits
Decimal(P, S) -- P total digits, S after decimal point

-- Examples
CREATE TABLE examples (
    price Decimal(18, 2),       -- Currency (up to 999 trillion)
    percentage Decimal(5, 2),   -- Percentages (0.00 to 999.99)
    metric Float64              -- Approximate metrics
)
```

### Temporal Types

```sql
-- Date (2 bytes, days since Unix epoch)
Date              -- Range: 1970-01-01 to 2149-06-06

-- DateTime (4 bytes, seconds since Unix epoch)
DateTime          -- Range: 1970-01-01 00:00:00 to 2106-02-07 06:28:15
DateTime('UTC')   -- With timezone

-- DateTime64 (8 bytes, sub-second precision)
DateTime64(3)                -- Millisecond precision
DateTime64(6, 'UTC')         -- Microsecond precision with timezone
DateTime64(9, 'America/New_York') -- Nanosecond precision

-- Functions
toDate('2024-01-01')                    -- String → Date
toDateTime('2024-01-01 12:00:00')       -- String → DateTime
toDateTime64('2024-01-01 12:00:00.123', 3) -- String → DateTime64

now()                                   -- Current DateTime
today()                                 -- Current Date
yesterday()                             -- Yesterday's Date
tomorrow()                              -- Tomorrow's Date

-- Date arithmetic
now() + INTERVAL 1 DAY
now() - INTERVAL 1 HOUR
date_diff('day', timestamp, now())      -- Days between dates
```

### String Types

```sql
-- Variable-length string
String          -- No length limit, stores any string

-- Fixed-length string
FixedString(N)  -- Fixed N bytes, pads with zeros
-- Example: UUID as FixedString(16)

-- Common operations
length(string)           -- String length
concat(s1, s2, ...)      -- Concatenate
substring(s, offset, length)  -- Substring
splitByChar(separator, s)    -- Split into array
arrayJoin(splitByChar(' ', s))  -- Split and explode
```

### Advanced Types

```sql
-- Arrays
Array(UInt32)                    -- Array of unsigned integers
Array(String)                    -- Array of strings
['a', 'b', 'c']                  -- Array literal
arrayJoin([1, 2, 3])             -- Explode array into rows

-- Tuples
Tuple(UInt32, String, Float64)   -- Mixed-type tuple
tuple(123, 'abc', 45.6)          -- Tuple literal
t.1, t.2                         -- Access tuple fields

-- Maps (key-value pairs)
Map(String, UInt64)              -- String → UInt64 map
map('key1', 1, 'key2', 2)        -- Map literal

-- Enums (efficient string storage)
Enum8('action1'=1, 'action2'=2)     -- 1 byte per value
Enum16('status1'=1, 'status2'=2)    -- 2 bytes per value

-- Nullable (allows NULL values)
Nullable(UInt32)           -- Can be NULL or UInt32
-- Nullable has overhead (special NULL marker)

-- LowCardinality (compression for low-cardinality strings)
LowCardinality(String)     -- Efficient for < 10k distinct values

-- UUID
UUID                       -- 16-byte UUID
generateUUIDv4()           -- Generate random UUID

-- IPv4/IPv6
IPv4                       -- 4-byte IPv4 address
IPv6                       -- 16-byte IPv6 address
toIPv4('192.168.1.1')      -- String → IPv4
```

## CREATE TABLE

```sql
-- Basic syntax
CREATE TABLE [IF NOT EXISTS] [db.]table_name
(
    column1 Type [DEFAULT|ALIAS expr] [COMMENT 'description'],
    column2 Type [DEFAULT|ALIAS expr] [COMMENT 'description'],
    ...
)
ENGINE = MergeTree()
PARTITION BY expr
ORDER BY expr
PRIMARY KEY expr
SAMPLE BY expr
TTL expr
SETTINGS name=value, ...;

-- Example with all features
CREATE TABLE events (
    timestamp DateTime,
    user_id UInt32,
    event_type LowCardinality(String) DEFAULT 'unknown',
    session_id UUID DEFAULT generateUUIDv4(),
    metadata String DEFAULT '',
    revenue Decimal(18, 2) DEFAULT 0.00 COMMENT 'Revenue in USD'
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (user_id, timestamp)
PRIMARY KEY (user_id)
SAMPLE BY user_id
TTL timestamp + INTERVAL 90 DAY
SETTINGS index_granularity = 8192;
```

## INSERT

```sql
-- Insert values
INSERT INTO events VALUES
    (now(), 123, 'login', generateUUIDv4(), '{}', 0.00),
    (now(), 456, 'logout', generateUUIDv4(), '{}', 0.00);

-- Insert with columns
INSERT INTO events (timestamp, user_id, event_type) VALUES
    (now(), 789, 'purchase');

-- Insert from SELECT
INSERT INTO events_archive
SELECT * FROM events
WHERE timestamp < today() - INTERVAL 90 DAY;

-- Insert with format
INSERT INTO events FORMAT JSONEachRow
{"timestamp":"2024-01-01 00:00:00","user_id":123,"event_type":"login"}
{"timestamp":"2024-01-01 00:01:00","user_id":456,"event_type":"logout"}
```

## SELECT

```sql
-- Basic SELECT
SELECT [DISTINCT] [TOP n] expr
FROM table
[FINAL]  -- Apply mutations (deduplication)
[WHERE expr]
[GROUP BY expr] [WITH ROLLUP|WITH CUBE]
[HAVING expr]
[ORDER BY expr]
[LIMIT [offset, ]n]
[UNION ALL]
[SETTINGS name=value, ...];

-- Examples
SELECT * FROM events WHERE user_id = 123;
SELECT DISTINCT user_id FROM events;
SELECT TOP 10 user_id, count() as cnt FROM events GROUP BY user_id ORDER BY cnt DESC;

-- With FINAL (apply mutations)
SELECT * FROM ReplacingMergeTree_table FINAL WHERE user_id = 123;

-- WITH ROLLUP (hierarchical aggregation)
SELECT
    user_id,
    event_type,
    count() as cnt
FROM events
GROUP BY user_id, event_type WITH ROLLUP;
```

## JOIN

```sql
-- All JOINs are RIGHT JOINs internally
SELECT *
FROM t1
[GLOBAL] [ANY|ALL|ASOF] [INNER|LEFT|RIGHT|FULL|CROSS] JOIN t2
ON t1.key = t2.key

-- USING for same column names
SELECT *
FROM t1
[INNER|LEFT|RIGHT|FULL] JOIN t2 USING (common_key);

-- GLOBAL: Sends right table to each shard (for distributed queries)
SELECT *
FROM distributed_table lt
GLOBAL RIGHT JOIN small_table st ON lt.id = st.id;

-- ANY: First match only
SELECT * FROM t1 ANY LEFT JOIN t2 ON t1.id = t2.id;

-- ASOF: As-of join with inequality (time-series)
SELECT *
FROM ticks t1
ASOF LEFT JOIN trades t2
ON t1.symbol = t2.symbol
AND t1.time <= t2.time;
```

## ALTER TABLE

```sql
-- Add column (safe, metadata-only)
ALTER TABLE table ADD COLUMN col Type DEFAULT expr;

-- Drop column (mutation, expensive)
ALTER TABLE table DROP COLUMN col;

-- Modify column (mutation, expensive)
ALTER TABLE table MODIFY COLUMN col Type;

-- Rename column (metadata-only)
ALTER TABLE table RENAME COLUMN old_name TO new_name;

-- Comment column
ALTER TABLE table COMMENT COLUMN col 'description';

-- Delete data (mutation, expensive)
ALTER TABLE table DELETE WHERE expr;

-- Update data (mutation, expensive)
ALTER TABLE table UPDATE col = expr WHERE expr;

-- Add index
ALTER TABLE table ADD INDEX idx_name col TYPE bloom_filter GRANULARITY 1;

-- TTL
ALTER TABLE table MODIFY TTL timestamp + INTERVAL 90 DAY;
```

## DROP/TRUNCATE

```sql
-- Drop table
DROP TABLE [IF EXISTS] table;

-- Truncate table
TRUNCATE TABLE [IF EXISTS] table;

-- Drop partition (instant, no mutation)
ALTER TABLE table DROP PARTITION '202401';

-- Detach/Attach
DETACH TABLE table;  -- Keeps data on disk
ATTACH TABLE table;
```

## OPTIMIZE

```sql
-- Force merge of parts
OPTIMIZE TABLE table [PARTITION partition] [FINAL];

-- FINAL: Apply mutations, deduplicate
-- Without FINAL: Just merges parts
```

## SYSTEM Commands

```sql
-- Stop/start merges
SYSTEM STOP MERGES [ON CLUSTER cluster];
SYSTEM START MERGES [ON CLUSTER cluster];

-- Stop/start replication
SYSTEM STOP REPLICATION QUEUES;
SYSTEM START REPLICATION QUEUES;

-- Flush logs
SYSTEM FLUSH LOGS;
```

## Common Functions

### Date Functions

```sql
now()                          -- Current DateTime
today()                        -- Current Date
yesterday()                    -- Yesterday
tomorrow()                     -- Tomorrow
toDate(expr)                   -- Convert to Date
toDateTime(expr)               -- Convert to DateTime
toStartOfMonth(date)           -- First day of month
toStartOfWeek(date)            -- First day of week
toStartOfDay(date)             -- Start of day
date_diff(unit, start, end)    -- Difference between dates
```

### Array Functions

```sql
array(x1, x2, ...)             -- Create array
arrayJoin(arr)                 -- Explode array into rows
length(arr)                    -- Array length
has(arr, elem)                -- Check if element exists
arrayConcat(arr1, arr2)       -- Concatenate arrays
arrayMap(func, arr)           -- Apply function to each element
arrayFilter(func, arr)        -- Filter array
arraySort(func, arr)          -- Sort array
```

### String Functions

```sql
length(str)                    -- String length
substring(str, offset, length) -- Substring
concat(s1, s2, ...)            -- Concatenate
splitByChar(sep, str)          -- Split into array
join(arr, sep)                 -- Join array into string
lower(str)                     -- Lowercase
upper(str)                     -- Uppercase
trim(str)                      -- Trim whitespace
replaceOne(str, pattern, replacement)  -- Replace first
replaceAll(str, pattern, replacement)  -- Replace all
```

### Aggregation Functions

```sql
count()                        -- Count rows
sum(expr)                      -- Sum
avg(expr)                      -- Average
min(expr)                      -- Minimum
max(expr)                      -- Maximum
quantile(level)(expr)          -- Quantile
median(expr)                   -- Median
uniq(expr)                     -- Approximate unique count
uniqCombined(expr)             -- Better approximate unique
topK(K)(expr)                  -- Top K values
histogram(K)(expr)             -- Histogram
```

## See Also

- `../SKILL.md` - Main skill entry point
- `query-optimization.md` - Query performance and EXPLAIN
- `table-design.md` - Schema design and ORDER BY
