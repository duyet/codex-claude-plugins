# Simplify Plugin

Review changed code for reuse, quality, and efficiency, then simplify issues found.

## Installation

```bash
/plugin install simplify@duyet-claude-plugins
```

## Usage

```bash
/simplify:simplify
```

The command inspects the current diff, reviews it from three angles, fixes actionable issues, and summarizes what changed.

## Structure

```
simplify/
├── .claude-plugin/
│   └── plugin.json
├── .codex-plugin/
│   └── plugin.json
├── commands/
│   └── simplify.md
├── skills/
│   └── simplify/
│       └── SKILL.md
└── README.md
```
