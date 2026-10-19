---
name: clickhouse
description: Use when reviewing or writing ClickHouse schemas, queries, inserts, or operations. Check the checklist below and cite rules by name.
---

# ClickHouse

ClickHouse has a sparse primary index, immutable parts, and background merges, so row-store habits mislead. Details: <https://clickhouse.com/docs>. Never put real credentials in examples.

Review output: list each rule checked as compliant or violated, cite as "Per `rule-name`", give current state, required state, and fix. End with prioritized recommendations.

## Review checklist

Schema, ORDER BY cannot change after creation:

- `schema-pk-plan-before-creation`: decide ORDER BY before creating the table.
- `schema-pk-cardinality-order`: order key columns low to high cardinality.
- `schema-pk-prioritize-filters`: put frequently filtered columns in ORDER BY.
- `schema-pk-filter-on-orderby`: queries filter on the ORDER BY prefix.
- `schema-types-native-types`: use native types, not String.
- `schema-types-minimize-bitwidth`: smallest numeric width that fits.
- `schema-types-lowcardinality`: LowCardinality for repeated strings under about 10K values.
- `schema-types-avoid-nullable`: avoid Nullable, use defaults.
- `schema-types-enum`: Enum for finite value sets.
- `schema-partition-start-without`: start without partitioning.
- `schema-partition-low-cardinality`: 100 to 1,000 partitions at most.
- `schema-partition-lifecycle`: partition for data lifecycle, drop partitions instead of DELETE.
- `schema-partition-query-tradeoffs`: queries spanning many partitions get slower.
- `schema-json-when-to-use`: JSON type only for dynamic schemas, typed columns otherwise.

Queries:

- `query-join-choose-algorithm`: pick the join algorithm for table size to avoid OOM.
- `query-join-use-any`: ANY JOIN when one match is enough.
- `query-join-filter-before`: filter both sides before joining.
- `query-join-consider-alternatives`: dictionaries or denormalization instead of joins.
- `query-join-null-handling`: default values instead of NULL in outer joins.
- `query-index-skipping-indices`: skipping indices for non-ORDER BY filters.
- `query-mv-incremental`: incremental materialized views for real-time aggregation.
- `query-mv-refreshable`: refreshable materialized views for complex joins and batch.

Inserts and changes:

- `insert-batch-size`: batch 10K to 100K rows per insert.
- `insert-async-small-batches`: async inserts when client batching is impractical.
- `insert-format-native`: Native format over JSONEachRow.
- `insert-mutation-avoid-update`: no ALTER UPDATE, use ReplacingMergeTree.
- `insert-mutation-avoid-delete`: no ALTER DELETE, use lightweight DELETE, CollapsingMergeTree, or DROP PARTITION.
- `insert-optimize-avoid-final`: no routine `OPTIMIZE ... FINAL` or `FINAL` reads.

Rules derive from [ClickHouse/agent-skills](https://github.com/ClickHouse/agent-skills) (Apache-2.0).
