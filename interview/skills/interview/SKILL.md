---
name: interview
description: Use before implementing when requirements are ambiguous. Interview the user to clarify a vague request or to find gaps in a plan or spec file, then write a decision-complete spec.
---

# Interview

If the input is a file, interview about its gaps. Read relevant repo files first and never ask what the code answers. Probe only where the answer changes the build: core use case and failure paths, scale and integrations, user types, edge cases, constraints and v2 scope, existing patterns.

- Use the ask-user tool, 2 to 4 related questions per call, architecture before details.
- Each question offers real options with a recommended one and its tradeoff. No yes/no questions. Separate product intent from implementation preference.
- Stop when an engineer could build from the spec with no further questions. Confirm once.

Write a spec with: overview, decisions and rationale, functional and non-functional requirements, technical design, edge cases with expected behavior, out of scope, open questions.
