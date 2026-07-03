# Knowledge Structure Design

## Hierarchy

```
knowledge/
├── structure.md                 # This file - structure overview
├── duyet-profile.md             # Main profile, work, skills
├── writing-style.md             # Writing patterns for duyetbot
├── blog-archive.md              # Blog posts by year/topic
├── _raw_data.txt                # Fetched llms.txt data (source)
│
└── topics/                      # Topic-based knowledge
    ├── clickhouse-monitoring/   # ClickHouse monitoring dashboard
    │   └── overview.md
    ├── duyet-mcp-server/        # Personal MCP server
    │   └── overview.md
    └── duyetbot-agent/          # This agent plugin
        └── overview.md
```

## Linking Strategy

### Internal Links
Use markdown relative links:

```markdown
<!-- Link to profile -->
For work history, see [duyet-profile.md](./duyet-profile.md)
```

### External References
```markdown
<!-- Blog posts -->
Full article: [Why ClickHouse?](https://blog.duyet.net/2023/01/clickhouse.html)

<!-- GitHub -->
Source code: [github.com/duyet/repo-name](https://github.com/duyet/repo-name)
```

### Series Links
```markdown
## Series: ClickHouse on Kubernetes

1. [ClickHouse on Kubernetes](https://blog.duyet.net/2024/03/clickhouse-on-kubernetes.html)
2. [MergeTree](https://blog.duyet.net/2024/05/clickhouse-mergetree.html)
3. [ReplacingMergeTree](https://blog.duyet.net/2024/06/clickhouse-replacingmergetree.html)
4. [ReplicatedReplacingMergeTree](https://blog.duyet.net/2024/06/clickhouse-replicatedreplacingmergetree.html)
```

## When to Add Knowledge

| Trigger | Action | Location |
|---------|--------|----------|
| New project | Create topic folder | `topics/{project-name}/` |
| New job | Update profile | `duyet-profile.md` |
| New tech focus | Create topic | `topics/{topic}/` |
| Quarterly review | Refresh all | All files |

## Naming Conventions

- **Files**: `kebab-case.md`
- **Topics**: Lowercase with hyphens for multi-word names
- **Project topics**: `{project-name}/` matching repository name

## Frontmatter Template

```markdown
# Title

> **Type**: {profile|project|topic|guide}
> **Last Updated**: YYYY-MM-DD
> **Source**: {url|internal}
> **Related**: [link1](path), [link2](path)

## Content...
```

## Maintenance

```bash
# Update knowledge base
cd /path/to/claude-plugins/duyetbot
./scripts/fetch-duyet-data.sh

# Update timestamps
grep -r "Last Updated" knowledge/
```

---

**Design Principle**: Flat structure with topic-based organization. Each file independently useful with cross-references to related content.
