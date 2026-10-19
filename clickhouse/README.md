# clickhouse

ClickHouse review guidance for schemas, queries, and inserts, built around 28 atomic rules.

## Install

```text
/plugin install clickhouse@duyet-claude-plugins
```

## What ships

- `skills/clickhouse/SKILL.md`: decision tree that routes a review to the right rules.
- `skills/clickhouse/rules/`: 28 rules with incorrect and correct examples, grouped by schema, query, and insert.
- `skills/clickhouse/references/`: schema design, query optimization, debugging, and monitoring queries.

Rules are synced from [ClickHouse/agent-skills](https://github.com/ClickHouse/agent-skills) (Apache-2.0).
