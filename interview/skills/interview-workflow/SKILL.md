---
name: interview-workflow
description: Use before implementing when requirements are ambiguous. Interview the user to clarify a vague request or to find gaps in a plan or spec file, then write a decision-complete spec.
---

# Interview

## Start

If the input is a file path, read it and interview about its gaps. Otherwise treat the input as the request. Read relevant repo files, schemas, and docs first so you never ask what the code already answers.

## What to cover

Probe only where the answer changes the build.

- Core: the real primary use case, boundaries, what happens when the happy path fails.
- Technical: scale and latency, persistence, integrations, security, error handling.
- Users: every user type, their mental model, critical flows, accessibility.
- Edge cases: invalid input, load, dependency failure, races and concurrency.
- Constraints: deadline, what can wait for v2, hard constraints versus preferences.
- Context: existing patterns to follow or avoid, who else is affected.

## How to ask

- Use the ask-user tool, batching 2 to 4 related questions per call. Go from architecture to details.
- Each question offers real options with a recommended one and its tradeoff. No yes/no questions, no questions the input already answers.
- Separate product intent from implementation preference. If the user says "just do X", ask why and name an alternative.
- Record each decision as you go.

## Stop

Stop when you could hand the spec to an engineer with no further questions. Summarize the decisions and ask for confirmation once.

## Output

Write a spec with these sections: overview, decisions and rationale, functional and non-functional requirements, technical design (components, data model, APIs if any), edge cases with expected behavior, out of scope, open questions.
