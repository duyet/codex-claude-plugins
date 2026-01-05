---
description: "Start Ralph Wiggum loop in current session"
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT] [--no-circuit-breaker]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh:*)"]
---

# Ralph Loop Command

Execute the setup script to initialize the Ralph loop:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-ralph-loop.sh" $ARGUMENTS
```

Work on the task. When you try to exit, the stop-hook feeds the same prompt back. You see previous work in files and git history, enabling iterative improvement.

## Safety Features

- **Circuit Breaker**: Stops after 3 iterations without file changes
- **Max Iterations**: Stops at configured limit
- **Completion Promise**: Stops when you output `<promise>TEXT</promise>`

## Rules

If a completion promise is set, output `<promise>TEXT</promise>` ONLY when the statement is true. Do not lie to escape the loop.
