# Claude, Codex, Cursor, and Grok plugins

[![License](https://img.shields.io/github/license/duyet/codex-claude-plugins?style=flat-square)](LICENSE)

Agent workflows, git automation, and developer skills packaged once for Claude Code, Codex, Cursor, Grok Build, Grok Bot, and the [skills.sh](https://skills.sh) CLI.

## Install

Claude Code:

```bash
/plugin marketplace add duyet/codex-claude-plugins
/plugin install <plugin-name>@duyet-claude-plugins
```

Cursor: add `duyet/codex-claude-plugins` as a plugin marketplace, then install from the `duyet-claude-plugins` catalog. The index is `.cursor-plugin/marketplace.json`.

Codex: clone the repo and add the local marketplace at `.agents/plugins/marketplace.json`.

Grok Build and Grok Bot:

```bash
grok plugin marketplace add duyet/codex-claude-plugins
grok plugin install <plugin-name> --trust
```

Any agent that supports skills.sh:

```bash
npx skills add duyet/codex-claude-plugins
```

## Plugins

<!-- plugins:start -->

| Plugin                                      | Category     | Description                                                                                                                                                                                                                                           |
| ------------------------------------------- | ------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [team-agents](./team-agents/)               | Agents       | Leader, senior, and junior engineer agents plus React, TypeScript, backend, and quality skills for parallel work.                                                                                                                                     |
| [commit](./commit/)                         | Git          | Semantic commits, with optional push or a PR from templates.                                                                                                                                                                                          |
| [frontend-design](./frontend-design/)       | Design       | Distinctive, production-grade frontend design that avoids generic AI aesthetics.                                                                                                                                                                      |
| [interview](./interview/)                   | Productivity | Interview the user to clarify requirements, then write a spec.                                                                                                                                                                                        |
| [statusline](./statusline/)                 | UI           | Configurable status bar showing context usage, API rate limits, git branch, and active tools                                                                                                                                                          |
| [orchestration](./orchestration/)           | Agents       | Orchestrator skill for managing parallel agent workstreams                                                                                                                                                                                            |
| [github](./github/)                         | Git          | Drive PRs to merge-ready with gh: fix CI and review-bot feedback, plus bulk merge, close, and label.                                                                                                                                                  |
| [fix](./fix/)                               | Productivity | Fix failing tests, lint, and CI, then commit and push or open or update a PR.                                                                                                                                                                         |
| [clickhouse](./clickhouse/)                 | Database     | ClickHouse review rules for schemas, queries, and inserts, with references for debugging and monitoring queries.                                                                                                                                      |
| [prompt-engineering](./prompt-engineering/) | Productivity | Prompting guidance and per-model deltas for Claude, Gemini, and Grok.                                                                                                                                                                                 |
| [chmonitor](./chmonitor/)                   | Monitoring   | Read-only ClickHouse monitoring and advice through the chmonitor MCP server, with pointers to its docs and codebase.                                                                                                                                  |
| [unsloth-training](./unsloth-training/)     | ML           | Fine-tune LLMs with Unsloth using GRPO or SFT: rewards, datasets, FP8, vision, MLX, export, mobile.                                                                                                                                                   |
| [good-html](./good-html/)                   | Design       | Dense, interactive, self-contained HTML artifacts and reviews.                                                                                                                                                                                        |
| [anyrouter](./anyrouter/)                   | AI           | Wire AnyRouter, an OpenAI-compatible LLM gateway, into projects and agents, with migration help and an MCP server.                                                                                                                                    |
| [sag-notify](./sag-notify/)                 | UI           | Spoken voice notifications via sag (ElevenLabs TTS): skill-driven, Claude calls sag directly to speak a short alert just before it asks you something and a one-line summary when work finishes, naming the project. Configurable voice and language. |
| [build-macos-apps](./build-macos-apps/)     | Development  | Build, debug, instrument, and implement macOS apps with SwiftUI and AppKit guidance, codesigning, packaging, and telemetry workflows.                                                                                                                 |
| [build-ios-apps](./build-ios-apps/)         | Development  | Build, debug, and profile iOS apps with SwiftUI, Simulator, App Intents, and on-device AI.                                                                                                                                                            |
| [agent-loop](./agent-loop/)                 | Automation   | Unattended repo maintenance that triages issues and PRs, dispatches fixes to parallel subagents, and reports results each scheduled cycle.                                                                                                            |
| [kb](./kb/)                                 | Productivity | Knowledge base maintenance skills. Initialize a shared-brain kb, then consolidate, dedupe, prune, refresh, and forget notes in a markdown KB.                                                                                                         |
| [okf](./okf/)                               | Productivity | Open Knowledge Format (OKF) tooling. Author, initialize, validate, render, and refactor knowledge into vendor-neutral OKF v0.1 bundles: markdown files with YAML frontmatter.                                                                         |
| [command-code](./command-code/)             | Development  | Dispatch the Command Code CLI (`cmd`) as headless sub-agents across isolated git worktrees.                                                                                                                                                           |

<!-- plugins:end -->

Each plugin folder has its own README with commands and skills.

## Contributing

`marketplace.json` is the only manifest you edit by hand. It holds each plugin's name, display name, description, version, and category. Everything else is generated:

```bash
python3 scripts/plugins.py sync    # write every harness manifest and the table above
bash scripts/validate-plugins.sh   # fail on drift, broken skill links, missing frontmatter
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for commit and versioning rules.

## License

MIT
