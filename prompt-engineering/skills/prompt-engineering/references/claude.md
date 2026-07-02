# Claude-Specific Prompting

Prompt engineering guidance specifically for Anthropic's Claude models.

## Claude's Identity

| Attribute | Description |
|-----------|-------------|
| **Personality** | Helpful, harmless, honest |
| **Architecture** | Constitutional AI with built-in safety guidelines |
| **Context** | Up to 1M tokens (Sonnet 4.5 beta), 200K standard |
| **Strengths** | Long-context analysis, instruction following, document understanding |
| **Recommended** | Claude Sonnet 4.5 (default), Opus 4.5 (complex coding), Haiku 4.5 (speed) |

## XML-Style Tagging

Claude's official courses extensively use XML tags. This is the recommended structure.

### Common XML Tags

```xml
<context>
[background information]
</context>

<task>
[what needs to be done]
</task>

<examples>
[example inputs and outputs]
</examples>

<input>
[the actual input to process]
</input>

<output_format>
[expected structure]
</output_format>
```

### Hierarchical Structure (from Anthropic)

```
[TASK_CONTEXT]
Setting the stage and overall context

[TONE_CONTEXT]
How Claude should approach the task

[INPUT_DATA]
The actual data to work with

[EXAMPLES]
Few-shot examples

[TASK_DESCRIPTION]
Specific task details

[IMMEDIATE_TASK]
The immediate action to take

[OUTPUT_FORMATTING]
Expected output structure
```

## Extended Thinking

Claude 4.5 supports extended thinking with tool use.

### API Syntax (Python)

```python
from anthropic import Anthropic

client = Anthropic()

response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={
        "type": "enabled",
        "budget_tokens": 8192  # Must be less than max_tokens
    },
    messages=[{
        "role": "user",
        "content": "Analyze this complex problem..."
    }]
)

# Response includes thinking block
thinking = response.content.find_block("thinking")
answer = response.content.find_block("text")
```

### Prompt-Side (Expected Output Structure)

```xml
<task>
[complex reasoning task]
</task>

<thinking>
[Claude will show its reasoning here when extended thinking is enabled]
</thinking>

<answer>
[final answer]
</answer>
```

### Key Points

- `budget_tokens` sets max tokens for reasoning (must be < `max_tokens`)
- Claude returns summarized thinking by default
- First few lines are more verbose (useful for prompt engineering)
- You're billed for full thinking tokens, not summary tokens
- Extended thinking works with tool use (can pause reasoning to use tools)

## Parallel Tool Use

Claude 4.5 can use multiple tools simultaneously.

```xml
<task>
Analyze this data and create a visualization.
</task>

<tools>
- Web search for market data
- Code execution for analysis
- File write for chart output
</tools>

Claude will execute these in parallel when possible.
```

## System Prompts

System prompts set Claude's behavior for the conversation.

```
System: You are a technical writer specializing in API documentation. Your responses are always:
- Clear and concise
- Technically accurate
- Formatted with Markdown
- Focused on developer needs

User: [your actual query]
```

## Cache Control

Optimize for repeated prompts with cache control headers.

```xml
<cached_content cache_control="{\"type\":\"ephemeral\"}">
[large context that doesn't change]
</cached_content>

<task>
[specific task that varies]
</task>
```

This caches the large content segment across multiple API calls.

## Prompt Prefill

Guide Claude's response format by starting it for it.

```xml
<task>
Analyze this document and extract key findings.
</task>

<document>
[paste document]
</document>

<response>
<summary>
[ Claude continues from here ]
```

## Model Selection Guide

| Model | Best For | Context | Speed | Cost |
|-------|----------|---------|-------|------|
| **Claude Sonnet 4.5** | Default choice, balanced | 200K/1M | Fast | Medium |
| **Claude Opus 4.5** | Complex coding, deep reasoning | 200K | Moderate | High |
| **Claude Haiku 4.5** | Speed-critical tasks | 200K | Very Fast | Low |

## Quick Templates

### Document Analysis
```xml
<task>
Extract all [entities] from this document and summarize their relationships.
</task>

<document>
[paste document]
</document>

<output_format>
<entities>
<entity name="[name]" type="[type]">
<description>[brief description]</description>
<connections>
<connection to="[other entity]">[relationship]</connection>
</connections>
</entity>
</entities>
</output_format>
```

### Code Generation
```xml
<task>
Write a [language] function that [description].
</task>

<requirements>
- [requirement 1]
- [requirement 2]
- Include error handling
- Add type hints
</requirements>

<examples>
<example>
<input>[input example]</input>
<output>[expected output]</output>
</example>
</examples>

<output_format>
Code in [language] with comments explaining the logic.
</output_format>
```

### Data Extraction
```xml
<task>
Extract [specific fields] from the following text.
</task>

<input_text>
[paste text]
</input_text>

<output_format>
JSON with keys:
- field_1: [description]
- field_2: [description]
- confidence: [0-1 score]
</output_format>
```

## Migration Notes (Claude 3 → 4.5)

| Change | Action Required |
|--------|-----------------|
| Model IDs | Update to `claude-sonnet-4-5-20250929` or use alias `claude-sonnet-4-5` |
| Context window | Add beta header for 1M tokens if needed |
| Parallel tools | Update prompts to leverage parallel execution |
| Memory files | Grant file access for persistent knowledge |
| Extended thinking + tools | Can now use tools during reasoning |
| Max output | Adjust from 8K to 64K tokens expectation |

Most prompting techniques remain unchanged—XML tags, system prompts, and structured outputs work identically.
