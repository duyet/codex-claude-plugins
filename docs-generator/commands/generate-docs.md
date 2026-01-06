---
description: Manually trigger documentation generation for all plugins
---

# Generate Documentation

Manually regenerate all plugin documentation (README.md and CLAUDE.md files).

This command is useful when you want to update documentation without making any code changes, or when the auto-generation hook is disabled.

## Usage

Run the generation script directly:

```bash
./docs-generator/scripts/generate-docs.sh
```

Or from any directory:

```bash
/path/to/claude-plugins/docs-generator/scripts/generate-docs.sh /path/to/claude-plugins
```

## What It Generates

1. **Root README.md** - At-a-glance table, plugin details, install commands
2. **Plugin CLAUDE.md** - Versioning guide, structure, components for each plugin

## Configuration

Set environment variables to control behavior:

- `DOCS_GENERATOR_ENABLED=1` - Enable auto-generation (default: 1)
- `DOCS_GENERATOR_VERBOSE=1` - Enable verbose output
