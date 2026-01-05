# Duyet Knowledge Management

Maintain and update knowledge base about Duyet Le (@duyet).

## Knowledge Sources

| Source | URL | Type | Update Frequency |
|--------|-----|------|------------------|
| Profile | https://duyet.net/llms.txt | LLM-friendly profile | As needed |
| Resume | https://cv.duyet.net/llms.txt | CV/Experience | As needed |
| Blog | https://blog.duyet.net/llms.txt | Technical blog | Monthly |
| Blog Feed | https://blog.duyet.net/feed | RSS feed | Weekly |
| GitHub | https://github.com/duyet | Repos, activity | Dynamic |
| X/Twitter | https://x.com/_duyet | Thoughts, updates | Dynamic |
| Insights | https://insights.duyet.net | Analytics dashboard | Monthly |

## Quick Update

```bash
# Fetch all llms.txt sources
./scripts/fetch-duyet-data.sh

# Commit changes with semantic commit
git add knowledge/
git commit -m "feat(duyetbot): update duyet profile knowledge

- Updated from duyet.net/llms.txt
- Refreshed blog archive from blog.duyet.net
- Synced latest GitHub activity

Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>"
```

## When to Update

| Trigger | Action |
|---------|--------|
| New job/experience | Fetch from cv.duyet.net/llms.txt |
| New blog post series | Fetch from blog.duyet.net/llms.txt |
| Major project launch | Check GitHub, update profile |
| Quarterly review | Full refresh from all sources |
| User asks about @duyet | Verify knowledge is current |

## Data Freshness

- **Profile (duyet-profile.md)**: Update when experience changes
- **Blog Archive (blog-archive.md)**: Update monthly or when new series starts
- **GitHub Activity**: Fetch dynamically when needed
- **Latest Posts**: Check feed for recent entries

## Verification

After updating, verify:
```bash
# Check file updated correctly
head -20 knowledge/duyet-profile.md | grep "Last Updated"

# Verify no markdown errors
# (Add linting if needed)
```

## Version Bump

After updating knowledge:
- **Patch**: Documentation only updates
- **Minor**: New data sources added
- **Major**: Knowledge structure changes

Update `.claude-plugin/plugin.json` version accordingly.

---

**Skill maintained by**: duyetbot
**Last skill update**: 2025-01-05
