# ClickHouse Monitoring Dashboard

> **Type**: project
> **Last Updated**: 2025-01-05
> **Repository**: https://github.com/duyet/clickhouse-monitoring
> **Demo**: https://clickhouse-monitoring.duyet.net
> **Related**: [duyet-profile](../../duyet-profile.md)

## Project Overview

ClickHouse Monitoring Dashboard is a **Next.js-based monitoring tool** that provides real-time visibility into ClickHouse cluster performance, query execution, and system health using only `system.*` tables - no external dependencies or agents required.

**Key Philosophy**: Simple, lightweight, self-contained monitoring that works out of the box with any ClickHouse installation.

## Tech Stack

### Frontend
- **Framework**: Next.js 16 (App Router, React Server Components)
- **UI**: Tailwind CSS 4, Radix UI, Tremor
- **Charts**: Recharts (custom generic chart system)
- **State**: React hooks, server-only context
- **Language**: TypeScript 5

### Backend
- **Runtime**: Node.js (standalone) or Cloudflare Workers (OpenNext)
- **Database**: ClickHouse via `@clickhouse/client-web`
- **Deployment**: Vercel, Docker, Kubernetes (Helm), Cloudflare

### Development
- **Package Manager**: pnpm (strict mode)
- **Linting**: Biome (replacement for ESLint/Prettier)
- **Testing**: Jest (unit), Cypress (E2E + component)
- **Build**: Turbopack (Next.js 16 default)

### Monitoring
- **Bundle Analysis**: Codecov webpack plugin
- **Memory**: Custom health metrics endpoint
- **Uptime**: https://duyet.github.io/uptime/history/clickhouse-monitoring-vercel-app

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Next.js App Router                    │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │   Pages      │  │   API Routes │  │  Components  │ │
│  │              │  │              │  │              │ │
│  │ [host]/      │  │ /api/health  │  │ Charts/      │ │
│  │ overview/    │  │ /api/init    │  │ DataTable/   │ │
│  │ query/       │  │ /api/clean   │  │ UI/          │ │
│  │ tables/      │  │              │  │              │ │
│  │ ...          │  │              │  │              │ │
│  └──────────────┘  └──────────────┘  └──────────────┘ │
│         │                   │                   │       │
│         └───────────────────┼───────────────────┘       │
│                             │                           │
├─────────────────────────────┼───────────────────────────┤
│                             ▼                           │
│                  ┌──────────────────┐                   │
│                  │ ClickHouse Client│                   │
│                  │  (Connection Pool)│                   │
│                  └──────────────────┘                   │
└─────────────────────────────────────────────────────────┘
                             │
                             ▼
                  ┌──────────────────┐
                  │   ClickHouse     │
                  │  system.* tables │
                  └──────────────────┘
```

## Key Features

### 1. Query Monitor
- **Current queries**: Real-time running queries with resources
- **Query history**: Past query execution with duration/memory
- **Query resources**: Memory usage, parts read, files opened
- **Expensive queries**: Top resource-consuming queries
- **Table usage**: Most accessed tables and columns
- **User breakdown**: Query count by user with failure rates

### 2. Cluster Monitor
- **System metrics**: CPU, memory, disk usage
- **Merge performance**: Merge count, duration, read rows
- **Mutation tracking**: Mutation queue and progress
- **Distributed queue**: Distributed query status
- **Settings**: Global and MergeTree configuration
- **ZooKeeper**: ZK requests, exceptions, wait time, uptime

### 3. Tables & Parts Information
- **Table size**: Disk usage, row count, compression ratio
- **Part details**: Part size, rows, partition info
- **Column-level**: Size, type, compression per column
- **Replica status**: Replication lag, queue, absolute delay

### 4. Visualization Charts
- **Query metrics**: Count, duration, memory over time
- **Merge performance**: Merge count, avg duration, read rows
- **Resource usage**: CPU, memory, disk over time
- **Query cache**: Hit rate, memory savings
- **Connection stats**: HTTP, inter-server connections
- **Background tasks**: Mutation/merge queue sizes

### 5. Tools
- **ZooKeeper explorer**: Browse ZK data tree
- **Query EXPLAIN**: Visualize query plans
- **Kill queries**: Terminate running queries
- **Table info**: Detailed table metadata
- **Part info**: Individual part details

## Advanced Features

### Memory Optimization
**Achievement**: 50-70% memory reduction

| Optimization | Impact |
|--------------|--------|
| Connection pooling | 80% client memory reduction |
| Table memoization | 70% faster rendering (100+ cols) |
| Single-pass algorithms | 95% faster chart processing |
| Cache hard limit (1MB) | 87% cache memory reduction |
| Production logger | Zero logging overhead in prod |

**Files**:
- `lib/clickhouse.ts` - Connection pool management
- `lib/memory-monitor.ts` - Memory metrics
- `lib/table-existence-cache.ts` - LRU cache with limits
- `lib/logger.ts` - Conditional logging

### Generic Chart System
**Architecture**: Layered separation of concerns

```
Data Fetching (server) → Visualization (client) → Presentation (UI)
```

**Features**:
- Type-safe chart configuration
- Automatic value formatting (bytes, duration, quantity)
- Interactive tooltips and click navigation
- SQL query exposure for transparency
- Raw data inspection dialog

**Chart Types**:
- Area charts (stacked, single)
- Bar charts (horizontal, vertical, stacked)
- Card metrics (single, multi-metric)
- Radial charts (gauge-style)
- Heat maps (GitHub-style activity)
- Tables with faceted filtering

### Error Handling
**Architecture**: Multi-layer graceful degradation

```
Error Boundary → HOC (withErrorHandling) → ErrorAlert → UI
```

**Features**:
- React error boundaries catch rendering failures
- HOC wraps components with try-catch
- Rich error display with stack traces
- SQL query visibility for debugging
- User-friendly error messages

### Multi-Host Support
**URL Structure**: `/[host]/[page]/[subpage]`

**Features**:
- Dynamic host switching via dropdown
- Independent contexts per host
- Shared navigation state
- Graceful fallback on connection failure

## Deployment Options

### 1. Vercel (Recommended)
**Config**: `vercel.json`
- Standalone output mode
- Edge functions for API routes
- Automatic HTTPS

### 2. Docker
**File**: `Dockerfile`
- Minimal node:alpine image
- Standalone build artifacts
- Production-ready configuration

### 3. Kubernetes
**Chart**: Available in repo
- Helm chart for easy deployment
- ConfigMap for environment variables
- Service and Ingress manifests

### 4. Cloudflare Workers
**Config**: `open-next.config.ts`, `wrangler.jsonc`
- OpenNext for Next.js adaptation
- D1 database for cache (optional)
- Edge deployment for global latency

## Performance Metrics

### Memory Optimization Results

| Metric | Before | After | Gain |
|--------|--------|-------|------|
| ClickHouse clients | 1-2MB/client | 200KB pooled | 80% |
| Table render (100+ cols) | 50-100ms | 10-20ms | 70% |
| Chart processing (1000+ rows) | O(n²) | O(n) | 95% |
| Cache memory | ~8MB unbounded | 1MB hard limit | 87% |
| Total app memory | Baseline | -50 to -70% | 60% avg |

### Bundle Analysis
- **Tool**: Codecov webpack plugin
- **Bundle name**: `clickhouse-monitoring-bundle`
- **Upload**: Automatic with CODECOV_TOKEN

## Development Guidelines

### Adding New Features

**1. ClickHouse Queries**:
```typescript
import { getClient } from '@/lib/clickhouse'

// Connection pooling is automatic
const client = await getClient()
const result = await client.query({ query: '...' })
```

**2. React Components**:
```typescript
import { useMemo } from 'react'

// Memoize expensive calculations
const processedData = useMemo(
  () => expensiveCalculation(data),
  [data] // Only recalculate when data changes
)
```

**3. Logging**:
```typescript
import { debug, error, warn } from '@/lib/logger'

// Development-only logging
debug('This is a debug message')

// Always logged
error('Critical error occurred')
```

**4. Charts**:
```typescript
// Use generic chart system
import { AreaChart, BarChart } from '@/components/generic-charts'

// Type-safe configuration
const config: ChartConfig = {
  stack: true,
  opacity: 0.6,
  readable: 'bytes'
}
```

## Monitoring & Debugging

### Health Endpoint
**URL**: `GET /api/health`

**Returns**:
```json
{
  "status": "healthy",
  "uptime": 12345,
  "metrics": {
    "memory": { "heapUsedPercent": 45 },
    "connectionPool": { "poolSize": 10 },
    "tableCache": { "size": 50, "maxSize": 500 }
  },
  "alerts": []
}
```

### Enable Debug Logging
```bash
DEBUG=true pnpm dev
```

### Check Memory Usage
```bash
curl http://localhost:3000/api/health | jq '.metrics.memory'
```

### Monitor Connection Pool
```bash
curl http://localhost:3000/api/health | jq '.metrics.connectionPool'
```

## Documentation

**Public Docs**: https://duyet.github.io/clickhouse-monitoring

**Sections**:
- Getting Started
  - Local Development
  - User Role and Profile
  - Enable System Tables
- Deployments
  - Vercel
  - Docker
  - Kubernetes (Helm)
- Advanced
  - Memory Optimization Guide
  - Generic Chart System
  - Error Handling

## Testing

### Unit Tests (Jest)
```bash
pnpm test                 # Run all tests
pnpm jest                 # With coverage
pnpm test-queries-config  # Query config tests only
```

### E2E Tests (Cypress)
```bash
pnpm e2e                # Interactive E2E
pnpm e2e:headless       # Headless E2E
pnpm cy:open            # Interactive mode
```

### Component Tests (Cypress)
```bash
pnpm component           # Interactive component testing
pnpm component:headless  # Headless component testing
```

## Quality & Tooling

### Linting & Formatting
```bash
pnpm lint          # Biome lint check
pnpm lint:fix      # Biome lint auto-fix
pnpm check         # Full Biome check (lint + format)
pnpm check:fix     # Auto-fix all issues
pnpm fmt           # Format with Biome
```

### Biome Configuration
**File**: `biome.json`
- Replacement for ESLint + Prettier
- 10-100x faster than ESLint
- Unified linting and formatting

### Renovate
**File**: `renovate.json`
- Automated dependency updates
- Configured for stability

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 0.1.0 | Current | Next.js 16, React 19, Tailwind CSS 4 |
| - | 2024 | Memory optimizations (50-70% reduction) |
| - | 2023 | Initial release with basic monitoring |

## Related Projects

| Project | URL | Description |
|---------|-----|-------------|
| ClickHouse | https://clickhouse.com | Database being monitored |
| @clickhouse/client | https://github.com/ClickHouse/clickhouse-js | Official JS client |
| Next.js | https://nextjs.org | Framework |
| Recharts | https://recharts.org | Chart library |

## Feedback & Contributions

- **Issues**: https://github.com/duyet/clickhouse-monitoring/issues
- **PRs**: Welcome!
- **License**: See LICENSE file

---

**Design Principles**:
- Simple over complex
- No external dependencies (uses system.* tables only)
- Lightweight and fast
- Production-ready with monitoring

**Inspired by**: Real production needs at Cartrack and Fossil Group where @duyet manages large-scale ClickHouse deployments.
