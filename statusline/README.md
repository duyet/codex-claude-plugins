# statusline

Configurable Claude Code statusline: project and branch, model and effort, context, cache hit rate, cost, rate limits, MCP servers and agents. Empty sections are hidden.

Install: `/plugin install statusline@duyet-claude-plugins`, then `/statusline:setup`.

- `/statusline:setup`, `/statusline:config`, `/statusline:status`, `/statusline:disable`.
- Config: `~/.claude/statusline.config.json`. Presets in `scripts/templates/`. Field reference in `skills/statusline-workflow/SKILL.md`.
- Requires Claude Code, Python 3.8+, and git.
