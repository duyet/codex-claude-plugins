# Prompt Engineering Basics

Foundational concepts for effective prompt engineering across all AI models.

## Core Principles

### 1. Clarity Over Cleverness

Be explicit about what you want. Vague prompts produce vague results.

**Bad:**
```
Help me with this code.
```

**Good (Claude):**
```xml
<task>
Review this Python function for bugs and suggest improvements.
Focus on: error handling, edge cases, and performance.
</task>

<code>
[paste code]
</code>

<output_format>
1. Issues found (if any)
2. Specific suggestions with code examples
3. Explanation of why each change matters
</output_format>
```

**Good (Gemini):**
```json
{
  "system_instruction": {
    "parts": [{"text": "You are a code reviewer. You identify bugs, suggest improvements, and explain your reasoning clearly."}]
  },
  "contents": [{"parts": [{"text": "Review this Python code for bugs and improvements:\n\n[code]"}]}]
}
```

### 2. Provide Context

Models don't know what you haven't told them. Include relevant background.

**Essential Context:**
- Goal/purpose of the task
- Target audience or use case
- Constraints or limitations
- Available resources or tools
- Relevant background information

### 3. Specify Output Format

Always define how you want the response structured.

**Format Options:**
- JSON/structured data
- Markdown (headers, lists, tables)
- Code with specific language
- XML tags for parsing
- Specific sections or templates

### 4. Use Examples When Appropriate

For complex tasks, provide few-shot examples to demonstrate the expected pattern.

## Prompt Elements

Every effective prompt contains these elements (in order of priority):

| Element | Purpose | When Required |
|---------|---------|---------------|
| **Task** | What to do | Always |
| **Context** | Background information | Complex tasks |
| **Format** | Output structure | Almost always |
| **Examples** | Demonstrate pattern | Ambiguous tasks |
| **Constraints** | Limitations/boundaries | When scope matters |
| **Tone** | How to respond | For personality/style |

## Common Prompt Structures

### Structure 1: Task-Format (Simple)
```
<task>
[what to do]
</task>

<format>
[how to output]
</format>
```

### Structure 2: Context-Task-Format (Standard)
```
<context>
[background information]
</context>

<task>
[what to do]
</task>

<format>
[how to output]
</format>
```

### Structure 3: Full Structure (Complex)
```
<context>
[background]
</context>

<task>
[what to do]
</task>

<examples>
[examples]
</examples>

<constraints>
[limitations]
</constraints>

<format>
[how to output]
</format>
```

## Universal Techniques

### Zero-Shot
Single prompt without examples. Works for straightforward tasks.

### Few-Shot
Provide 2-5 examples to demonstrate the pattern. Essential for classification or transformation tasks.

### Chain-of-Thought
Ask the model to "think step by step" for reasoning tasks.

### Prompt Chaining
Break complex tasks into multiple prompts, feeding output of one into input of next.

## Output Format Patterns

### JSON Output
```
Output JSON with the following structure:
{
  "summary": "brief overview",
  "details": ["item 1", "item 2"],
  "confidence": 0.95
}
```

### Markdown Sections
```
## Summary
[brief overview]

## Details
- Point 1
- Point 2

## Conclusion
[final thoughts]
```

### Code Format
```
Language: Python
Requirements:
- Function signature: def process_data(data: List[str]) -> Dict
- Include type hints
- Add docstring
- Handle edge cases
```

## Testing Your Prompts

Before finalizing a prompt:

1. **Test with edge cases** - Empty input, very long input, special characters
2. **Verify format** - Does output match expected structure?
3. **Check consistency** - Run multiple times, check for variations
4. **Measure quality** - Does output meet your actual requirements?

## Iteration Process

Prompt engineering is iterative:

1. Start with simple prompt
2. Test and identify failures
3. Add missing context
4. Specify format more precisely
5. Add examples if needed
6. Test again
7. Refine until consistent quality

## Common Mistakes

| Mistake | Impact | Fix |
|---------|--------|-----|
| No output format specified | Unpredictable structure | Always specify format |
| Too much context at once | Model loses focus | Use prompt chaining |
| No examples for complex task | Misunderstanding requirements | Add 2-3 few-shot examples |
| Ignoring model personality | Wasted capabilities | Adapt to model's style |
| One-shot for complex tasks | Poor quality | Break into smaller prompts |
