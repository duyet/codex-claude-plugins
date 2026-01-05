# Ralph Wiggum Plugin

A self-referential development loop for Claude Code. Run iterative tasks until completion with automatic progress detection and safety controls.

## Concept

The Ralph technique feeds the same prompt to Claude repeatedly in a `while true` loop. Each iteration, Claude sees its previous work in files and git history, enabling continuous refinement until the task completes.

```bash
while true; do
  cat PROMPT.md | claude --continue
done
```

This plugin implements the loop within Claude Code using a stop-hook that intercepts exit attempts and restarts with the same prompt.

## Usage

```bash
# Start a loop
/ralph-loop "Build a REST API with CRUD operations and tests"

# Set iteration limit
/ralph-loop "Refactor auth module" --max-iterations 15

# Define completion criteria
/ralph-loop "Add input validation" --completion-promise "DONE"

# Check status
/status

# Cancel
/cancel-ralph
```

## Completion

The loop stops when any condition is met:

| Condition | Trigger |
|-----------|---------|
| **Promise** | Output `<promise>TEXT</promise>` matching `--completion-promise` |
| **Iterations** | Reach `--max-iterations` limit |
| **Circuit Breaker** | No file changes for 3 iterations or 5 consecutive errors |

## Safety: Circuit Breaker

Prevents runaway loops through stagnation detection:

- **No Progress**: Stops after 3 iterations without file changes
- **Errors**: Stops after 5 consecutive errors in output

## Options

| Flag | Description |
|------|-------------|
| `--max-iterations <n>` | Stop after N iterations |
| `--completion-promise <text>` | Promise phrase to signal completion |
| `--no-circuit-breaker` | Disable stagnation detection |
| `--reset-circuit` | Reset circuit breaker state |

## Prompt Guidelines

Write prompts with clear, verifiable completion criteria:

```markdown
Fix the token refresh bug in auth.ts.

Requirements:
- Token refresh returns valid JWT
- Expired tokens trigger refresh flow
- All auth tests pass

Output <promise>FIXED</promise> when tests pass.
```

## Monitoring

```bash
/status                                  # Quick status check
cat .claude/ralph-loop.local.md          # Loop state
cat .claude/ralph-circuit.local.json     # Circuit breaker state
```

## When to Use

**Good for:**
- Tasks with clear success criteria (tests pass, build succeeds)
- Iterative refinement (debugging, optimization)
- Greenfield implementation with defined requirements

**Not for:**
- Tasks requiring human judgment or design decisions
- One-shot operations
- Production debugging

## Architecture

```
ralph-wiggum/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   ├── ralph-loop.md        # Start loop command
│   ├── status.md            # Check loop status
│   ├── cancel-ralph.md      # Cancel active loop
│   └── help.md              # Plugin documentation
├── hooks/
│   ├── hooks.json           # Hook configuration
│   └── stop-hook.sh         # Main loop interceptor
└── scripts/
    ├── setup-ralph-loop.sh  # Loop initialization
    ├── status.sh            # Status display
    └── cancel-ralph.sh      # Cancellation handler
```

## References

- [ghuntley.com/ralph](https://ghuntley.com/ralph/)
- [Official Anthropic plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)
- [frankbria/ralph-claude-code](https://github.com/frankbria/ralph-claude-code)
