---
name: prompt-engineering
description: Write or improve prompts for Claude, Gemini, or Grok. Use when crafting a system prompt, tuning an agent or extraction prompt, or adapting a prompt from one model family to another.
---

# Prompt engineering

## Method

1. State the goal, the audience of the output, and the success test before writing.
2. Write the prompt: context, then task, then output format. Say what to do. Add the reason when a rule is not obvious.
3. Run it on 3 to 5 realistic inputs, including a hard one. Change one thing at a time and keep what fixes a real failure.
4. Delete instructions that no failing case needs.

## Techniques that pay off on every model

- Examples beat description for format and tone. Use 3 to 5 varied ones, clearly separated from the instructions.
- Separate instructions from data with delimiters so pasted content is not read as commands.
- Specify the output shape exactly, and use the API's structured-output feature when you need machine-readable results.
- For multi-step work, split into chained prompts with a checkable result at each step.
- For reasoning, use the model's built-in thinking setting. Do not prescribe the steps.
- Tool-using agents need clear tool descriptions, stop conditions, and what to do on failure.

## Model deltas

Read the one that matches the target model. Each lists only what changes how you prompt it.

- [references/claude.md](references/claude.md)
- [references/gemini.md](references/gemini.md)
- [references/grok.md](references/grok.md)

Model ids, context limits, and parameters change often. Check the provider's current model list instead of copying ids from memory.
