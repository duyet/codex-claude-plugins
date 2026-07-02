---
name: prompt-engineering
description: Comprehensive prompt engineering guidance for Claude (Anthropic), Gemini (Google), and Grok (xAI). Use when crafting prompts to leverage each model's unique capabilities—XML-style tags for Claude, system instructions for Gemini, conversational style for Grok.
---

# Prompt Engineering

Comprehensive prompt engineering guidance covering Claude (Anthropic), Gemini (Google), and Grok (xAI). Each model has unique strengths and optimal prompting patterns.

## When to Invoke This Skill

Use this skill when:
- Crafting prompts for Claude, Gemini, or Grok models
- Leveraging model-specific capabilities (XML tags, system instructions, real-time knowledge)
- Working with long-context tasks (up to 1M+ tokens)
- Implementing extended thinking or reasoning features
- Building agentic workflows with parallel tool use
- Designing prompts for multimodal inputs (text, images, audio, video)

## Quick Model Selection

| Model | Best For | Key Strength | Prompt Style |
|-------|----------|--------------|--------------|
| **Claude Sonnet 4.5** | Balanced tasks, long-context, instruction following | XML-style structure, extended thinking, parallel tools | Structured with XML tags |
| **Gemini 3 Flash/Pro** | Multimodal, ultra-long context, system instructions | Native multimodal, 1M+ context, JSON schema output | System instruction based |
| **Grok** | Current events, controversial topics, creative work | Real-time X (Twitter) access, witty personality | Conversational, direct |

## Universal Prompting Techniques

These techniques work across all models with adaptations noted below.

### 1. Zero-Shot Prompting

**Claude (XML-style):**
```xml
<task>
Extract the key dates and events from the following text:
</task>

<text>
[paste text]
</text>

<output_format>
JSON with keys "date", "event", "description"
</output_format>
```

**Gemini (System Instructions):**
```json
{
  "system_instruction": {
    "parts": [{"text": "You are a data extraction specialist. Output JSON only."}]
  },
  "contents": [{"parts": [{"text": "Extract dates from: [text]"}]}]
}
```

**Grok (Conversational):**
```
Hey, can you pull out all the important dates from this text and give me a JSON summary?

[text]
```

### 2. Few-Shot Prompting (Multishot)

**Claude:**
```xml
<examples>
<example>
<input>The conference is scheduled for March 15, 2025 in San Francisco.</input>
<output>{"date": "2025-03-15", "event": "conference", "location": "San Francisco"}</output>
</example>
<example>
<input>Our next board meeting is on June 22nd.</input>
<output>{"date": "2025-06-22", "event": "board meeting"}</output>
</example>
</examples>

<input>
The product launches on September 1st in New York.
</input>

<output>
```

**Gemini:** Similar structure with system instruction for classification task.

**Grok:** Provide natural language examples matching conversational tone.

### 3. Chain-of-Thought Prompting

**Claude (Extended Thinking - API):**
```python
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={"type": "enabled", "budget_tokens": 8192},
    messages=[{
        "role": "user",
        "content": "<task>[complex reasoning task]</task>\n\nPlease show your reasoning step by step."
    }]
)
# Response includes <thinking> block followed by <answer>
```

**Gemini (Thinking Config):**
```python
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Solve step-by-step: [problem]",
    config=types.GenerateContentConfig(
        thinking_config=types.ThinkingConfig(thinking_budget=8192)
    )
)
```

**Grok (Zero-Shot CoT):**
```
Let's work through this step by step:

[complex problem]

Walk me through your reasoning.
```

### 4. Prompt Chaining

Break complex tasks into sequential steps.

**Claude (XML structure):**
```xml
<!-- Step 1 -->
<task>Extract relevant quotes about [topic].</task>
<document>[text]</document>

<!-- Step 2 -->
<task>Summarize extracted quotes and synthesize key insights.</task>
<quotes>[from step 1]</quotes>
```

**Gemini:** Use long context (1M+ tokens) to maintain conversation history.

**Grok:** Natural conversation flow with follow-up questions.

### 5. ReAct Prompting

Thought-Action-Observation cycles for reasoning with tools.

**Claude (XML):**
```xml
<question>[research question]</question>

<thought_1>[what needs to be done first]</thought_1>
<action_1>[tool use]</action_1>
<observation_1>[result]</observation_1>

<thought_2>[next step based on observation]</thought_2>
<final_answer>[conclusion]</final_answer>
```

**Gemini:** Similar structure with system instruction for reasoning behavior.

**Grok:** Conversational "Let's approach this methodically" style.

### 6. Tree of Thoughts

Explore multiple reasoning paths before concluding.

**Claude:**
```xml
<thought_paths>
<path_1>
<assumption>[approach 1]</assumption>
<reasoning>[step-by-step]</reasoning>
<conclusion>[result]</conclusion>
</path_1>
<path_2>...</path_2>
</thought_paths>

<synthesis>[best path and why]</synthesis>
```

**Grok (Creative exploration):**
```
Let's imagine three different perspectives on [topic]:
1. The Optimist's View: ...
2. The Skeptic's View: ...
3. The Pragmatist's View: ...

Where do these perspectives intersect?
```

## Model-Specific Best Practices

### Claude (Anthropic)

**Key Features:**
- XML-style tags for structure (official Anthropic recommendation)
- Extended thinking with tool use support
- Parallel tool execution
- Memory files for persistent knowledge
- Up to 1M tokens context (Sonnet 4.5 beta)

**Prompt Structure:**
```xml
[task_context]
Setting the stage and overall context

[tone_context]
How Claude should approach the task

[input_data]
The actual data to work with

[examples]
Few-shot examples

[task_description]
Specific task details

[immediate_task]
The immediate action to take

[output_formatting]
Expected output structure
```

**Best Practices:**
- Use XML tags liberally for structure
- Enable extended thinking for complex reasoning
- Leverage parallel tool use
- Use cache control for repeated prompts
- Prefill responses to guide format

### Gemini (Google)

**Key Features:**
- System instructions (primary behavior control)
- Native multimodal (text, images, audio, video, code)
- Ultra-long context (1M+ tokens)
- JSON schema validation for structured output
- Function calling for agent building

**System Instruction Template:**
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

**Best Practices:**
- Always use system instructions for behavior
- Leverage multimodal inputs (combine text + images)
- Use JSON schema for structured outputs
- Process large documents with 1M+ context
- Enable thinking_budget for complex tasks

### Grok (xAI)

**Key Features:**
- Witty, rebellious personality
- Real-time X (Twitter) knowledge access
- Relaxed content filtering
- Natural, conversational style

**Prompt Style:**
```
Conversational, direct, and flexible. Grok responds best to natural language rather than over-structured prompts.
```

**Best Practices:**
- Use conversational language (not overly formal)
- Leverage real-time knowledge for current events
- Embrace the wit (work with it, not against it)
- Be direct—no need for delicate prompting
- Explore controversial or filtered topics

## Model Capabilities Comparison

| Feature | Claude Sonnet 4.5 | Gemini 3 Flash/Pro | Grok |
|---------|-------------------|-------------------|------|
| **Context Window** | 200K / 1M (beta) | 1M+ tokens | 1M+ tokens |
| **Extended Thinking** | ✅ (with tools) | ✅ (thinking config) | ⚠️ Limited |
| **Multimodal** | ✅ Yes | ✅ Native | ✅ Yes |
| **Real-Time Knowledge** | ❌ No | ❌ No | ✅ Yes (X/Twitter) |
| **Structured Output** | ✅ (prefill) | ✅ (JSON schema) | ⚠️ Manual |
| **Parallel Tools** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Content Filtering** | Strict | Moderate | Relaxed |
| **Best For** | Long-context, instruction following | Multimodal, system instructions | Current events, creative work |

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Fails | Fix |
|--------------|--------------|-----|
| **Claude**: Ambiguous instructions | Follows literally | Be explicit with XML tags |
| **Claude**: Missing output format | Unpredictable formatting | Always specify format |
| **Gemini**: Ignoring system instructions | Wastes key feature | Always set system_instruction |
| **Gemini**: Not using multimodal | Underutilizes strength | Combine text, images, audio |
| **Grok**: Overly formal prompts | Against personality | Use conversational language |
| **Grok**: Ignoring real-time knowledge | Wastes unique capability | Ask about current events |
| **All**: Single-shot for complex tasks | Misses reasoning depth | Use chaining or multi-turn |

## Quick Reference Templates

### Document Analysis (Claude)
```xml
<task>
[specific analysis task]
</task>

<document>
[paste document]
</document>

<output_format>
[expected structure]
</output_format>
```

### Multimodal Input (Gemini)
```json
{
  "contents": [{
    "parts": [
      {"text": "Describe what's in this image."},
      {"inline_data": {"mime_type": "image/jpeg", "data": "[base64]"}}
    ]
  }]
}
```

### Current Events Query (Grok)
```
What's the latest on [topic] according to posts on X? Give me a summary of the current sentiment.
```

## Model Selection Guide

| Use Case | Recommended Model | Why |
|----------|-------------------|-----|
| **Long document analysis** | Claude Sonnet 4.5 | 1M context, extended thinking |
| **Multimodal understanding** | Gemini 3 Pro | Native multimodal architecture |
| **Current events/news** | Grok | Real-time X (Twitter) access |
| **Code generation** | Claude Sonnet 4.5 or Opus 4.5 | SOTA coding capabilities |
| **Structured JSON output** | Gemini 3 Flash | JSON schema validation |
| **Creative writing** | Grok | Witty, less constrained |
| **Agentic workflows** | Claude Sonnet 4.5 | Parallel tool use |
| **System instruction needs** | Gemini 3 Flash/Pro | Primary feature |
| **Instruction following** | Claude Sonnet 4.5 | Best in class |

## See Also

### Reference Documentation
- `references/basics.md` - Foundational prompt engineering concepts
- `references/techniques.md` - Detailed technique explanations
- `references/claude.md` - Claude-specific XML patterns
- `references/gemini.md` - Gemini system instruction patterns
- `references/grok.md` - Grok conversational patterns
- `references/multimodal.md` - Multimodal prompting guide
- `references/examples.md` - Concrete examples and templates

### Related Skills
- `engineering-discipline` - Core principles for sustainable code
- `task-decomposition` - Breaking down complex tasks
- `orchestration` - Intelligent tool selection and execution
