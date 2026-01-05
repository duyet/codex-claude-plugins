---
description: "Explain Ralph Wiggum technique and available commands"
allowed-tools: []
---

# Ralph Wiggum Plugin Help

Explain the following to the user:

## What is Ralph?

A self-referential development loop. The same prompt feeds to Claude repeatedly in a `while true` loop. Each iteration, Claude sees previous work in files and git history, enabling continuous refinement until completion.

```bash
while true; do
  cat PROMPT.md | claude --continue
done
```

The stop-hook intercepts exit attempts and feeds the same prompt back.

## Commands

### /ralph-loop

Start a loop in the current session.

```
/ralph-loop "Build a REST API" --max-iterations 20
/ralph-loop "Fix auth bug" --completion-promise "FIXED"
```

**Options:**

| Flag | Description |
|------|-------------|
| `--max-iterations <n>` | Stop after N iterations |
| `--completion-promise <text>` | Promise phrase to signal completion |
| `--no-circuit-breaker` | Disable stagnation detection |
| `--reset-circuit` | Reset circuit breaker state |

### /status

Show current loop status.

```
/status
```

### /cancel-ralph

Cancel the active loop.

```
/cancel-ralph
```

## Stop Conditions

The loop stops when any condition is met:

1. `--max-iterations` reached
2. `<promise>TEXT</promise>` matches `--completion-promise`
3. Circuit breaker opens (stagnation/errors)

## Safety: Circuit Breaker

Prevents runaway loops:
- No file changes for 3+ iterations → stops
- 5+ consecutive errors in output → stops

## Completion Promises

Signal completion by outputting:

```
<promise>TASK COMPLETE</promise>
```

The text must exactly match `--completion-promise`.

## Monitoring

```bash
/status                                  # Show status
cat .claude/ralph-loop.local.md          # Loop state
cat .claude/ralph-circuit.local.json     # Circuit breaker
```

## Example

```
/ralph-loop "Fix token refresh in auth.ts. Output <promise>FIXED</promise> when tests pass." --completion-promise "FIXED" --max-iterations 10
```

Claude will:
1. Work on the fix
2. Run tests
3. If tests fail, iterate and improve
4. Output `<promise>FIXED</promise>` when all tests pass
5. Loop stops

## References

- [ghuntley.com/ralph](https://ghuntley.com/ralph/)
- [Official plugin](https://github.com/anthropics/claude-code/tree/main/plugins/ralph-wiggum)
