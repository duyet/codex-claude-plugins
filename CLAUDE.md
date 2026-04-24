# Claude Plugins Project

## Install

```bash
/plugin marketplace add duyet/claude-plugins
/plugin install <plugin-name>@duyet-claude-plugins
```

Codex plugin metadata is maintained beside Claude metadata in each plugin:

- Claude manifest: `.claude-plugin/plugin.json`
- Codex manifest: `.codex-plugin/plugin.json`
- Claude marketplace: `marketplace.json` and `.claude-plugin/marketplace.json`
- Codex marketplace: `.agents/plugins/marketplace.json`

Alternative: `npx skills add duyet/claude-plugins` ([skills.sh](https://skills.sh))

## Versioning

Follow semantic versioning (semver) for all plugins:

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Bug fix, docs | Patch | 1.0.0 → 1.0.1 |
| New feature, minor change | Minor | 1.0.0 → 1.1.0 |
| Breaking change | Major | 1.0.0 → 2.0.0 |

**When to bump:**
- Adding new commands, skills, or agents → **Minor**
- Modifying existing behavior → **Minor** (or Major if breaking)
- Updating documentation only → **Patch**
- Bug fixes → **Patch**

Always update `plugin.json` version when making changes.

## Plugin Structure

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Manifest (name, version, description)
├── .codex-plugin/
│   └── plugin.json          # Codex manifest and interface metadata
├── agents/                  # Sub-agent definitions
├── commands/                # Slash commands
├── skills/                  # Reusable knowledge/procedures
├── hooks/                   # Hook configurations
└── README.md                # Documentation
```

When changing plugin metadata, keep Claude and Codex manifests in sync and run `bash scripts/validate-plugins.sh`.

## Commit Convention

Use semantic commits with plugin scope:

```
feat(plugin-name): add new feature
fix(plugin-name): fix bug
docs(plugin-name): update documentation
```

Co-author: `Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>`
