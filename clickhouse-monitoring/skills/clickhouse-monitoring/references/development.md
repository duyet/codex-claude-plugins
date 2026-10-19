# Development Guide

Patterns and conventions for contributing to the ClickHouse Monitor dashboard.

## Architecture Overview

### Static Site Design

**Critical**: This is a **fully static site** with no server-side rendering. All pages use client-side data fetching via SWR.

**Implications:**
- No `use server()` directives
- No `redirect()` from next/navigation - use `useRouter` + `useEffect`
- All data fetching happens client-side
- Better CDN caching and edge deployment

### Routing Pattern

**Old (Don't Use):**
```
app/[host]/overview/page.tsx  → Dynamic route
URL: /0/overview
```

**New (Use This):**
```
app/overview/page.tsx  → Static route
URL: /overview?host=0
```

**Benefits:**
- Faster initial page load (static shell pre-rendered)
- Better CDN caching
- Simpler deployment
- Progressive data loading

### Project Structure

```
app/
├── api/v1/              # API routes for data fetching
│   ├── data/            # Generic query endpoint
│   ├── charts/[name]/   # Chart-specific data
│   ├── tables/[name]/   # Table data with pagination
│   ├── explorer/        # Data explorer API
│   └── hosts/           # Host configuration
├── overview/            # Static pages with ?host= query param
├── dashboard/
├── explorer/
└── running-queries/

components/
├── data-table/          # Advanced table system
├── charts/              # Chart components (32+)
├── overview-charts/     # Overview page charts
└── ui/                  # shadcn/ui components (DO NOT MODIFY)

lib/
├── api/
│   ├── types.ts         # API request/response types
│   ├── chart-registry.ts # Chart query registry
│   └── table-registry.ts # Table query registry
├── swr/
│   ├── provider.tsx     # SWR configuration
│   ├── use-host.ts      # Extract hostId from query params
│   ├── use-chart-data.ts # Chart data fetching
│   └── use-table-data.ts # Table data fetching
├── query-config/        # Centralized query configurations
├── clickhouse.ts        # ClickHouse client
└── charts/              # Chart query definitions
```

## SWR Data Fetching Pattern

### The Standard Pattern

**All client components that fetch data follow this pattern:**

```typescript
'use client'
import { Suspense } from 'react'
import { useHostId } from '@/lib/swr'
import { ChartSkeleton } from '@/components/skeletons'
import { YourChart } from '@/components/charts/your-chart'

export default function YourPage() {
  const hostId = useHostId() // Extracts ?host= from URL

  return (
    <Suspense fallback={<ChartSkeleton />}>
      <YourChart hostId={hostId} />
    </Suspense>
  )
}
```

### Chart Component Template

```typescript
'use client'
import useSWR from 'swr'
import { useChartData } from '@/lib/swr/use-chart-data'
import { ChartSkeleton } from '@/components/skeletons'
import { ChartError } from '@/components/error-alert'

interface YourChartProps {
  hostId: number
  interval?: number
}

export function YourChart({ hostId, interval = 300000 }: YourChartProps) {
  const { data, error, isLoading } = useChartData({
    name: 'your-chart-name',
    hostId,
    interval,
  })

  if (isLoading) return <ChartSkeleton />
  if (error) return <ChartError error={error} />
  if (!data || data.length === 0) return <div>No data available</div>

  // Render chart using recharts, tremor, or custom
  return <div>{/* Chart rendering */}</div>
}
```

### useChartData Hook

```typescript
const { data, error, isLoading } = useChartData({
  name: 'chart-name',     // From chart registry
  hostId: 0,              // Required
  interval: 300000,       // Refresh interval (ms)
  lastHours: 24,          // For historical charts
  params: {               // Optional chart params
    database: 'default',
  },
})
```

### useTableData Hook

```typescript
const { data, error, isLoading } = useTableData({
  queryConfigName: 'running-queries',
  hostId: 0,
  searchParams: {
    pageSize: '50',
    page: '1',
  },
})
```

## Adding a New Route

### Step 1. Create Page Component

Create `app/your-route/page.tsx`:

```typescript
'use client'

import { Suspense } from 'react'
import { useHostId } from '@/lib/swr'
import { ChartSkeleton, TableSkeleton } from '@/components/skeletons'
import { RelatedCharts, Table } from '@/components'

export default function YourRoutePage() {
  const hostId = useHostId()

  return (
    <div className="flex flex-col gap-4">
      <Suspense fallback={<ChartSkeleton />}>
        <RelatedCharts
          relatedCharts={['chart-name-1', 'chart-name-2']}
          hostId={hostId}
        />
      </Suspense>
      <Suspense fallback={<TableSkeleton />}>
        <Table
          title="Your Data"
          queryConfigName="your-query-config"
          hostId={hostId}
        />
      </Suspense>
    </div>
  )
}
```

### Step 2. Add Menu Item

Edit `menu.ts`:

```typescript
{
  title: 'Your Route',
  href: '/your-route',
  description: 'Your route description',
  icon: YourIcon,
  countKey: 'your-count',
  countLabel: 'items',
}
```

### Step 3. Create Query Config (if needed)

Add to `lib/query-config/`:

```typescript
export const yourConfig: QueryConfig = {
  name: 'your-query',
  description: 'Query description',
  sql: 'SELECT database, table FROM system.parts',
  columns: ['database', 'table'],
  columnFormats: {
    database: ColumnFormat.Badge,
    table: ColumnFormat.Text,
  },
}
```

## Troubleshooting Development

### Common Issues

**Build fails with TypeScript errors:**
- Check `bun run build` output
- Fix type errors in indicated files
- Ensure imports are correct

**SWR not refetching:**
- Check `interval` is set correctly
- Verify API endpoint returns data
- Check network tab for failed requests

**Charts show "No data available":**
- Verify ClickHouse table exists and has data
- Check query is valid for ClickHouse version

**Multi-host not working:**
- Verify all environment arrays have same length
- Check `CLICKHOUSE_HOST`, `CLICKHOUSE_USER`, `CLICKHOUSE_PASSWORD`
- Use comma-separated values

