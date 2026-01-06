# Docs Generator Plugin

Automatically generate and maintain plugin documentation for the claude-plugins marketplace.

## Installation

```bash
/plugin install docs-generator@duyet-claude-plugins
```

## What It Does

Generates documentation from plugin metadata:

1. **Root README.md** - Plugin overview, quick install, at-a-glance table, detailed descriptions
2. **Plugin CLAUDE.md** - Versioning guide, structure, components for each plugin

## How It Works

### Automatic Generation (Stop Hook)

When you finish a Claude session and have made implementation changes:

1. Stop hook detects changes via `git diff`
2. Skips doc-only changes (README.md, CLAUDE.md) to avoid infinite loops
3. Regenerates all documentation from `marketplace.json` and plugin directories
4. Non-blocking - always allows normal exit

### Manual Generation

Use the `/generate-docs` command or run the script directly:

```bash
./docs-generator/scripts/generate-docs.sh
```

## Configuration

Environment variables:

- `DOCS_GENERATOR_ENABLED=1` - Enable auto-generation (default: enabled)
- `DOCS_GENERATOR_VERBOSE=1` - Enable verbose logging

## Architecture

```
docs-generator/
├── hooks/
│   ├── hooks.json           # Stop hook configuration
│   └── stop-hook.sh         # Entry point
├── scripts/
│   ├── generate-docs.sh     # Main orchestrator
│   └── lib/
│       ├── plugin-scanner.sh      # Read marketplace.json
│       ├── type-detector.sh       # Classify plugins
│       ├── feature-extractor.sh   # Extract components
│       └── emoji-mapper.sh        # Assign emojis
└── commands/
    └── generate-docs.md     # Manual trigger
```

## Changelog

### [1.0.0] - Initial Release

- Stop hook for automatic documentation generation
- Root README.md generation from marketplace.json
- Plugin CLAUDE.md generation from plugin.json
- Type detection (Agent/Skill/Hook/Command/Config)
- Feature extraction (commands/agents/skills)
- Emoji assignment by keyword
