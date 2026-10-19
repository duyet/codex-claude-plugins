# statusline

A configurable Claude Code statusline showing project and branch, model and effort, context usage, prompt-cache hit rate with a TTL countdown, session cost and duration, rate limits, and running MCP servers and agents. Empty sections are hidden.

```bash
/plugin install statusline@duyet-claude-plugins
/statusline:setup
```

Example (detailed preset):

```text
monorepo (master) -> opus-5.5[200k] (medium) -> 23m
██░░░░░░░░ 21% (43k/200k) -> cache 98% (42k/43k) -> 5h: 45% | 7d: 28%
Seq Ctx7
```

## Commands

- `/statusline:setup` picks a preset or custom options and wires the renderer into `~/.claude/settings.json`.
- `/statusline:config` changes layout, sections, style, or preset.
- `/statusline:status` shows the active config and a preview.
- `/statusline:disable` removes the `statusLine` setting.

## Config

Settings live in `~/.claude/statusline.config.json`. Six presets ship in `scripts/templates/`: detailed, balanced, minimal, monitor, developer, and performance. Field reference and troubleshooting are in `skills/statusline-workflow/SKILL.md`.

Context turns yellow at 50%, bold yellow at 70%, and red at 85%. Cache stats show for Claude models only.

## Requirements

Claude Code, Python 3.8 or newer, and git for branch detection.
