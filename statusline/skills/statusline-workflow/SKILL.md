---
name: statusline-workflow
description: Configure, preview, troubleshoot, or disable the Claude Code statusline plugin. Use for statusline setup, layout or section changes, applying a preset, or a statusline that renders wrong.
---

# Statusline

The renderer is `scripts/statusline.py` in this plugin. Claude Code runs it as the `statusLine` command and pipes session JSON to stdin. It reads `~/.claude/statusline.config.json` and falls back to the detailed three-line layout when the file is missing.

Resolve the plugin directory from this skill's location (`${CLAUDE_PLUGIN_ROOT}` in Claude Code). Never hard-code a path.

## Workflow

1. Read the existing config and the `statusLine` entry in `~/.claude/settings.json` before changing anything.
2. Write the config. For a preset, copy `scripts/templates/<name>.json` to `~/.claude/statusline.config.json`. For custom, build it from the fields below and keep unchanged values.
3. Point `statusLine` at `~/.claude/statusline/statusline.py`. The plugin's SessionStart hook copies the renderer there on every session, so the path survives plugin updates. On first setup, copy it there yourself.

   ```json
   {
     "statusLine": {
       "type": "command",
       "command": "python3 ~/.claude/statusline/statusline.py"
     }
   }
   ```

4. Preview by piping sample JSON to the renderer.

   ```bash
   echo '{"workspace":{"current_dir":"'"$PWD"'"},"model":{"id":"claude-opus-5-5"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":43000}},"effort":{"level":"medium"},"rate_limits":{"five_hour":{"used_percentage":45},"seven_day":{"used_percentage":28}}}' | python3 ~/.claude/statusline/statusline.py
   ```

5. To troubleshoot, run the same command with real-looking JSON and check provider detection, the rate-limit fields, and that empty sections are hidden. `bash scripts/test-statusline.sh` runs the regression suite.

To disable, remove the `statusLine` key from `~/.claude/settings.json`.

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
