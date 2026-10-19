---
name: chmonitor
description: "Use when working on the ClickHouse Monitor dashboard: adding charts, pages, or query configs, calling its API, or handling ClickHouse version differences in system table queries."
---

# ClickHouse Monitor

Real-time monitoring and observability dashboard for ClickHouse clusters. Static site architecture with client-side SWR data fetching, multi-host support, and version-aware queries.

## Quick Start

### Dashboard Access

Navigate using query parameter routing (`?host=N` for multi-host setups):

- `/overview?host=0` - System overview (Connections, Queries, Merges, Replication, System)
- `/running-queries?host=0` - Active queries with progress tracking
- `/explorer?host=0` - Interactive database schema browser
- `/merges?host=0` - Active merge operations with progress
- `/clusters?host=0` - Cluster configuration and ZooKeeper status

### Multi-Host Configuration

Configure multiple ClickHouse instances via comma-separated environment variables:

```bash
CLICKHOUSE_HOST=prod.example.com,staging.example.com
CLICKHOUSE_USER=admin,readonly
CLICKHOUSE_PASSWORD=secret,readonly_secret
CLICKHOUSE_NAME="Production,Staging"
```

Access hosts via `?host=0`, `?host=1`, etc. in URLs.

## Core features

The dashboard covers query monitoring (running, history, failed, expensive, cache), table management (explorer, replicas, projections, dictionaries), merges and mutations, system metrics and settings, and security logs (sessions, login attempts, crashes). See `references/dashboard-pages.md` for every page.

## API Usage

### Chart Data

Fetch time-series data for visualization:

```http
GET /api/v1/charts/{chartName}?hostId={hostId}&interval={interval}&lastHours={hours}
```

**Parameters:**

- `chartName` - Name from chart registry (see references for full list)
- `hostId` - Host index (0-based)
- `interval` - Time bucket: `1m`, `5m`, `1h`, `1d`
- `lastHours` - Historical range (default: 24)

**Response:**

```json
{
  "success": true,
  "data": [{ "ts": "2026-03-05T00:00:00Z", "value": 1234 }],
  "metadata": {
    "queryId": "abc123",
    "duration": 45,
    "rows": 24,
    "host": "clickhouse.example.com",
    "clickhouseVersion": "24.3.1.1"
  }
}
```

### Table Data

Fetch paginated table data:

```http
GET /api/v1/tables/{queryConfigName}?hostId={hostId}&pageSize={n}&page={p}
```

Supports sorting (`sortCol`, `sortOrder`) and filtering per query config.

### Database Explorer

Browse schema structure:

```http
GET /api/v1/explorer/databases?hostId={hostId}
GET /api/v1/explorer/tables?hostId={hostId}&database={db}
GET /api/v1/explorer/columns?hostId={hostId}&database={db}&table={t}
```

## Development Patterns

### Static Site Architecture

Fully static site with client-side data fetching. No SSR, no middleware.

**Routing Pattern:**

```typescript
// Static route with query parameter
app/overview/page.tsx  to  /overview?host=0

// NOT dynamic routes (not supported)
// app/[host]/overview/page.tsx
```

**Page Component Template:**

```typescript
'use client'

import { Suspense } from 'react'
import { useHostId } from '@/lib/swr'
import { ChartSkeleton } from '@/components/skeletons'
import { YourChart } from '@/components/charts/your-chart'

export default function YourPage() {
  const hostId = useHostId()  // Extracts from ?host= query param

  return (
    <Suspense fallback={<ChartSkeleton />}>
      <YourChart hostId={hostId} />
    </Suspense>
  )
}
```

### SWR Data Fetching

All data uses SWR with the `hostId` pattern:

```typescript
import useSWR from 'swr'
import { useChartData } from '@/lib/swr/use-chart-data'

export function YourChart({ hostId }: { hostId: number }) {
  const { data, error, isLoading } = useChartData({
    name: 'your-chart-name',
    hostId,
    interval: 300000,  // 5 minutes SWR cache
  })

  if (isLoading) return <ChartSkeleton />
  if (error) return <ChartError error={error} />
  // ... render chart with data
}
```

### Adding Charts

1. **Define query** in `lib/api/charts/{domain}-charts.ts`:

```typescript
export const yourChart: ChartQueryBuilder = (params) => ({
  sql: `
    SELECT toStartOfInterval(event_time, INTERVAL {interval:UInt64} SECOND) AS ts,
           COUNT() AS value
    FROM system.query_log
    WHERE event_time > now() - INTERVAL {lastHours:UInt64} HOUR
    GROUP BY ts ORDER BY ts
  `,
  columns: ["ts", "value"],
});
```

2. **Register** in `lib/api/chart-registry.ts`:

```typescript
export const chartRegistry = {
  // ...
  "your-chart-name": yourChart,
};
```

3. **Create component** in `components/charts/`:

```typescript
"use client";
import { useChartData } from "@/lib/swr/use-chart-data";

export function YourChart({ hostId }: { hostId: number }) {
  const { data } = useChartData({ name: "your-chart-name", hostId });
  // Render using Recharts or Tremor
}
```

### Query Configuration

Add table views via `QueryConfig` in `lib/query-config/queries/`:

```typescript
export const yourConfig: QueryConfig = {
  name: "your-query",
  description: "Query description",
  sql: `
    SELECT database, table,
           formatReadableQuantity(sum(rows)) AS total_rows
    FROM system.parts
    WHERE active
    GROUP BY database, table
    ORDER BY total_rows DESC
  `,
  columns: ["database", "table", "total_rows"],
  columnFormats: {
    database: ColumnFormat.Badge,
    total_rows: [
      ColumnFormat.BackgroundBar,
      {
        base: "rows",
        readable: "total_rows",
        pct: "pct_rows",
      },
    ],
  },
};
```

**BackgroundBar format** requires 3 SQL columns:

```sql
rows,                              -- base value
formatReadableQuantity(rows) AS total_rows,  -- display
round(rows * 100 / max(rows) OVER (), 2) AS pct_rows  -- percentage
```

## ClickHouse Compatibility

### Version-Aware Queries

ClickHouse system tables change between versions. Use `VersionedSql[]`:

```typescript
export const yourConfig: QueryConfig = {
  name: "your-query",
  sql: [
    { since: "23.8", sql: "SELECT col1 FROM system.table" },
    { since: "24.3", sql: "SELECT col1, col2 FROM system.table" },
  ],
  columns: ["col1", "col2"],
};
```

The system selects the appropriate query based on detected ClickHouse version.

### Optional Tables

Some tables don't exist depending on configuration. Mark as `optional`:

```typescript
export const backupsConfig: QueryConfig = {
  name: "backups",
  optional: true, // Graceful handling if table missing
  tableCheck: "system.backup_log",
  sql: "SELECT * FROM system.backup_log",
  // ...
};
```

**Optional tables**: `backup_log`, `error_log`, `zookeeper`, `monitoring_events`.

## Common Issues

**Empty charts?**

- Verify required log tables enabled: `query_log`, `metric_log`, `part_log`
- Check ClickHouse configuration for log settings

**API returns `table_not_found`?**

- Optional table missing - verify ClickHouse configuration
- Version mismatch: check the query's `since` versions in `references/clickhouse-compat.md`

**Multi-host not working?**

- Verify all three env arrays have same length
- Use comma-separated values: `host1,host2` (not spaces)
- Check each host's credentials individually

## References

- [Complete API List](references/api-list.md) - All 58 charts and 63 table endpoints
- [Dashboard Pages](references/dashboard-pages.md) - All 45 dashboard pages with descriptions
- [API Endpoints](references/api-endpoints.md) - Detailed API documentation with examples
- [Development Guide](references/development.md) - Architecture patterns, conventions, contribution workflow
- [ClickHouse Compatibility](references/clickhouse-compat.md) - Version-aware queries, schema docs, optional tables
- [Project Repository](https://github.com/chmonitor/chmonitor)
