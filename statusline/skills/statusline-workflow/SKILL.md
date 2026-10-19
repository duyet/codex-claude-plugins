---
name: statusline-workflow
description: Configure, preview, troubleshoot, or disable the Claude Code statusline plugin. Use for statusline setup, layout or section changes, applying a preset, or a statusline that renders wrong.
---

# Statusline

The renderer is `scripts/statusline.py` in this plugin. Claude Code runs it as the `statusLine` command and pipes session JSON to stdin. It reads `~/.claude/statusline.config.json` and falls back to the detailed three-line layout when the file is missing.

Resolve the plugin directory from this skill's location (`${CLAUDE_PLUGIN_ROOT}` in Claude Code). Never hard-code a path.

## Workflow

Read the existing config and the `statusLine` entry in `~/.claude/settings.json` first. For a preset, copy `scripts/templates/<name>.json` to `~/.claude/statusline.config.json`. For custom, build from the fields below and keep unchanged values.

Point `statusLine` at `~/.claude/statusline/statusline.py` (`{"type": "command", "command": "python3 ~/.claude/statusline/statusline.py"}`). The SessionStart hook copies the renderer there each session so the path survives plugin updates. On first setup, copy it yourself.

Preview by piping sample session JSON to the renderer. `bash scripts/test-statusline.sh` runs the regression suite. To disable, remove the `statusLine` key.

## Config fields

| Field                                                                                                                                           | Values                              | Default        |
| ----------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------- | -------------- |
| `line_format`                                                                                                                                   | `"1"`, `"2"`, `"3"`                 | `"3"`          |
| `separator`                                                                                                                                     | `arrow`, `pipe`, `dot`, `slash`     | `arrow`        |
| `context_style`                                                                                                                                 | `progress_bar`, `tokens`, `compact` | `progress_bar` |
| `icon_style`                                                                                                                                    | `emoji`, `unicode`, `minimal`       | `emoji`        |
| `cache_ttl`                                                                                                                                     | `"5m"`, `"1h"`                      | `"5m"`         |
| `show_context`, `show_rate_limits`, `show_git_branch`, `show_tools`, `show_agents`, `show_cache`, `show_session`, `show_reasoning`, `show_cost` | boolean                             | `true`         |

Cache stats show for Claude models only, because other providers report proxy values that are not real cache metrics. Empty sections are hidden. Rate limits read `n/a` when the provider sends none.

## Presets

| Preset      | Lines | Icons   | Focus                           |
| ----------- | ----- | ------- | ------------------------------- |
| detailed    | 3     | emoji   | Everything (default)            |
| balanced    | 2     | unicode | Key metrics                     |
| minimal     | 1     | none    | Essentials                      |
| monitor     | 2     | emoji   | Rate limits and cache, no tools |
| developer   | 2     | unicode | Tools, agents, git              |
| performance | 3     | emoji   | Cache and context               |
