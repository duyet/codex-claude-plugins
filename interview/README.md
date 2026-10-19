# Interview

Clarify ambiguous requirements before coding. Claude asks batched, option-based questions, then writes a decision-complete spec.

```bash
/plugin install interview@duyet-claude-plugins
```

## Ships

- `interview-workflow` skill: question categories, how to ask, stop condition, spec format.
- `/interview <prompt or spec path>`: runs the skill.

## Usage

```
/interview "add a commenting system to the blog"
/interview ./docs/feature-spec.md
```
