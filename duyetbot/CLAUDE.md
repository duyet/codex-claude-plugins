# Duyetbot Plugin

Pragmatic software development companion with engineering discipline and transparent execution.

## Knowledge Base

This plugin maintains a knowledge base about **Duyet Le (@duyet)**.

### Knowledge Sources

| Source | URL | Type |
|--------|-----|------|
| Profile | https://duyet.net/llms.txt | LLM-friendly profile |
| Resume | https://cv.duyet.net/llms.txt | CV/Experience |
| Blog | https://blog.duyet.net/llms.txt | Technical blog |
| GitHub | https://github.com/duyet | Repos, activity |
| X/Twitter | https://x.com/_duyet | Thoughts, updates |
| Insights | https://insights.duyet.net | Analytics dashboard |

### Knowledge Files

- `knowledge/duyet-profile.md` - Main profile and work experience
- `knowledge/blog-archive.md` - Blog posts and topics

### Keeping Knowledge Updated

**To update the knowledge base:**

```bash
# Fetch latest data from llms.txt sources
./scripts/fetch-duyet-data.sh

# Review and update knowledge files manually
# Then commit with semantic commit:

git add knowledge/
git commit -m "feat(duyetbot): update duyet profile knowledge

- Updated from duyet.net/llms.txt
- Refreshed blog archive from blog.duyet.net

Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>"
```

**When to update:**
- New job/experience → Fetch from cv.duyet.net
- New blog post series → Fetch from blog.duyet.net
- Major project launch → Check GitHub
- Quarterly review → Full refresh from all sources

**See `skills/duyet-knowledge/SKILL.md` for detailed guidance.**

## Skills

- **engineering-discipline** - Focus on craftsmanship, testing, and quality
- **transparency** - Show work, explain reasoning, acknowledge uncertainty
- **task-loop** - Iterative execution with visibility
- **team-coordination** - Spawn and coordinate team agents
- **duyet-knowledge** - Maintain and update @duyet knowledge base

## Commands

- `/duyetbot` - Main command for pragmatic development companion
- `/duyetbot:think` - Deep thinking with visible reasoning
- `/duyetbot:loop` - Iterative execution until task complete
- `/duyetbot:spawn` - Delegate to team agents
- `/duyetbot:orchestrate` - Coordinate parallel workstreams

## MCP Integration

This plugin uses the `duyetbot-mcp` MCP server for:
- Knowledge storage and retrieval
- Memory management
- Prompt templates
- GitHub integration

See `.mcp.json` for MCP server configuration.

## Version History

| Version | Changes |
|---------|---------|
| 1.1.0 | Added duyet knowledge base and fetch scripts |
| 1.0.0 | Initial release with core duyetbot functionality |

---

**Plugin Author**: duyet
**Last Updated**: 2025-01-05
