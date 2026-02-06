---
title: Use Native Types Instead of String
impact: CRITICAL
impactDescription: "2-10x storage reduction; enables compression and correct semantics"
tags: [schema, data-types, String, storage]
---

## Use Native Types Instead of String

**Impact: CRITICAL**

Using String for all data wastes storage, prevents compression optimization, and makes comparisons slower. ClickHouse performs significantly better with appropriate native data types.

**Storage comparison:**

| Data | Native Type | Native Size | String Size |
|------|-------------|-------------|-------------|
| UUID | UUID | 16 bytes | 36 bytes |
| Timestamp | DateTime | 4 bytes | 19 bytes |
| Boolean | Bool | 1 byte | 4 bytes |

**Incorrect (String for everything):**

```sql
CREATE TABLE events (
    id String,                -- UUID stored as String
    created_at String,        -- Timestamp stored as String
    is_active String,         -- Boolean stored as String
    count String              -- Number stored as String
)
```

**Correct (native types):**

```sql
CREATE TABLE events (
    id UUID,                  -- 16 bytes instead of 36
    created_at DateTime,      -- 4 bytes instead of 19
    is_active Bool,           -- 1 byte instead of 4
    count UInt32              -- 4 bytes instead of variable
)
```

**Type Selection Reference:**

| Data Category | Recommended Type | Avoid |
|---------------|------------------|-------|
| Sequential IDs | UInt32/UInt64 | String |
| Status/Category | Enum8 or LowCardinality(String) | String |
| Timestamps | DateTime | DateTime64 or String |
| Counts | Smallest UInt that fits | Int64 or String |
| Money | Decimal(P,S) or Int64 (cents) | Float64 or String |

Reference: [Select Data Types](https://clickhouse.com/docs/best-practices/select-data-types)
