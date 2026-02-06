---
title: Plan ORDER BY Before Table Creation
impact: CRITICAL
impactDescription: "ORDER BY is immutable; wrong choice requires full data migration"
tags: [schema, primary-key, ORDER BY, planning]
---

## Plan ORDER BY Before Table Creation

**Impact: CRITICAL**

ClickHouse's PRIMARY KEY (defined via ORDER BY) is immutable after table creation. Once created with an incorrect ORDER BY, you cannot use ALTER TABLE to modify it. Fixing mistakes requires building a new table and migrating all data — a costly operation at scale.

**Before creating any table:**

1. **Analyze query patterns** — Document your 5-10 most frequent queries
2. **Identify filter columns** — Note which WHERE clause columns appear most often
3. **Prioritize selectivity** — Rank columns by their ability to eliminate rows
4. **Order by cardinality** — Place low-cardinality columns before high-cardinality ones
5. **Keep it concise** — Limit to 4-5 key columns maximum

**Incorrect (arbitrary column order without analysis):**

```sql
-- No analysis of query patterns; arbitrary ORDER BY
CREATE TABLE events (
    event_id UUID,
    timestamp DateTime,
    user_id UInt32,
    event_type String
)
ENGINE = MergeTree()
ORDER BY (event_id);
-- event_id has highest cardinality, queries by user_id will full-scan
```

**Correct (ORDER BY based on documented query patterns):**

```sql
-- Analyzed: 80% of queries filter by user_id + timestamp range
CREATE TABLE events (
    event_id UUID,
    timestamp DateTime,
    user_id UInt32,
    event_type LowCardinality(String)
)
ENGINE = MergeTree()
ORDER BY (user_id, timestamp);
-- Matches dominant query pattern
```

Reference: [Choosing a Primary Key](https://clickhouse.com/docs/best-practices/choosing-a-primary-key)
