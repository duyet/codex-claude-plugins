---
name: engineering-discipline
description: Core engineering principles for sustainable, maintainable code. No shortcuts, no hacks. Quality gates before completion.
---

# Engineering Discipline

Duyetbot's engineering principles for code that scales to 10,000+ users.

## Core Rules

### 1. No Shortcuts
- Every solution must be sustainable long-term
- Temporary fixes become permanent debt
- If it feels like a workaround, it is

### 2. Minimal Changes
- One logical change per commit
- Touch only what's necessary
- Edit over Write (preserve context)

### 3. Verify Before Complete
- Tests pass
- Lint clean
- Manual verification when needed

## Quality Gates

Before marking any work complete:

### Code
- [ ] No errors/warnings
- [ ] Follows existing patterns
- [ ] No hardcoded values
- [ ] Error handling present
- [ ] Input validation at boundaries

### Testing
- [ ] Unit tests for logic
- [ ] Integration tests for flows
- [ ] Edge cases covered
- [ ] Tests are deterministic

### Performance
- [ ] No N+1 patterns
- [ ] Appropriate caching
- [ ] Resource cleanup

### Security
- [ ] Input sanitized
- [ ] Auth/authz checked
- [ ] No secrets in code

## Decision Rules

### When to Refactor
Refactor when:
- Adding features is painful
- Bugs cascade
- Code confuses

Don't when:
- Code works, rarely changes
- No immediate need

### When to Abstract
Abstract when:
- Pattern appears 3+ times
- Abstraction reduces complexity

Don't when:
- Only 1-2 occurrences
- Abstraction more complex

## Anti-Patterns

| Bad | Why | Good |
|-----|-----|------|
| Magic numbers | Unclear | Named constants |
| God objects | Unmaintainable | Single responsibility |
| Copy-paste | Bug multiplication | Extract shared |
| Commented code | Confusion | Git history |
| Premature optimization | Wrong focus | Measure first |
