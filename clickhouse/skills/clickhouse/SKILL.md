---
name: clickhouse
description: Use when reviewing or writing ClickHouse schemas, queries, inserts, or operations. Check the matching rule files in rules/ first and cite them by name in your answer.
---

# ClickHouse

ClickHouse behaves differently from row-store databases (sparse primary index, immutable parts, background merges), so general database habits mislead. The 28 files in `rules/` encode the validated guidance. Read the relevant ones before recommending anything, and cite each as "Per `rule-name`".

Order of sources: `rules/`, then `references/`, then the official docs. Say which one you used.

Never put real credentials in examples. Use environment variables, a secret manager, or named collections.

## Which rules to read

### Schema review (CREATE TABLE, ALTER TABLE)

- ORDER BY and primary key: `schema-pk-plan-before-creation`, `schema-pk-cardinality-order`, `schema-pk-prioritize-filters`, `schema-pk-filter-on-orderby`. ORDER BY cannot be changed after creation.
- Types: `schema-types-native-types`, `schema-types-minimize-bitwidth`, `schema-types-lowcardinality`, `schema-types-avoid-nullable`, `schema-types-enum`.
- Partitioning: `schema-partition-start-without`, `schema-partition-low-cardinality`, `schema-partition-lifecycle`, `schema-partition-query-tradeoffs`.
- JSON columns: `schema-json-when-to-use`.

### Query review (SELECT, JOIN, aggregation)

- Joins: `query-join-choose-algorithm`, `query-join-use-any`, `query-join-filter-before`, `query-join-consider-alternatives`, `query-join-null-handling`.
- Filters on non-key columns: `query-index-skipping-indices`.
- Precomputation: `query-mv-incremental`, `query-mv-refreshable`.

### Insert and update review

- Batching: `insert-batch-size` (10K to 100K rows), `insert-async-small-batches`, `insert-format-native`.
- Changes to existing rows: `insert-mutation-avoid-update`, `insert-mutation-avoid-delete`.
- Merges: `insert-optimize-avoid-final`.

`rules/_sections.md` lists the categories by impact. CRITICAL rules (primary key, types, joins, batching, mutations) come first.

## Table engine choice

```text
Small dimension table (under 1M rows)? Memory or MergeTree
Otherwise MergeTree family
├── Deduplicate by key        ReplacingMergeTree(version)
├── Cancel rows with a sign   CollapsingMergeTree(sign)
├── Pre-aggregate             AggregatingMergeTree
├── Replicated cluster        Replicated* variant of the above
└── Default                   MergeTree
```

## Common symptoms

| Symptom         | First step                                                                                                                   |
| --------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| Too many parts  | Fix insert batching (`insert-batch-size`). Do not run `OPTIMIZE ... FINAL` as a routine fix (`insert-optimize-avoid-final`). |
| Slow query      | `EXPLAIN indexes = 1` to check whether the key prefix is used                                                                |
| Stuck mutation  | Check `system.mutations`, then see `insert-mutation-avoid-update`                                                            |
| Replication lag | Check `system.replication_queue` and Keeper health                                                                           |
| Out of memory   | Reduce data read first, then tune `max_memory_usage`                                                                         |

## References

- `references/schema-design.md` for ORDER BY patterns, partition operations, codecs, skip indexes, and migrations.
- `references/query-optimization.md` for EXPLAIN, join tuning, projections.
- `references/debugging.md` for query, merge, mutation, and replication troubleshooting.
- `references/monitoring.md` for ready-to-use `system.*` queries, alerting, and Prometheus.

## Review output

List each rule checked as compliant or violated. For each violation give the current state, the required state, and the fix. End with prioritized recommendations that cite rules.

Rules are synced from [ClickHouse/agent-skills](https://github.com/ClickHouse/agent-skills) (Apache-2.0).
