# Contributing

Thanks for your interest in contributing to the Claude Plugins Marketplace!

## Quick Start

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-new-plugin`
3. Make your changes
4. Push to your fork: `git push origin feature/my-new-plugin`
5. Open a Pull Request

## Plugin Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest (name, version, description)
├── README.md                # Plugin documentation
├── CLAUDE.md               # Claude-specific instructions (optional, for skills/agents)
├── agents/                  # Agent definitions (optional)
├── commands/                # Slash commands (optional)
├── skills/                  # Reusable knowledge (optional)
└── hooks/hooks.json          # Lifecycle hooks (optional)
```

## Creating a New Plugin

### 1. Plugin Manifest (.claude-plugin/plugin.json)

```json
{
  "name": "my-plugin",
  "description": "A brief description of what this plugin does",
  "version": "1.0.0",
  "author": {
    "name": "your-username"
  }
}
```

### 2. Documentation (README.md)

Required sections:
- Description of what the plugin does
- Installation instructions
- Usage examples
- Configuration options (if any)
- Versioning guidelines (if applicable)

### 3. Claude Instructions (CLAUDE.md)

Required for skills and agents:
- How Claude should use the plugin
- When to invoke it
- Expected inputs and outputs

### 4. Update Marketplace

Add your plugin to `marketplace.json`:

```json
{
  "name": "my-plugin",
  "id": "my-plugin@duyet-claude-plugins",
  "description": "...",
  "version": "1.0.0",
  "type": "skill|command|hook",
  "category": "your-category"
}
```

### 5. Update Main README

Add your plugin to the main README.md table:

| Plugin | Type | Description |
|--------|------|-------------|
| [🔧 my-plugin](./my-plugin/) | Type | Description |

## Development Guidelines

### Code Quality

- Write clear, well-documented code
- Follow existing patterns in the codebase
- Keep changes focused and atomic

### Versioning

Follow [Semantic Versioning](https://semver.org/):
- **Patch** (1.0.0 → 1.0.1): Bug fixes, documentation
- **Minor** (1.0.0 → 1.1.0): New features, non-breaking changes
- **Major** (1.0.0 → 2.0.0): Breaking changes

Update plugin.json version on every change.

### Commits

Use conventional commits with plugin scope:

```bash
feat(my-plugin): add new feature
fix(my-plugin): fix bug
docs(my-plugin): update documentation
test(my-plugin): add tests
refactor(my-plugin): refactor code
```

### Testing

- Test your plugin thoroughly before submitting
- Include usage examples in README
- Consider edge cases and error handling

## Pull Request Process

1. **Title**: Use conventional commit format (e.g., `feat(my-plugin): add X`)
2. **Description**: Explain what and why
3. **Link issues**: `Fixes #123` if applicable
4. **Co-author**: Add if using duyetbot: `Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>`

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Getting Help

- Check [existing issues](https://github.com/duyet/claude-plugins/issues)
- Use [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) for new ideas
- Use [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) for issues
