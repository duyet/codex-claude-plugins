# Knowledge Structure Design

## Hierarchy

```
knowledge/
├── README.md                    # This file - structure overview
├── duyet-profile.md             # Main profile, work, skills
├── writing-style.md             # Writing patterns for duyetbot
├── blog-archive.md              # Blog posts by year/topic
├── _raw_data.txt                # Fetched llms.txt data
│
└── topics/                      # Nested topic-based knowledge
    ├── README.md                # Topic index
    ├── clickhouse/              # ClickHouse specific
    │   ├── overview.md
    │   ├── on-kubernetes.md
    │   └── best-practices.md
    ├── rust/                    # Rust programming
    │   ├── overview.md
    │   ├── data-engineering.md
    │   └── design-patterns.md
    ├── data-engineering/        # Data Engineering
    │   ├── overview.md
    │   ├── apache-spark.md
    │   └── airflow.md
    ├── devops/                  # DevOps & Cloud
    │   ├── kubernetes.md
    │   └── ci-cd.md
    └── side-projects/           # Personal projects
        └── overview.md
```

## Linking Strategy

### Internal Links
Use markdown relative links:

```markdown
<!-- Link to topic -->
See [ClickHouse on Kubernetes](topics/clickhouse/on-kubernetes.md)

<!-- Link to profile -->
For work history, see [duyet-profile.md](../duyet-profile.md)
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
| New blog series | Create topic folder | `topics/{series-name}/` |
| New job | Update profile | `duyet-profile.md` |
| New project | Add to projects | `topics/side-projects/` |
| New tech focus | Create topic | `topics/{topic}/` |
| Quarterly review | Refresh all | All files |

## Naming Conventions

- **Files**: `kebab-case.md`
- **Topics**: Lowercase directory names
- **Series**: Match blog series naming
- **Years**: For chronological organization

## Frontmatter Template

```markdown
# Title

> **Type**: {profile|blog|topic|guide}
> **Last Updated**: YYYY-MM-DD
> **Source**: {url|internal}
> **Related**: [link1](path), [link2](path)

## Content...
```

## Maintenance

```bash
# Check for broken links
# (Add markdown linting tool later)

# Find orphaned files
# (Add script later)

# Update timestamps
grep -r "Last Updated" knowledge/
```

---

**Design Principle**: Flat structure where possible, nested by topic when depth is needed. Each file should be independently useful but link to related content.
