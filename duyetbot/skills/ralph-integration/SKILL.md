# Ralph Integration Skill

Enables autonomous overnight task execution through Ralph Wiggum loop integration.

**Note**: Duyetbot includes its own copies of Ralph Wiggum scripts for reliable operation. The ralph-loop-setup.sh and ralph-stop-hook.sh are bundled with duyetbot.

## Overview

Ralph Wiggum loop provides automated iteration management:
- **Stop-hook interception**: Automatically feeds prompt back on exit
- **Circuit breaker**: Detects stagnation (no progress) and errors
- **Completion promises**: Clean completion detection via `<promise>TAG</promise>`
- **Overnight execution**: Tasks continue while human is asleep

## When to Activate Ralph Loop

**Autonomous execution is appropriate when:**

1. **Clear completion criteria** - Tests pass, build succeeds, feature works end-to-end
2. **Iterative refinement needed** - Debugging, optimization, multi-step implementation
3. **3+ implementation steps** - Single-step tasks don't need automation
4. **Well-scoped task** - Clear boundaries, no ambiguous requirements

**Do NOT use for:**
- Single-line fixes or simple edits
- Tasks requiring human creativity/decisions
- Exploratory work without clear success criteria
- Quick prototyping (< 5 minutes expected)

## Activation Protocol

### Via /loop Command

```bash
# Basic activation (unlimited iterations)
/duyetbot:loop Implement user authentication

# With completion promise (RECOMMENDED)
/duyetbot:loop Fix the bug --promise TESTS_PASS

# Max iterations for safety
/duyetbot:loop Refactor database --max 50 --promise REFACTOR_COMPLETE
```

### Manual Activation

```bash
# Direct Ralph invocation
/ralph-loop "Build REST API" --completion-promise API_WORKS --max-iterations 30
```

## Completion Promise Pattern

**Always specify a completion promise for reliable overnight execution:**

```markdown
Task: "Implement user authentication"
Promise: <promise>AUTH_TESTS_PASS</promise>

Iteration 1: Design + implement → Verify: npm test → FAILED
Iteration 2: Fix bugs → Verify: npm test → PASSED
Output: <promise>AUTH_TESTS_PASS</promise> → Loop exits cleanly
```

**Good promises:**
- `TESTS_PASS` - Tests succeed
- `BUILD_SUCCESS` - Build completes without errors
- `FEATURE_COMPLETE` - End-to-end functionality works
- `BUG_FIXED` - Specific bug no longer occurs

**Bad promises:**
- `DONE` - Too vague, might trigger early
- `OK` - Common word, risk of false positive
- Empty/null - No defined completion

## Circuit Breaker

**Automatic safety mechanisms:**

| Condition | Threshold | Action |
|-----------|-----------|--------|
| No file changes | 3 iterations | Stop loop |
| Consecutive errors | 5 iterations | Stop loop |
| Max iterations | Per `--max` flag | Stop loop |

**Monitoring circuit state:**
```bash
cat .claude/ralph-circuit.local.json
# Output: {"no_progress": 1, "errors": 0, "last_hash": "..."}
```

**Reset if needed:**
```bash
/duyetbot:loop Continue task --reset-circuit
```

## Overnight Execution Workflow

### Before Sleep

1. **Ensure task is well-scoped**: Clear requirements, known success criteria
2. **Set completion promise**: Specific tag indicating done state
3. **Set max iterations**: Prevent infinite loops (e.g., `--max 100`)
4. **Verify circuit breaker ON**: Default enabled, catches stagnation
5. **Test setup**: Ensure tests/build can run automatically

```bash
/duyetbot:loop Implement user authentication \
  --promise AUTH_TESTS_PASS \
  --max 100
```

### During Loop (Automatic)

**Each iteration:**
1. UNDERSTAND → Read state
2. PLAN → Choose next action
3. EXECUTE → Make one change
4. VERIFY → Test result
5. Output progress marker
6. Exit → Stop-hook feeds back

**Stop-hook checks:**
- Promise fulfilled? → Exit cleanly
- Max iterations? → Exit with message
- No progress? → Circuit breaker, exit
- Errors detected? → Track count, exit if threshold

### Morning After

**Check results:**
```bash
# Did loop complete?
/status

# What was accomplished?
git log --oneline -10

# Are tests passing?
npm test

# Any circuit breaks?
cat .claude/ralph-circuit.local.json
```

**Outcomes:**
- ✅ **Complete**: Promise matched, task done
- ⚠️ **Circuit break**: Stuck, needs new approach
- ❌ **Error spike**: Technical blocker, investigate logs
- 🔄 **In progress**: Still running, let it continue or `/cancel-ralph`

## Execution Format Within Loop

**Maintain duyetbot's transparent execution style:**

```markdown
─── duyetbot ── iteration 5 ─────

[1] UNDERSTAND → Auth endpoint returns 401
[2] PLAN → Add JWT validation middleware
[3] EXECUTE → Create middleware/auth.ts
[4] VERIFY → npm test → PASSED

Progress: 5/15 steps complete
Next: Add refresh token endpoint
```

## Integration with Duyetbot Skills

**Ralph loop complements existing skills:**

| Skill | Ralph Interaction |
|-------|------------------|
| **task-loop** | Ralph automates the loop iterations |
| **team-coordination** | Can spawn agents within each iteration |
| **transparency** | Maintain visible execution chains |
| **engineering-discipline** | Apply quality gates each iteration |

**Example with team coordination:**
```markdown
Iteration 3:
[1] Spawn: senior-engineer for API design
[2] Spawn: junior-engineer for implementation
[3] Verify both outputs complete
[4] Integration test
<promise>ITERATION_3_COMPLETE</promise>
```

## Safety Best Practices

1. **Always use `--max`** for overnight tasks (safety limit)
2. **Specific promises** - avoid generic words like "done"
3. **Test before sleep** - Verify build/tests work locally
4. **Check dependencies** - Ensure API keys, env vars available
5. **Monitor logs** - Check first few iterations before leaving

## Troubleshooting

**Loop not starting:**
- Check `.claude/ralph-loop.local.md` exists
- Verify hook is registered: `cat hooks/hooks.json`

**Loop stops early:**
- Check circuit state: `cat .claude/ralph-circuit.local.json`
- Review git log for actual progress

**Promise not matching:**
- Verify exact spelling/case
- Check for whitespace in promise tags
- Use simple, unique promises

**Manual cancellation:**
```bash
/cancel-ralph
```
