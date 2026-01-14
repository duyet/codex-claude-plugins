# Claude Prompt Engineering - Basics

## What is Prompt Engineering for Claude?

Prompt engineering for Claude is the practice of crafting effective instructions to elicit optimal responses from Anthropic's AI models. Claude's unique characteristics—constitutional AI, long-context windows, and strong instruction following—require specific prompting strategies.

## Why Claude-Specific Prompting?

While universal prompting techniques apply to all LLMs, Claude has unique characteristics:

1. **Constitutional AI**: Built-in safety and ethical guidelines
2. **Long Context**: Up to 200K token context window
3. **XML Preference**: Official docs extensively use XML-style tags
4. **Extended Thinking**: Optional reasoning trace feature
5. **Strong Instruction Following**: Excels at precise instruction adherence

## Core Principles for Claude

### 1. Structure with XML-Style Tags

Claude's official documentation and courses heavily use XML tags for organization:

```xml
<context>[background info]</context>
<task>[what to do]</task>
<input>[data]</input>
<output_format>[expected format]</output_format>
```

### 2. Be Clear and Direct

Claude follows instructions precisely. Ambiguity leads to unpredictable results.

**Good:**
```xml
<task>Extract all email addresses from the text.</task>
<output_format>Comma-separated list</output_format>
```

**Less Effective:**
```
Can you find the emails?
```

### 3. Specify Output Format

Always tell Claude how you want the output structured:

```xml
<output_format>
JSON with keys: "name", "email", "company"
</output_format>
```

### 4. Use Few-Shot Examples

When format matters, show Claude examples:

```xml
<examples>
<example>
<input>Jane Doe, jane@example.com, Acme Inc</input>
<output>{"name": "Jane Doe", "email": "jane@example.com", "company": "Acme Inc"}</output>
</example>
</examples>
```

### 5. Leverage Long Context

Claude can analyze entire documents (up to 200K tokens):

```xml
<task>Analyze this research paper and summarize findings.</task>
<document>
[entire paper]
</document>
```

## Claude Model Family

| Model | Best For | Speed | Context |
|-------|----------|-------|---------|
| **Claude 3.5 Sonnet** | Coding, analysis, tool use | Fast | 200K |
| **Claude 3 Opus** | Complex reasoning, writing | Medium | 200K |
| **Claude 3 Haiku** | Speed, cost-efficiency | Very Fast | 200K |

## Prompt Structure from Anthropic Courses

Official Anthropic courses teach this hierarchical structure:

```
1. TASK_CONTEXT - Overall setting and purpose
2. TONE_CONTEXT - How Claude should approach the task
3. INPUT_DATA - The actual data to process
4. EXAMPLES - Few-shot demonstrations
5. TASK_DESCRIPTION - Specific task details
6. IMMEDIATE_TASK - The immediate action to take
7. OUTPUT_FORMATTING - Expected output structure
8. PRECOGNITION - Anticipating issues (optional)
```

## System Prompts vs User Messages

**System Prompt:**
- Sets Claude's overall behavior and persona
- Persists across the conversation
- Not visible to end users in production
- Best for: role definition, behavioral guidelines

**User Message:**
- The actual task or query
- Visible in conversation
- Best for: specific requests, data input

**Example:**
```
System: You are a technical documentation specialist. Your responses are always:
- Clear and concise
- Formatted in Markdown
- Focused on developer needs
- Technically accurate

User: Write documentation for this API endpoint...
```

## Extended Thinking Feature

Claude can show its reasoning process:

```json
{
  "thinking": {
    "type": "enabled",
    "budget_tokens": 4096
  }
}
```

This causes Claude to output `<thinking>` tags with its reasoning before the final answer.

## When to Use Claude

| Scenario | Why Claude? |
|----------|-------------|
| **Long document analysis** | 200K context window |
| **Precise instruction following** | Constitutional AI training |
| **Code generation** | Sonnet excels at coding |
| **Tool use** | Excellent function calling |
| **Structured output** | Follows format precisely |
| **Ethical considerations** | Built-in safety guidelines |

## Common Use Cases

### 1. Document Analysis
```xml
<task>Summarize key findings from this research paper.</task>
<document>[paste paper]</document>
<output_format><summary>...</summary><key_points>...</key_points></output_format>
```

### 2. Code Generation
```xml
<task>Write a function that validates email addresses.</task>
<language>Python</language>
<requirements>- Use regex
- Return boolean
- Include docstring</requirements>
```

### 3. Data Extraction
```xml
<task>Extract names and emails from this text.</task>
<input_text>[paste text]</input_text>
<output_format>JSON list of objects</output_format>
```

### 4. Content Transformation
```xml
<task>Rewrite this for a technical audience.</task>
<input>[casual explanation]</input>
<output_format>Technical documentation in Markdown</output_format>
```

## Getting Started Checklist

- [ ] Define your task clearly
- [ ] Choose appropriate Claude model
- [ ] Structure prompt with XML tags
- [ ] Provide examples if format matters
- [ ] Specify output format
- [ ] Consider using system prompt for context
- [ ] Test and iterate

## Key Differences from Other Models

| Aspect | Claude | Grok | Gemini |
|--------|--------|------|--------|
| **Prompt Style** | Structured/XML | Conversational | Flexible |
| **Strength** | Long-context | Real-time knowledge | Multimodal |
| **Constraints** | Constitutional | Relaxed | Balanced |
| **Best For** | Analysis, code | Current events | Multimodal tasks |
| **Format** | XML tags preferred | Natural language | System instructions |
