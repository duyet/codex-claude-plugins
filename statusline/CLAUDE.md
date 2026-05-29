# Statusline Plugin

Configurable multi-line status bar with context health, cache hit rate, session duration, API rate limits (Anthropic 5h/7d + z.ai GLM), git branch, active tools, and agent tracking. Supports 1/2/3 line layouts, icon themes, and 6 template presets. Dual-provider: Anthropic Claude and z.ai GLM.

## Versioning

Follow semantic versioning (semver) for this plugin:

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Bug fix, docs | Patch | 1.8.0 → 1.8.1 |
| New feature, minor change | Minor | 1.8.0 → 1.9.0 |
| Breaking change | Major | 1.8.0 → 2.0.0 |

**When to bump:**
- Adding new commands, skills, or agents → **Minor**
- Modifying existing behavior → **Minor** (or Major if breaking)
- Updating documentation only → **Patch**
- Bug fixes → **Patch**

Always update `plugin.json` version when making changes.

## Plugin Structure

```
statusline/
├── .claude-plugin/
│   └── plugin.json              # Manifest (version 1.8.0)
├── commands/                    # Slash commands
│   ├── setup.md                 # /statusline:setup — interactive wizard
│   ├── config.md                # /statusline:config — quick changes
│   ├── status.md                # /statusline:status — view metrics
│   └── disable.md               # /statusline:disable — pause updates
├── skills/
│   └── statusline-workflow/
│       └── SKILL.md             # Reusable skill for configuration
├── hooks/
│   ├── hooks.json               # Lifecycle hooks
│   └── session-start.sh         # Rate limit fetching on session start
├── scripts/
│   ├── statusline.py            # Configurable renderer (reads config JSON)
│   ├── format-status.ts         # TypeScript rate-limit fetcher
│   ├── test-statusline.sh       # Test harness
│   └── templates/               # Layout presets
│       ├── detailed.json        # 3-line, emoji, all sections (default)
│       ├── balanced.json        # 2-line, unicode, key metrics
│       ├── minimal.json         # 1-line, no icons, essentials
│       ├── monitor.json         # 2-line, rate-limit focused
│       ├── developer.json       # 2-line, tools+agents+git focused
│       └── performance.json     # 3-line, cache+context optimization
└── README.md
```

## Dual-Provider Behavior

| Feature | Anthropic Claude | z.ai GLM |
|---------|-----------------|----------|
| Model name | Simplified (`opus-4.8[200k]`) | Preserved from ID |
| Cache stats | Real prompt caching data | Hidden (proxy artifacts) |
| Rate limits | 5h/7d from payload | When available |
| All other features | ✅ | ✅ |

## Config Schema

`~/.claude/statusline.config.json` — see SKILL.md for full field reference.

## Commit Convention

Use semantic commits with plugin scope:

```
feat(statusline): add new feature
fix(statusline): fix bug
docs(statusline): update documentation
```

Co-author: `Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>`
