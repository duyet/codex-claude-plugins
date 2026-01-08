# Fix Plugin

Intelligent issue detection and resolution with Git workflow integration.

## Commands

| Command | Description |
|---------|-------------|
| `/fix:and-push` | Fix issues, commit, and push to remote |
| `/fix:and-update-pr` | Fix issues and update an existing PR |
| `/fix:and-create-pr` | Fix issues and create a new PR |

## Features

- **Auto-detection**: Automatically detects project type (Python, Node, Rust, Go)
- **Smart fixing**: Analyzes errors and applies appropriate fixes
- **Parallel execution**: Spawns agents for complex multi-file issues
- **Git integration**: Handles commits and pushes with semantic messages
- **PR management**: Creates and updates pull requests via GitHub CLI

## Usage

### Fix and Push

```bash
# Fix all failing tests and push
/fix:and-push

# Fix specific issues
/fix:and-push

pytest test_auth.py is failing with assertion error
```

### Update Existing PR

```bash
# Fix CI failures on current branch's PR
/fix:and-update-pr

# Fix specific PR by number
/fix:and-update-pr 123
```

### Create New PR

```bash
# Fix issues and create PR to default branch
/fix:and-create-pr

# With custom title
/fix:and-create-pr

feat: add user authentication
```

## Supported Project Types

| Type | Detection | Test Commands |
|------|-----------|---------------|
| Python | `pyproject.toml`, `setup.py` | pytest, unittest, ruff, mypy |
| Node/TS | `package.json` | jest, vitest, eslint, tsc |
| Rust | `Cargo.toml` | cargo test, clippy |
| Go | `go.mod` | go test, golint |

## Prerequisites

- GitHub CLI (`gh`) installed and authenticated
- Git configured with push access
- Project-specific test tools installed

## Safety Features

- Maximum 3 fix attempts per issue
- Local testing before pushing
- Never force pushes
- Stops on repeated failures
- Preserves existing PR metadata

## Version

1.0.0
