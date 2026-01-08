---
allowed-tools: [Read, Bash, Glob, Grep, TodoWrite, Edit, Write, Task]
description: "Fix issues/tests, commit changes, and push to remote"
---

# /fix:and-push - Fix, Commit, and Push

## Purpose

Intelligently detect and fix issues (tests, linting, type errors), commit the changes, and push to the remote branch.

## Usage

```
/fix:and-push
```

```
/fix:and-push

<error message or test names>
<user note or context>
```

## Issue Detection

The command automatically detects the project type and runs appropriate checks:

| Project Type | Detection | Test Command |
|--------------|-----------|--------------|
| Python | `pyproject.toml`, `setup.py`, `requirements.txt` | `pytest`, `python -m pytest` |
| Node/TypeScript | `package.json` | `npm test`, `npm run lint`, `npm run type-check` |
| Rust | `Cargo.toml` | `cargo test`, `cargo clippy` |
| Go | `go.mod` | `go test ./...` |

## Execution Flow

### Phase 1: Discovery
1. Detect project type from config files
2. Identify test framework and commands
3. Parse provided error messages (if any)
4. Create todo list for tracking

### Phase 2: Analysis
1. Run tests/checks to identify failures
2. Categorize issues by type:
   - Unit test failures
   - Integration test failures
   - Linting errors
   - Type errors
   - Build errors
3. Prioritize fixes (dependencies first)

### Phase 3: Fix
1. For simple issues (1-2 files): Fix directly
2. For complex issues (3+ files or multiple domains):
   - Spawn senior-engineer agents in parallel
   - Each agent handles a specific issue domain
3. After each fix:
   - Re-run affected tests locally
   - Verify fix doesn't break other tests

### Phase 4: Commit & Push
1. Stage all changed files
2. Create semantic commit message:
   ```
   fix(scope): clear description of what was fixed

   Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>
   ```
3. Push to current branch

## Parallel Execution Strategy

For complex multi-file fixes:

```
Main Agent (Coordinator)
├── Senior Agent 1: Python test fixes
├── Senior Agent 2: TypeScript type errors
├── Senior Agent 3: Linting issues
└── Main Agent: Monitors, integrates, commits
```

## Notes

- **Mock external dependencies**: Use mocks for databases, external APIs unless explicitly testing integration
- **Logic over green tests**: Think about whether the test logic makes sense, not just making tests pass
- **Document recurring issues**: If a pattern emerges, consider adding notes to local CLAUDE.md
- **Incremental commits**: For large fixes, commit working states incrementally
- **Never auto-merge**: This command only pushes; merging requires separate action

## Error Recovery

If fixes fail after 3 attempts:
1. Document what was tried
2. Provide detailed error analysis
3. Suggest manual intervention steps
4. Do NOT continue pushing broken code
