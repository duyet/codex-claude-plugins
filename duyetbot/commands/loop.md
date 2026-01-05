---
description: Duyetbot loop - iterative execution until task completion
argument-hint: "TASK [--max N]"
---

# Duyetbot Loop

Execute iteratively until complete: `$ARGUMENTS`

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

- All criteria met
- Blocker requiring human input
- Max iterations reached
- Repeated failure (3x same step)

## Output

End each iteration:
```
─── duyetbot ── iteration N ─────
```

Final:
```
─── duyetbot ── complete (N iterations) ─────
```
