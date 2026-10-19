# Claude Plugins Project

## Install

```bash
/plugin marketplace add duyet/codex-claude-plugins
/plugin install <plugin-name>@duyet-claude-plugins
```

Alternative: `npx skills add duyet/codex-claude-plugins` ([skills.sh](https://skills.sh))

### Grok Build / Grok Bot

```bash
grok plugin marketplace add duyet/codex-claude-plugins
grok plugin install <plugin-name> --trust
```

### Antigravity Installation

For Antigravity CLI, install/symlink a plugin locally for development:

```bash
./scripts/install-antigravity.sh <plugin-name>  # Or 'all' to install all
```

## Plugin Metadata

`marketplace.json` is the only hand-edited manifest. Each entry holds `name`, `displayName`, `description`, `version`, `category`. `python3 scripts/plugins.py sync` generates the rest, and `bash scripts/validate-plugins.sh` fails on drift:

- Claude: `<plugin>/.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`
- Codex: `<plugin>/.codex-plugin/plugin.json`, `.agents/plugins/marketplace.json`
- Cursor: `<plugin>/.cursor-plugin/plugin.json`, `.cursor-plugin/marketplace.json`
- Grok Bot / Grok Build: `<plugin>/.grok-plugin/plugin.json`, `<plugin>/.grok-build-plugin/plugin.json`, `.grok-plugin/marketplace.json`
- Antigravity: `<plugin>/.antigravity-plugin/plugin.json`, only where that directory exists
- README plugin table between the `plugins:start` and `plugins:end` markers
- Plugin logo: `<plugin>/assets/logo.svg`

## Versioning

Follow semantic versioning (semver) for all plugins:

| Change Type               | Version Bump | Example       |
| ------------------------- | ------------ | ------------- |
| Bug fix, docs             | Patch        | 1.0.0 → 1.0.1 |
| New feature, minor change | Minor        | 1.0.0 → 1.1.0 |
| Breaking change           | Major        | 1.0.0 → 2.0.0 |

**When to bump:**

- Adding new commands, skills, or agents → **Minor**
- Modifying existing behavior → **Minor** (or Major if breaking)
- Updating documentation only → **Patch**
- Bug fixes → **Patch**

Bump the version in `marketplace.json`, then run `python3 scripts/plugins.py sync`. Removing or renaming a skill or command users invoke is a major bump.

## Plugin Structure

```text
plugin-name/
├── .claude-plugin/ .codex-plugin/ .cursor-plugin/ .grok-plugin/ .grok-build-plugin/   # generated
├── assets/logo.svg
├── skills/<name>/SKILL.md   # name frontmatter must equal <name>
├── commands/*.md            # description frontmatter required
├── agents/*.md              # description frontmatter required
├── hooks/hooks.json
├── .mcp.json
└── README.md                # short, with the /plugin install line
```

Links inside a plugin must stay inside it. A plugin installs alone, so never link `../other-plugin/`.

## No Personal / Environment-Specific Information

Plugins in this repo are **published and shared**. Never bake personal or
machine-specific information into any plugin file (manifests, hooks, scripts,
skills, commands, configs, docs, examples).

**Never hardcode:**

- Absolute home paths (`/Users/<you>/…`) — use `$HOME`, `~`, `${CLAUDE_PLUGIN_ROOT}`, or `$PWD`.
- Personal secret-file conventions (e.g. `~/.secret`) — read secrets from documented env vars; allow an optional, user-set key-file path.
- Real project, client, host, or repo names — use neutral placeholders (`demo-project`, `/path/to/project`).
- Account-bound resources (private/professional voice IDs, API keys, tokens, account ids, emails).

**Defaults must be generic.** Ship neutral, English-first defaults that work for
any user. Put personal preferences (language, voice, key location, custom
wording) in the user's own config under `~/.config/<plugin>/` — outside the repo,
never committed.

Author/owner metadata (`author`, marketplace `owner`) is allowed — that is
legitimate attribution, not environment-specific leakage. Shipping additional
**language presets** (e.g. a `vi` template set) is a feature, not personal info.

Before committing a plugin, scan for leaks:
`grep -rniE "/Users/|~/\.secret|<your-name>|<real-project-names>" <plugin>/`

## Commit Convention

Use semantic commits with plugin scope:

```text
feat(plugin-name): add new feature
fix(plugin-name): fix bug
docs(plugin-name): update documentation
```

Co-author: `Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>`
