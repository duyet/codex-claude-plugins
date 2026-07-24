# Statusline

A Claude Code plugin that provides real-time visibility into your coding session. Track context usage, cache hit rates, session duration, API rate limits, active tools, and running agents — all at a glance.

**Dual-provider support:** Automatically adapts to Anthropic Claude and z.ai GLM models with provider-specific metrics.

## Quick Start

```bash
/plugin install statusline
/statusline:setup
```

Answer 4 questions and your statusline is live. That's it.

## What You See

The statusline renders in your terminal below the input prompt, updating automatically every turn.

### 3-line Detailed (default)

```
📁 monorepo (master) → 🤖 opus-4.8[200k] (medium) → ⏳ 23m
📊 ██░░░░░░░░ 21% (43k/200k) → 🗃️ 98% (42k/43k) cache hit → ⏱️ 5h: 45% | 7d: 28%
🔧 Seq Ctx7
```

### 2-line Balanced

```
monorepo (master) → opus-4.8[200k] (medium) → 23m
██░░░░░░░░ 21% (43k/200k) → cache 98% (42k/43k) → 5h: 45% | 7d: 28% → Seq Ctx7
```

### 1-line Minimal

```
monorepo (master) · opus-4.8[200k] (medium) · 21% · 5h: 45% | 7d: 28%
```

## Features

### 📊 Context Health

See how much of your context window you've used — with color-coded thresholds:

| Range | Color | Meaning |
|-------|-------|---------|
| 0–49% | 🟢 Green | Plenty of room |
| 50–69% | 🟡 Dim yellow | Starting to fill |
| 70–84% | 🟡 Bold yellow | Getting tight |
| 85%+ | 🔴 Bold red | Approaching limit |

Three display styles:
- **Progress bar**: `██░░░░░░░░ 21% (43k/200k)`
- **With tokens**: `21% (43k/200k)`
- **Compact**: `21%`

### 🗃️ Cache Hit Rate + TTL Countdown (Anthropic only)

Shows how effective prompt caching is, and how long until the cache expires:

```
🗃️ cache 98% (42k/43k) 5m ⏳3m40s
🗃️ cache expired (1m00s ago · next msg full price)
```

- Percentage with decimal precision when ≥99% (e.g., `99.98%`)
- Token breakdown: cached reads vs total cacheable tokens
- Live countdown of the cache TTL window (`cache_ttl`: `"5m"` default, or `"1h"`); the clock resets whenever a new API request lands
- Once expired, shows an explicit red marker instead of a stale hit % — the next message repays the full prompt price
- **Only shown for Anthropic Claude models** — GLM proxy values aren't real cache metrics

### 💰 Session Cost

Total cost of the current session, straight from Claude Code's payload:

```
💰 $1.23
```

### ⏳ Session Duration

Tracks how long your current session has been running:

```
⏳ 1h23m
```

- File-based tracker persists across statusline updates
- Auto-resets after 24 hours of inactivity

### ⏱️ Rate Limits

**Anthropic Claude** — 5-hour and 7-day utilization with reset timers:

```
⏱️ 5h: 45% (reset 1h12m) | 7d: 28%
```

**z.ai GLM** — Shown when available from the API:

```
⏱️ rate-limits: n/a
```

Rate limits use the same color thresholds as context health.

### 🤖 Model Name

Simplified model names with context window size:

| Raw Model ID | Display |
|-------------|---------|
| `claude-opus-4-8` | `opus-4.8[200k]` |
| `claude-sonnet-4-6` | `sonnet-4.6[200k]` |
| `glm-5.1[1m]` | `glm-5.1[1m]` |

Effort/reasoning level shown in parentheses: `opus-4.8[200k] (medium)`

### 🔧 Active Tools & Agents

Process-detected MCP servers and running agent count:

```
🔧 Seq Ctx7 ZRead
👷 3 active
```

Hidden when idle: `💤 idle`

### 📁 Project & Branch

Current directory and git branch:

```
📁 monorepo (master)
```

## Dual-Provider Support

| Feature | Anthropic Claude | z.ai GLM |
|---------|-----------------|----------|
| Model name | Simplified (e.g., `opus-4.8[200k]`) | Preserved from model ID |
| Rate limits | 5h/7d from JSON payload | Shown when available |
| Cache stats | ✅ Real prompt caching data | ❌ Hidden (proxy artifacts) |
| Context window | From JSON payload | From JSON payload |
| Effort level | low/medium/high/max | low/medium/high/max |
| Session/tools | All features | All features |

## Template Presets

Six built-in presets for different workflows. Apply via `/statusline:config` → Template:

| Template | Lines | Icons | Focus |
|----------|-------|-------|-------|
| **Detailed** | 3 | emoji | Full visibility — everything shown |
| **Balanced** | 2 | unicode | Quick overview — key metrics only |
| **Minimal** | 1 | none | Maximum space — bare essentials |
| **Monitor** | 2 | emoji | Rate-limit tracking — hides tools |
| **Developer** | 2 | unicode | Tools + agents + git focused |
| **Performance** | 3 | emoji | Cache + context optimization |

## Configuration

All settings stored in `~/.claude/statusline.config.json`:

```json
{
  "line_format": "3",
  "separator": "arrow",
  "context_style": "progress_bar",
  "icon_style": "emoji",
  "show_context": true,
  "show_rate_limits": true,
  "show_git_branch": true,
  "show_tools": true,
  "show_agents": true,
  "show_cache": true,
  "show_session": true,
  "show_reasoning": true,
  "show_cost": true,
  "cache_ttl": "5m",
  "color_style": "colorful"
}
```

### Config Reference

| Field | Values | Default | Description |
|-------|--------|---------|-------------|
| `line_format` | `"1"`, `"2"`, `"3"` | `"3"` | Number of output lines |
| `separator` | `"arrow"`, `"pipe"`, `"dot"`, `"slash"` | `"arrow"` | Section separator |
| `context_style` | `"progress_bar"`, `"tokens"`, `"compact"` | `"progress_bar"` | Context display format |
| `icon_style` | `"emoji"`, `"unicode"`, `"minimal"` | `"emoji"` | Icon theme |
| `show_context` | boolean | `true` | Token count and percentage |
| `show_rate_limits` | boolean | `true` | API usage metrics |
| `show_git_branch` | boolean | `true` | Current git branch |
| `show_tools` | boolean | `true` | Running MCP servers |
| `show_agents` | boolean | `true` | Running agent count |
| `show_cache` | boolean | `true` | Cache hit rate + TTL countdown (Claude only) |
| `cache_ttl` | `"5m"`, `"1h"` | `"5m"` | Prompt-cache TTL window for the countdown |
| `show_cost` | boolean | `true` | Total session cost (USD) |
| `show_session` | boolean | `true` | Session duration |
| `show_reasoning` | boolean | `true` | Effort level next to model |

## Commands

| Command | Purpose |
|---------|---------|
| `/statusline:setup` | Interactive setup wizard |
| `/statusline:config` | Quick layout/style changes |
| `/statusline:status` | Display current session metrics |
| `/statusline:disable` | Pause automatic status updates |

## Smart Hiding

Empty values are never shown — no "0%" or "n/a" clutter:
- Cache section hidden for GLM models (not real data)
- Rate limits show "n/a" only when provider data is genuinely unavailable
- Tools/agents sections collapse when nothing is running
- Session duration hidden on first render (0s)

## Requirements

- Claude Code v1.0.80+
- Python 3.8+ (for the statusline renderer)
- Git (for branch detection)

## License

MIT License
