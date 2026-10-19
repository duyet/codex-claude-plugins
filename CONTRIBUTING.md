# Contributing

## Add or change a plugin

1. Create `<plugin>/` with any of `skills/<name>/SKILL.md`, `commands/*.md`, `agents/*.md`, `hooks/hooks.json`, `.mcp.json`, plus `assets/logo.svg` and a short `README.md`.
2. Add or edit its entry in `marketplace.json`: `name`, `displayName`, `description`, `version`, `category`.
3. Run `python3 scripts/plugins.py sync`. It writes the Claude, Codex, Cursor, Grok, Grok Build, and Antigravity manifests, every harness marketplace, and the README plugin table. Never edit those files by hand.
4. Run `bash scripts/validate-plugins.sh`. It fails on manifest drift, skills without matching `name` frontmatter, commands or agents without `description`, broken relative links, and em dashes.

## Writing skills

- Keep only prose that changes the agent's decision. Cut what a strong model already knows.
- One home per idea. A command that repeats a skill should point at the skill by path.
- Write harness-neutral steps that work in Claude Code, Codex, and Cursor.
- No personal paths, hosts, emails, or account ids. See `CLAUDE.md`.

## Versioning

Semver per plugin, set in `marketplace.json`. Patch for docs and fixes, minor for new or changed behavior, major when a command or skill users invoke is removed or renamed.

## Pull requests

Use semantic titles with the plugin as scope, for example `feat(github): add bulk label`. Explain what changed and why.

## License

Contributions are licensed under MIT.
