---
title: Avoid Nullable Unless Semantically Required
impact: HIGH
impactDescription: "Nullable adds storage overhead; use DEFAULT values instead"
tags: [schema, data-types, Nullable, DEFAULT]
---

## Avoid Nullable Unless Semantically Required

**Impact: HIGH**

Nullable columns maintain a separate UInt8 column for tracking null values, increasing storage and degrading performance. Use DEFAULT values instead when feasible.

**Incorrect (Nullable everywhere):**

```sql
CREATE TABLE users (
    id Nullable(UInt64),
    name Nullable(String),
    age Nullable(UInt8),
    login_count Nullable(UInt32)
)
```

**Correct (DEFAULT values with selective Nullable):**

```sql
CREATE TABLE users (
    id UInt64,
    name String DEFAULT '',
    age UInt8 DEFAULT 0,
    login_count UInt32 DEFAULT 0,
    deleted_at Nullable(DateTime),    -- NULL = "not deleted"
    parent_id Nullable(UInt64)        -- NULL = "no parent"
)
```

**When Nullable IS appropriate:**

| Use Case | Rationale |
|----------|-----------|
| `deleted_at` | NULL indicates "not deleted"; timestamp shows deletion time |
| `parent_id` | NULL means "no parent"; value indicates parent exists |
| `discount_percent` | NULL = "no discount"; 0 = "0% discount" |

**Recommended defaults by type:**

| Type | Default |
|------|---------|
| String | `''` |
| UInt*/Int* | `0` |
| DateTime | `now()` or `toDateTime(0)` |
| UUID | `generateUUIDv4()` |

Reference: [Select Data Types](https://clickhouse.com/docs/best-practices/select-data-types)
