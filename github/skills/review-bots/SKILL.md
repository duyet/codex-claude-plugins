---
name: review-bots
description: Use when a PR has comments from AI review bots (CodeRabbit, Sourcery, Gemini Code Assist) that need triage.
---

# Review bots

Bot logins: `coderabbitai[bot]`, `sourcery-ai[bot]`, `gemini-code-assist[bot]`. Fetch them with `gh api` on the PR's `pulls/{n}/comments`, `issues/{n}/comments`, and `pulls/{n}/reviews`.

- Inline comments are actionable. Top-level summaries and walkthroughs are not.
- Bots file real bugs and also noise. Judge each comment on its merits. Fix bugs, security, and correctness first. Apply style only if it matches project conventions. Reply with a reason when skipping.
- Take `suggestion` blocks as proposals, not patches. Check them against the surrounding code.
- Bots cannot be resolved through the API. Push the fix and they re-review.
