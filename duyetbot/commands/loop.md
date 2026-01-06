---
description: Duyetbot loop - iterative execution until task completion with autonomous overnight capability
argument-hint: "TASK [--max N] [--promise TEXT]"
---

# Duyetbot Loop

Execute iteratively until complete: `$ARGUMENTS`

**Ralph Integration**: This command activates Ralph Wiggum loop for autonomous execution, allowing tasks to continue overnight without human intervention.

```!
"${CLAUDE_PLUGIN_ROOT}/../ralph-wiggum/scripts/setup-ralph-loop.sh" $ARGUMENTS
```

## Loop Protocol

```
┌─────────────┐
│ UNDERSTAND  │ Current state, goal
└──────┬──────┘
       ▼
┌─────────────┐
│    PLAN     │ Single next action
└──────┬──────┘
       ▼
┌─────────────┐
│   EXECUTE   │ One change only
└──────┬──────┘
       ▼
┌─────────────┐
│   VERIFY    │ Validate result
└──────┬──────┘
       ▼
   Complete? ──NO──► Loop back
       │
      YES
       ▼
     DONE
```

## Each Iteration

```markdown
### Iteration N

**State**: Done / Pending
**Action**: What this iteration does

**Execution**:
[1] Tool → Result

**Verify**:
- [ ] Works as expected
- [ ] Tests pass

**Next**: What follows
```

## Progress Tracking

```
[x] Step 1: Done (iter 1)
[x] Step 2: Done (iter 2)
[ ] Step 3: Current (iter 3)
[ ] Step 4: Pending
```

## Stop Conditions

- **Completion promise**: Output `<promise>TEXT</promise>` matching `--promise`
- **Max iterations**: Reach `--max N` limit
- **Circuit breaker**: 3 iterations without file changes OR 5 consecutive errors
- **Manual**: `/cancel-ralph` to stop

## Usage

```bash
# Basic autonomous loop
/duyetbot:loop Implement user authentication

# With completion promise (recommended)
/duyetbot:loop Fix the bug --promise TESTS_PASS

# Max iterations for overnight tasks
/duyetbot:loop Refactor database --max 50 --promise REFACTOR_COMPLETE
```

## Output

End each iteration:
```
─── duyetbot ── iteration N ─────
```

Final (with promise):
```
─── duyetbot ── complete (N iterations) ─────
<promise>TASK_COMPLETE</promise>
```

## Monitoring

```bash
# Check loop status
/status

# View circuit breaker state
cat .claude/ralph-circuit.local.json

# Cancel loop
/cancel-ralph
```
