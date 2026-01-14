---
name: gemini-prompting
description: Prompt engineering guidance for Gemini (Google) model. Use when crafting prompts for Gemini to leverage system instructions, multimodal capabilities, ultra-long context, and strong reasoning features.
---

# Gemini Prompt Engineering

Gemini is Google's multimodal AI model designed from the ground up for text, images, audio, video, and code. It features system instructions, ultra-long context windows (up to 1M+ tokens), and native multimodal understanding.

## When to Invoke This Skill

Use this skill when:
- Crafting prompts specifically for Gemini/Google models
- Using system instructions to guide behavior
- Working with multimodal inputs (text, images, video, audio)
- Leveraging ultra-long context (1M+ tokens)
- Building with Gemini's agent reasoning capabilities

## Gemini's Identity & Characteristics

| Attribute | Description |
|-----------|-------------|
| **Architecture** | Multimodal-first (text, images, audio, video, code) |
| **Context Window** | Up to 1M+ tokens (industry-leading) |
| **System Instructions** | Primary feature for behavior control |
| **Strengths** | Multimodal reasoning, long-context, code generation |
| **Prompt Style** | Flexible with system instruction preference |
| **Models** | Gemini 3 Flash (fast), Gemini 3 Pro (capable), Gemini 2.5 Flash/Pro (legacy) |

## Universal Prompting Techniques (Gemini-Adapted)

### 1. Zero-Shot Prompting with System Instructions

Gemini's system instructions are powerful for zero-shot tasks.

```json
{
  "system_instruction": {
    "parts": [{"text": "You are a technical writing assistant. Your responses are clear, concise, and use Markdown formatting."}]
  },
  "contents": [{"parts": [{"text": "Explain how JWT authentication works."}]}]
}
```

### 2. Few-Shot Prompting

```xml
<system_instruction>
You are a sentiment classifier. Categorize text as positive, negative, or neutral.
</system_instruction>

<examples>
<example>
<input>
I absolutely love this product! Best purchase I've made all year.
</input>
<output>
{"sentiment": "positive", "confidence": 0.95}
</output>
</example>

<example>
<input>
This is the worst customer service I've ever experienced.
</input>
<output>
{"sentiment": "negative", "confidence": 0.92}
</output>
</example>
</examples>

<input>
The product is okay, does what it's supposed to do.
</input>

<output>
```

### 3. Chain-of-Thought Prompting

```
<system_instruction>
You are a strong reasoner. Always think through problems step by step before answering.
</system_instruction>

The odd numbers in this group add up to an even number: 4, 8, 9, 15, 12, 2, 1.

Let's think about this systematically:
```

### 4. Zero-Shot CoT

Simply add reasoning instructions:

```
<system_instruction>
Before answering, always think through the problem step by step.
</system_instruction>

What's the capital of the country that has the largest population in South America?

Let's work through this step by step.
```

### 5. Prompt Chaining

Gemini's long context enables extensive chaining:

**Chain 1:**
```
<system_instruction>
You are a research assistant.
</system_instruction>

Extract all research papers related to "transformer architecture" from this document.

<document>
[paste large document]
</document>
```

**Chain 2:**
```
Summarize the key findings from the extracted papers and identify common themes.

<extracted_papers>
[from previous response]
</extracted_papers>
```

### 6. ReAct Prompting

```xml
<system_instruction>
You are a reasoning agent. Before taking any action, analyze logical dependencies, constraints, and risks. Think through the problem methodically.
</system_instruction>

<question>
[research question]
</question>

<thought_1>
[analysis and plan]
</thought_1>

<action_1>
[tool use or information gathering]
</action_1>

<observation_1>
[result]
</observation_1>

<thought_2>
[next steps based on observation]
</thought_2>

<final_answer>
[conclusion]
</final_answer>
```

### 7. Tree of Thoughts

```xml
<system_instruction>
You are an expert planner. Explore multiple solution paths before recommending an approach.
</system_instruction>

<problem>
[complex problem]
</problem>

<thought_paths>
<path_1>
<approach>[strategy 1]</approach>
<reasoning>[step-by-step]</reasoning>
<expected_outcome>[result]</expected_outcome>
</path_1>

<path_2>
[...]
</path_2>

<path_3>
[...]
</path_3>
</thought_paths>

<recommendation>
[best approach with justification]
</recommendation>
```

## Gemini-Specific Best Practices

### 1. Use System Instructions

System instructions are Gemini's primary behavior control mechanism:

```json
{
  "system_instruction": {
    "parts": [{
      "text": "You are a specialized assistant for data science. You are precise, analytical, and always provide code examples in Python."
    }]
  }
}
```

### 2. Comprehensive System Instruction Template

From official Gemini documentation:

```xml
<role>
You are Gemini, a specialized assistant for [Domain].
You are precise, analytical, and persistent.
</role>

<instructions>
1. **Plan**: Analyze the task and create a step-by-step plan.
2. **Execute**: Carry out the plan.
3. **Validate**: Review your output against the user's task.
4. **Format**: Present the final answer in the requested structure.
</instructions>

<constraints>
- Verbosity: [Low/Medium/High]
- Tone: [Formal/Casual/Technical]
</constraints>

<output_format>
Structure your response as follows:
1. **Executive Summary**: [Short overview]
2. **Detailed Response**: [The main content]
</output_format>
```

### 3. Leverage Multimodal Inputs

Gemini natively processes multiple modalities:

```json
{
  "contents": [{
    "parts": [
      {"text": "Describe what's in this image and suggest a caption for social media."},
      {
        "inline_data": {
          "mime_type": "image/jpeg",
          "data": "[base64_encoded_image]"
        }
      }
    ]
  }]
}
```

### 4. Ultra-Long Context Utilization

Gemini's 1M+ token context enables massive document analysis:

```
<system_instruction>
You are a document analysis specialist.
</system_instruction>

<documents>
[Hundreds of pages of content - up to 1M tokens]
</documents>

<task>
Synthesize key themes across all documents and identify contradictions.
</task>
```

### 5. Code-Specific Prompting

Gemini excels at code generation and analysis:

```
<system_instruction>
You are a senior software engineer. You provide clean, well-documented code with error handling.
</system_instruction>

Write a Python function that:
1. Validates email addresses using regex
2. Returns (is_valid, error_message) tuple
3. Includes comprehensive docstring
4. Handles edge cases

Language: Python
```

## Advanced Features

### Function Calling

Gemini supports native function/tool calling for building agents:

```python
from google import genai
from google.genai import types

client = genai.Client()

get_weather = types.FunctionDeclaration(
    name="get_weather",
    description="Get current weather for a location",
    parameters=types.Schema(
        type=types.Type.OBJECT,
        properties={
            "location": types.Schema(
                type=types.Type.STRING,
                description="City name, e.g. San Francisco"
            ),
            "unit": types.Schema(
                type=types.Type.STRING,
                description="Temperature unit (celsius or fahrenheit)",
                enum=["celsius", "fahrenheit"]
            )
        },
        required=["location"]
    )
)

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="What's the weather in Tokyo and Paris?",
    config=types.GenerateContentConfig(
        tools=[get_weather]
    )
)
```

### Thinking Configuration

Control Gemini's reasoning process with configurable thinking budget:

```python
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Solve this step-by-step: [complex problem]",
    config=types.GenerateContentConfig(
        thinking_config=types.ThinkingConfig(
            thinking_budget=8192  # tokens for reasoning
        )
    )
)
```

### Structured Outputs with JSON Schema

Get validated JSON output with schema enforcement:

```python
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Extract user profile information from this text: [text]",
    config=types.GenerateContentConfig(
        response_mime_type="application/json",
        response_schema=types.Schema(
            type=types.Type.OBJECT,
            properties={
                "name": types.Schema(type=types.Type.STRING),
                "email": types.Schema(type=types.Type.STRING),
                "age": types.Schema(type=types.Type.INTEGER),
                "interests": types.Schema(
                    type=types.Type.ARRAY,
                    items=types.Schema(type=types.Type.STRING)
                )
            },
            required=["name", "email"]
        )
    )
)
```

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Fails | Better Approach |
|--------------|--------------|-----------------|
| Ignoring system instructions | Wastes Gemini's key feature | Always set system_instruction |
| Not using multimodal | Underutilizes Gemini's strength | Combine text, images, audio |
| Small context thinking | Wastes 1M+ capability | Process large documents |
| Inconsistent formats | Confuses multimodal processing | Specify output format clearly |
| Single-shot for complex tasks | Misses reasoning depth | Use multi-turn conversations |
| Not using structured outputs | Manual parsing needed | Use JSON schema validation |
| Disabling thinking when needed | Misses reasoning insights | Enable thinking_budget for complex tasks |

## Quick Reference Templates

### Basic System Instruction
```json
{
  "system_instruction": {
    "parts": [{"text": "[Your system instruction here]"}]
  },
  "contents": [{"parts": [{"text": "[Your prompt]"}]}]
}
```

### Multimodal Input
```
<system_instruction>
You are a visual analysis assistant.
</system_instruction>

Analyze this image and describe:
1. Main subject
2. Mood/atmosphere
3. Suggested use cases

[image]
```

### Long-Context Analysis
```
<system_instruction>
You are a research analyst specializing in synthesis and pattern recognition.
</system_instruction>

<large_context>
[up to 1M tokens of content]
</large_context>

<task>
[analysis task]
</task>

<output_format>
[structure]
</output_format>
```

## Model Capabilities Reference

| Feature | Gemini 3 Flash | Gemini 3 Pro | Gemini 2.5 Flash | Gemini 2.5 Pro |
|---------|----------------|----------------|------------------|----------------|
| **Context Window** | 1M tokens | 1M tokens | 1M tokens | 1M tokens |
| **System Instructions** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Multimodal** | ✅ Native | ✅ Native | ✅ Native | ✅ Native |
| **Code** | ✅ Excellent | ✅ Excellent | ✅ Excellent | ✅ Excellent |
| **Reasoning** | ✅ Strong | ✅ Excellent | ✅ Strong | ✅ Excellent |
| **Speed** | Very Fast | Fast | Very Fast | Fast |
| **Function Calling** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Thinking Config** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **Status** | Latest (2025) | Latest (2025) | Mature | Mature |

**Note:** Model names follow `gemini-{version}-{variant}` pattern. Use `gemini-3-flash-preview` for the latest features.

## System Instruction Patterns

### Role Definition
```
You are a [role] specializing in [domain].
You are [attribute 1], [attribute 2], and [attribute 3].
```

### Task Instructions
```
When given a task:
1. **Analyze**: Break down requirements
2. **Plan**: Create step-by-step approach
3. **Execute**: Complete the task
4. **Review**: Verify against requirements
```

### Output Formatting
```
Always structure your responses as:
- **Summary**: Brief overview
- **Details**: Main content
- **Examples**: Concrete illustrations (if applicable)
- **Caveats**: Limitations or considerations
```

### Behavioral Constraints
```
- Always cite sources when making factual claims
- Indicate confidence levels for uncertain information
- Offer alternative viewpoints on subjective topics
- Flag potential ethical concerns
```

## See Also

- `references/basics.md` - Foundational Gemini prompting concepts
- `references/techniques.md` - Detailed technique explanations
- `references/system-instructions.md` - System instruction patterns
- `references/multimodal.md` - Multimodal prompting guide
- `references/patterns.md` - Reusable Gemini prompt patterns
- `references/examples.md` - Concrete examples and templates
- `grok-prompting` skill - For Grok/xAI-specific guidance
- `claude-prompting` skill - For Anthropic Claude-specific guidance
