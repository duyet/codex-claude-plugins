---
description: Review and rewrite content to match @duyet's writing style
argument-hint: "<content|url|file>"
---

# /writing - Writing Style Review

Review and rewrite content to match @duyet's authentic writing style.

## Writing Style Reference

@knowledge/writing-style.md

## Task

$ARGUMENTS

## Process

1. **Analyze Input**
   - If URL: Fetch and extract content
   - If file path: Read the file
   - If text: Use directly

2. **Style Analysis**
   - Compare against @duyet's writing patterns
   - Identify mismatches in tone, structure, language

3. **Rewrite**
   - Apply @duyet's characteristic patterns:
     - Direct but friendly tone
     - First-person perspective ("I", "my team", "our experience")
     - Evidence over opinion (show metrics, benchmarks)
     - Practical over theoretical
     - ASCII diagrams for architecture
     - Humble closings ("I hope this helps", "Let me know")

4. **Output**
   - Show before/after comparison
   - Highlight key changes made
   - Explain why changes match @duyet's style

## Style Checklist

| Aspect | @duyet Pattern | Check |
|--------|----------------|-------|
| Tone | Direct but friendly | ☐ |
| Perspective | First-person ("I", "we") | ☐ |
| Opening | Hook/question or "Recently, I was..." | ☐ |
| Evidence | Metrics, benchmarks, real code | ☐ |
| Visuals | ASCII diagrams, tables | ☐ |
| Closing | Humble, invites feedback | ☐ |
| Honesty | Admits challenges, uncertainty | ☐ |

## Examples

```bash
# Review a blog post draft
/writing Review this post: "Apache Kafka is a distributed..."

# Rewrite content from URL
/writing https://blog.duyet.net/draft/new-post.md

# Review local file
/writing ./drafts/clickhouse-tips.md

# Quick style check
/writing "Here's how to optimize your queries..."
```

## Output Format

```
─── Writing Style Review ─────────────────────

## Analysis
- Tone: [match/mismatch] - [details]
- Structure: [match/mismatch] - [details]
- Evidence: [match/mismatch] - [details]

## Suggested Rewrite

[rewritten content]

## Changes Made
1. [change] - [reason: aligns with @duyet pattern]
2. [change] - [reason: aligns with @duyet pattern]

─── /writing ── complete ─────────────────────
```

## Related

- `/learn` - Learn new information about @duyet
- `/duyetbot` - Main duyetbot command
- `knowledge/writing-style.md` - Full style analysis
