---
name: chmonitor
description: Use when monitoring or diagnosing a ClickHouse cluster with chmonitor (queries, merges, replication, storage, health), or when working in the chmonitor codebase.
---

# chmonitor

chmonitor is a read-only dashboard and advisor for ClickHouse. It reads `system.*` tables and recommends changes. It never applies DDL.

- Cluster questions. Use the `chmonitor` MCP tools this plugin installs. They read schema, queries, merges, replication, and health.
- Running or deploying it. Read <https://docs.chmonitor.dev>.
- Changing its code. Clone <https://github.com/chmonitor/chmonitor> and follow its `AGENTS.md`.
