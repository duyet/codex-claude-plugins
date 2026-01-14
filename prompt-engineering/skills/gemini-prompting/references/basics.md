# Gemini Prompt Engineering - Basics

## What is Prompt Engineering for Gemini?

Prompt engineering for Gemini is the practice of crafting effective instructions to elicit optimal responses from Google's multimodal AI models. Gemini's unique architecture—multimodal-first design, ultra-long context, and system instructions—requires specific prompting strategies.

## Why Gemini-Specific Prompting?

While universal prompting techniques apply to all LLMs, Gemini has unique characteristics:

1. **Multimodal Native**: Built for text, images, audio, video from the ground up
2. **Ultra-Long Context**: Up to 1M+ token context window
3. **System Instructions**: Primary mechanism for behavior control
4. **Two Model Tiers**: Flash (fast) and Pro (capable)

## Core Principles for Gemini

### 1. Use System Instructions

System instructions are Gemini's key feature:

```json
{
  "system_instruction": {
    "parts": [{"text": "You are a specialized data science assistant."}]
  }
}
```

### 2. Leverage Multimodal Capabilities

Combine different input types:

```
Analyze this image and write a blog post about it.

[image]
```

### 3. Utilize Long Context

Process massive documents:

```
Analyze trends across this entire dataset.

[large dataset - up to 1M tokens]
```

### 4. Specify Output Format

Always tell Gemini the expected format:

```
<output_format>
JSON with keys: "analysis", "confidence", "recommendations"
</output_format>
```

## Gemini Model Family

| Model | Best For | Speed | Context |
|-------|----------|-------|---------|
| **Gemini 2.5 Flash** | Speed, cost-efficiency | Very Fast | 1M tokens |
| **Gemini 2.5 Pro** | Complex reasoning, nuanced tasks | Fast | 1M tokens |

## System Instruction vs. User Message

**System Instruction:**
- Sets behavior, role, and constraints
- Applies to all messages in conversation
- Not counted in user-visible message limits
- Best for: role definition, behavioral guidelines

**User Message:**
- The actual task or query
- Visible in conversation history
- Best for: specific requests, data input

**Example:**
```json
{
  "system_instruction": {
    "parts": [{"text": "You are a code reviewer. Focus on correctness, performance, and maintainability."}]
  },
  "contents": [{
    "parts": [{"text": "Review this Python function:\n\n[code]"}]
  }]
}
```

## When to Use Gemini

| Scenario | Why Gemini? |
|----------|-------------|
| **Image/video analysis** | Native multimodal understanding |
| **Very long documents** | 1M+ token context |
| **Code generation** | Excellent across all languages |
| **Multilingual tasks** | Strong language support |
| **Multimodal RAG** | Can process text + images together |
| **Reasoning tasks** | Pro model has strong reasoning |

## Common Use Cases

### 1. Multimodal Analysis
```
Describe this image and suggest improvements.

[image]
```

### 2. Code Generation
```
Write a function to validate email addresses in Python.

Include error handling and docstring.
```

### 3. Document Synthesis
```
<system_instruction>
You are a research analyst.
</system_instruction>

Synthesize key findings from these 50 research papers.

[all papers - large context]
```

### 4. Video Analysis
```
Summarize the key topics discussed in this video.

[video file]
```

## API Structure

### Basic Request (New SDK)

```python
from google import genai

client = genai.Client()
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Explain quantum computing in simple terms."
)

print(response.text)
```

### Basic Request (Legacy SDK)

```python
import google.generativeai as genai

model = genai.GenerativeModel("gemini-2.5-flash")
response = model.generate_content(
    "Explain quantum computing in simple terms."
)
print(response.text)
```

### With System Instruction (Legacy SDK)

```python
import google.generativeai as genai

model = genai.GenerativeModel(
    "gemini-2.5-flash",
    system_instruction="You are a physics tutor specializing in making complex topics accessible."
)

response = model.generate_content("Explain quantum entanglement.")
```

### With System Instruction (New SDK)

```python
from google import genai
from google.genai import types

client = genai.Client()

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Explain quantum entanglement.",
    config=types.GenerateContentConfig(
        system_instruction="You are a physics tutor specializing in making complex topics accessible."
    )
)
```

### Multimodal Input (Legacy SDK)

```python
import PIL.Image
import google.generativeai as genai

model = genai.GenerativeModel("gemini-2.5-pro")
image = PIL.Image.open("photo.jpg")

response = model.generate_content([
    "Describe this image in detail.",
    image
])
```

### Multimodal Input (New SDK)

```python
from google import genai
import PIL.Image

client = genai.Client()

image = PIL.Image.open("photo.jpg")

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents=[
        "Describe this image in detail.",
        image
    ]
)
```

## Getting Started Checklist

- [ ] Choose appropriate Gemini model (Flash vs Pro)
- [ ] Set system instruction for behavior
- [ ] Structure prompt with clear task
- [ ] Specify output format
- [ ] Consider multimodal inputs
- [ ] Leverage long context if needed
- [ ] Test and iterate

## Key Differences from Other Models

| Aspect | Gemini | Claude | Grok |
|--------|--------|--------|------|
| **Architecture** | Multimodal-first | Text-first | Text-first |
| **Context** | 1M+ tokens | 200K tokens | ~128K tokens |
| **Key Feature** | System instructions | XML tags | Conversational |
| **Strength** | Multimodal | Long-context analysis | Real-time knowledge |
| **Best For** | Multimodal tasks | Document analysis | Current events |
