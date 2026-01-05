---
description: Learn about @duyet and update knowledge base
---

# /learn - Learn About @duyet

Learn new information about Duyet Le and add it to the knowledge base.

## Usage

```
/learn <url|topic|question>
```

## Examples

```bash
# Learn from a specific URL
/learn https://blog.duyet.net/2024/11/clickhouse-rust-udf.html

# Learn about a topic
/learn ClickHouse MergeTree engines

# Answer a question and learn
/learn What is Duyet's experience with Rust?
```

## What It Does

1. **Fetches content** from the provided URL or searches existing knowledge
2. **Extracts key information** (tech stack, decisions, outcomes)
3. **Updates knowledge base** with new findings
4. **Creates commit** with semantic commit message
5. **Pushes to remote** repository automatically

## Output Format

```
[1] Fetched: <url>
[2] Extracted: <key points>
[3] Update location: knowledge/topics/<topic>/<file>.md
[4] Commit: feat(duyetbot): add knowledge about <topic>
[5] Pushed: origin/<branch>

─── /learn ── complete ─────
```

## Knowledge Sources

| Source | URL | Type |
|--------|-----|------|
| Profile | https://duyet.net/llms.txt | Profile |
| Resume | https://cv.duyet.net/llms.txt | CV |
| Blog | https://blog.duyet.net/llms.txt | Posts |
| GitHub | https://github.com/duyet | Repos |
| Twitter | https://x.com/_duyet | Thoughts |

## Related Commands

- `/duyetbot` - Main duyetbot command
- `/duyetbot:think` - Deep thinking about @duyet topics

## See Also

- `skills/duyet-knowledge/SKILL.md` - Knowledge management skill
- `knowledge/structure.md` - Knowledge organization
- `knowledge/writing-style.md` - Writing patterns
