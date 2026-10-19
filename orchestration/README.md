# orchestration

A skill for coordinating parallel subagents. It splits work into independent lanes, spawns them in one wave with a standard worker preamble, verifies each result, and synthesizes one answer. Works in Claude Code, Codex, and Cursor.

## Install

```bash
/plugin install orchestration@duyet-claude-plugins
```

## What ships

- `orchestration` skill covering decomposition, fan-out, the worker preamble, the verify loop, and synthesis.

The team-agents plugin is optional. Its `leader`, `senior-engineer`, and `junior-engineer` agents fit the worker roles, but any general-purpose subagent works.
