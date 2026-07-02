# Gemini-Specific Prompting

Prompt engineering guidance specifically for Google's Gemini models.

## Gemini's Identity

| Attribute | Description |
|-----------|-------------|
| **Architecture** | Multimodal-first (text, images, audio, video, code) |
| **Context** | 1M+ tokens (industry-leading) |
| **Key Feature** | System instructions (primary behavior control) |
| **Strengths** | Multimodal reasoning, long-context, code generation |
| **Models** | Gemini 3 Flash (fast), Gemini 3 Pro (capable) |

## System Instructions

System instructions are Gemini's primary mechanism for controlling behavior.

### Basic Structure

```json
{
  "system_instruction": {
    "parts": [{
      "text": "You are a [role] specializing in [domain]. You are [attribute 1], [attribute 2], and [attribute 3]."
    }]
  },
  "contents": [{
    "parts": [{"text": "[Your actual prompt]"}]
  }]
}
```

### Comprehensive Template

From official Gemini documentation:

```xml
<role>
You are Gemini, a specialized assistant for [Domain].
You are precise, analytical, and persistent.
</role>

<instructions>
1. Plan: Analyze the task and create a step-by-step plan.
2. Execute: Carry out the plan.
3. Validate: Review your output against the user's task.
4. Format: Present the final answer in the requested structure.
</instructions>

<constraints>
- Verbosity: [Low/Medium/High]
- Tone: [Formal/Casual/Technical]
</constraints>

<output_format>
Structure your response as follows:
1. Executive Summary: [Short overview]
2. Detailed Response: [The main content]
</output_format>
```

### System Instruction Patterns

#### Role Definition
```
You are a [role] specializing in [domain].
You are [attribute 1], [attribute 2], and [attribute 3].
```

#### Task Instructions
```
When given a task:
1. Analyze: Break down requirements
2. Plan: Create step-by-step approach
3. Execute: Complete the task
4. Review: Verify against requirements
```

#### Output Formatting
```
Always structure your responses as:
- Summary: Brief overview
- Details: Main content
- Examples: Concrete illustrations (if applicable)
- Caveats: Limitations or considerations
```

#### Behavioral Constraints
```
- Always cite sources when making factual claims
- Indicate confidence levels for uncertain information
- Offer alternative viewpoints on subjective topics
- Flag potential ethical concerns
```

## Multimodal Inputs

Gemini natively processes multiple modalities in a single request.

### Image + Text

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

### Video + Text

```json
{
  "contents": [{
    "parts": [
      {"text": "Analyze this video and summarize the key events."},
      {
        "file_data": {
          "mime_type": "video/mp4",
          "file_uri": "gs://[bucket]/[video].mp4"
        }
      }
    ]
  }]
}
```

### Multiple Modalities

```json
{
  "contents": [{
    "parts": [
      {"text": "Compare these two images and describe the differences."},
      {"inline_data": {"mime_type": "image/jpeg", "data": "[base64_1]"}},
      {"inline_data": {"mime_type": "image/jpeg", "data": "[base64_2]"}}
    ]
  }]
}
```

## Structured Outputs (JSON Schema)

Get validated JSON output with schema enforcement.

```python
from google import genai
from google.genai import types

client = genai.Client()

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

## Thinking Configuration

Control Gemini's reasoning process with configurable thinking budget.

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

## Function Calling

Gemini supports native function/tool calling for building agents.

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

## Long Context Utilization

Gemini's 1M+ token context enables massive document analysis.

```
<system_instruction>
You are a document analysis specialist specializing in synthesis and pattern recognition.
</system_instruction>

<documents>
[Hundreds of pages of content - up to 1M tokens]
</documents>

<task>
Synthesize key themes across all documents and identify contradictions.
Provide a structured summary with:
1. Common themes
2. Conflicting information
3. Knowledge gaps
4. Recommended next steps
</task>

<output_format>
Markdown with ## headings for each section.
</output_format>
```

## Model Selection

| Model | Best For | Speed | Capability |
|-------|----------|-------|------------|
| **Gemini 3 Flash** | Fast responses, real-time | Very Fast | Strong |
| **Gemini 3 Pro** | Complex reasoning, accuracy | Fast | Excellent |
| **Gemini 2.5 Flash** | Mature, proven | Very Fast | Strong |
| **Gemini 2.5 Pro** | Mature, capable | Fast | Excellent |

## Quick Templates

### Classification with System Instruction
```json
{
  "system_instruction": {
    "parts": [{"text": "You are a sentiment classifier. Categorize text as positive, negative, or neutral. Output JSON only."}]
  },
  "contents": [{
    "parts": [{"text": "I absolutely love this product! Best purchase ever."}]
  }]
}
```

### Code Generation
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

### Multimodal Analysis
```json
{
  "contents": [{
    "parts": [
      {"text": "Analyze this image, describe the main subject, mood, and suggest a use case."},
      {"inline_data": {"mime_type": "image/jpeg", "data": "[base64]"}}
    ]
  }]
}
```

## Best Practices Summary

1. **Always use system instructions** - This is Gemini's primary feature
2. **Leverage multimodal** - Combine text, images, audio, video
3. **Use long context** - Process up to 1M+ tokens
4. **Specify JSON schema** - For structured output validation
5. **Enable thinking** - For complex reasoning tasks
6. **Use function calling** - For agent building
