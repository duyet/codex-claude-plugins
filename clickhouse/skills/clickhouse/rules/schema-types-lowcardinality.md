---
title: Use LowCardinality for Repeated Strings
impact: HIGH
impactDescription: "Dictionary encoding for <10K unique values; significant storage reduction"
tags: [schema, data-types, LowCardinality, String, storage]
---

## Use LowCardinality for Repeated Strings

**Impact: HIGH**

Repeated string values consume substantial storage with plain String type. LowCardinality applies dictionary encoding for dramatic storage reduction on columns with fewer than 10,000 unique values.

**Incorrect (plain String for low-cardinality data):**

```sql
CREATE TABLE events (
    country String,           -- ~200 unique countries, repeated millions of times
    browser String,           -- ~50 unique browsers
    event_type String         -- ~30 event types
)
```

**Correct (LowCardinality wrapper):**

```sql
CREATE TABLE events (
    country LowCardinality(String),      -- Dictionary-encoded
    browser LowCardinality(String),      -- Dictionary-encoded
    event_type LowCardinality(String)    -- Dictionary-encoded
)
```

**When to use:**

| Cardinality | Recommendation |
|-------------|----------------|
| < 10,000 distinct values | `LowCardinality(String)` |
| > 10,000 distinct values | `String` |
| Fixed-length (e.g., 2-char country codes) | `FixedString(2)` |

**Check column cardinality:**

```sql
SELECT uniq(column_name) FROM table_name;
```

**LowCardinality vs FixedString:**
- Reserve `FixedString` exclusively for data with unchanging length (like 2-character country codes)
- For most low-cardinality text, `LowCardinality(String)` outperforms `FixedString`

Reference: [Select Data Types](https://clickhouse.com/docs/best-practices/select-data-types)
