---
name: prompt-engineering
description: Write or improve prompts for Claude, Gemini, or Grok. Use when crafting a system prompt, tuning an agent or extraction prompt, or adapting a prompt from one model family to another.
---

# Prompt engineering

State the goal and success test first. Test on 3 to 5 realistic inputs including a hard one, change one thing at a time, and delete instructions no failing case needs. Use examples for format, delimiters between instructions and data, and the API's structured-output and thinking settings instead of prose. Check the provider's current model list and docs for ids, limits, and parameters.

Model differences:

- **Claude.** XML tags for distinct inputs, long documents first and the question last. It follows instructions literally, so say what to do, not what to avoid. Use adaptive or extended thinking, not scripted steps.
- **Gemini.** Role, rules, and format in the system instruction, task and data in the user turn. Keep prompts short and direct. Name each multimodal input. Use built-in grounding for current facts.
- **Grok.** Conversational and direct. It has live X and web access, so give the time window and source type and ask for citations. Specify the register for contested topics. Ask it to separate sourced fact from opinion.
