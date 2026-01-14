---
name: claude-prompting
description: Prompt engineering guidance for Claude (Anthropic) model. Use when crafting prompts for Claude to leverage XML-style tags, long-context capabilities, extended thinking, and strong instruction following.
---

# Claude Prompt Engineering

Claude is Anthropic's AI assistant designed to be helpful, harmless, and honest. It excels at long-context tasks, follows complex instructions precisely, and works best with well-structured prompts using XML-style tags.

## When to Invoke This Skill

Use this skill when:
- Crafting prompts specifically for Claude/Anthropic models (default: Claude Sonnet 4.5)
- Working with long documents or large context (up to 1M tokens with Sonnet 4.5 beta)
- Using structured prompts with XML-style tags
- Implementing extended thinking for complex reasoning
- Requiring precise instruction following
- Building agentic workflows with parallel tool use

## Claude's Identity & Characteristics

| Attribute | Description |
|-----------|-------------|
| **Personality** | Helpful, harmless, honest |
| **Constitutional AI** | Built-in safety and ethical guidelines |
| **Context Window** | Up to 1M tokens (Sonnet 4.5 beta), 200K standard |
| **Strengths** | Long-context analysis, instruction following, document understanding, agentic tasks |
| **Prompt Style** | Structured, clear, XML-style formatting |
| **Extended Thinking** | Optional reasoning trace feature with tool use |

## Universal Prompting Techniques (Claude-Adapted)

### 1. Zero-Shot Prompting

Claude responds well to clear, direct zero-shot prompts.

**Good Example:**
```
Extract the key dates and events from the following text:

<text>
[paste text]
</text>

Output format: JSON with keys "date", "event", "description"
```

**Less Effective:**
```
Can you tell me what dates are in this text?
```

### 2. Few-Shot Prompting (Multishot)

Use well-formatted examples with XML structure.

```
<examples>
<example>
<input>
The conference is scheduled for March 15, 2025 in San Francisco.
</input>
<output>
{
  "date": "2025-03-15",
  "event": "conference",
  "location": "San Francisco"
}
</output>
</example>

<example>
<input>
Our next board meeting is on June 22nd.
</input>
<output>
{
  "date": "2025-06-22",
  "event": "board meeting"
}
</output>
</examples>

<input>
The product launches on September 1st in New York.
</input>

<output>
```

### 3. Chain-of-Thought Prompting

Claude has an **Extended Thinking** feature that shows reasoning (enabled via API, output in response):

```
I need to decide between these two job offers. Let me think through this step by step.

<job_offer_a>
[details]
</job_offer_a>

<job_offer_b>
[details]
</job_offer_b>

Please analyze both offers, show your reasoning, and provide a recommendation.
```

**API enables extended thinking; response includes:**
```
<thinking>
First, let me analyze the compensation...
Then consider the growth potential...
The work-life balance factors are...
The company stability differs by...
</thinking>

<answer>
[conclusion]
</answer>
```

### 4. Zero-Shot CoT

Simply add "Let's think step by step" or similar:

```
What's the most efficient route to visit all these cities?

Let's think step by step.
```

### 5. Prompt Chaining with XML Tags

Break complex tasks using XML delimiters:

**Chain Step 1:**
```
<task>
Extract relevant quotes from this document related to [topic].
</task>

<document>
[paste document]
</document>

<output_format>
<quotes>
<quote>[relevant quote 1]</quote>
<quote>[relevant quote 2]</quote>
</quotes>
</output_format>
```

**Chain Step 2:**
```
<task>
Summarize the extracted quotes and synthesize key insights.
</task>

<quotes>
[from previous response]
</quotes>

<output_format>
<summary>
[executive summary]
</summary>

<key_insights>
<insight>[insight 1]</insight>
<insight>[insight 2]</insight>
</key_insights>
</output_format>
```

### 6. ReAct Prompting

Use structured thought-action-observation cycles:

```
<question>
[research question]
</question>

<thought_1>
[what needs to be done first]
</thought_1>

<action_1>
[tool use or information gathering]
</action_1>

<observation_1>
[result from action]
</observation_1>

<thought_2>
[next step based on observation]
</thought_2>

<final_answer>
[conclusion]
</final_answer>
```

### 7. Tree of Thoughts

Use multiple reasoning paths with XML structure:

```
<problem>
[complex problem]
</problem>

<thought_paths>
<path_1>
<assumption>[approach 1]</assumption>
<reasoning>[step-by-step]</reasoning>
<conclusion>[result]</conclusion>
</path_1>

<path_2>
<assumption>[approach 2]</assumption>
<reasoning>[step-by-step]</reasoning>
<conclusion>[result]</conclusion>
</path_2>

<path_3>
<assumption>[approach 3]</assumption>
<reasoning>[step-by-step]</reasoning>
<conclusion>[result]</conclusion>
</path_3>
</thought_paths>

<synthesis>
[best path and why]
</synthesis>
```

## Claude-Specific Best Practices

### 1. Use XML-Style Tags for Structure

Claude's official courses extensively use XML tags:

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
[expected format]
</output_format>
```

### 2. Structure Long Prompts Hierarchically

From Anthropic's official courses:

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

### 3. Leverage Extended Thinking

For complex reasoning, enable Claude's extended thinking via the API:

**API Syntax (Python SDK):**
```python
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={
        "type": "enabled",
        "budget_tokens": 8192
    },
    messages=[{
        "role": "user",
        "content": "Analyze this complex problem..."
    }]
)
```

**Prompt-Side (XML structure for expected output):**
```
<task>
[complex reasoning task]
</task>

<thinking>
[Claude will show its reasoning here]
</thinking>

<answer>
[final answer]
</answer>
```

**Key Points:**
- `budget_tokens` sets max tokens for reasoning (must be < `max_tokens`)
- Claude 4.5 returns summarized thinking by default
- First few lines are more verbose (useful for prompt engineering)
- You're billed for full thinking tokens, not summary tokens

### 4. Use System Prompts Effectively

System prompts set Claude's behavior:

```
System: You are a technical writer specializing in API documentation. Your responses are always:
- Clear and concise
- Technically accurate
- Formatted with Markdown
- Focused on developer needs

User: [your actual query]
```

### 5. Prefill Claude's Response

Guide the format by starting Claude's response:

```
<task>
Analyze this document and extract key findings.
</task>

<document>
[paste document]
</document>

<response>
<summary>
[Claude continues from here]
```

### 6. Cache Control for Long Prompts

Optimize for repeated prompts:

```
<cached_content cache_control="{\"type\":\"ephemeral\"}">
[large context that doesn't change]
</cached_content>

<task>
[specific task that varies]
</task>
```

### 7. Claude 4.5 Agent Features

Claude 4.5 introduces powerful agent capabilities:

**Parallel Tool Use** - Claude can use multiple tools simultaneously:
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

**Memory Files** - Claude can maintain knowledge across sessions:
```xml
<task>
When working on ongoing projects, create a memory file to track:
- Key decisions and rationale
- Project context and constraints
- Preferences and patterns
</task>

Claude will automatically update and reference memory files when given local file access.
```

**Extended Thinking with Tools** - Reasoning can pause to use tools:
```python
# API: Enable extended thinking with tool use
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={
        "type": "enabled",
        "budget_tokens": 8192
    },
    tools=[web_search_tool],
    messages=[{
        "role": "user",
        "content": "Research [topic] and provide a comprehensive analysis."
    }]
)

# Claude can now use web search DURING extended thinking,
# alternating between reasoning and information gathering.
```

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Fails | Better Approach |
|--------------|--------------|-----------------|
| Ambiguous instructions | Claude follows literally | Be explicit about requirements |
| Missing output format | Unpredictable formatting | Always specify format |
| No structure in long prompts | Claude may lose track | Use XML tags and sections |
| Ignoring context window limits | Truncation issues | Be mindful of 200K/1M limits |
| Over-constraining creativity | Reduces Claude's helpfulness | Balance structure with flexibility |

## Quick Reference Templates

### Document Analysis
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

### Code Generation with Examples
```xml
<task>
Write a function that [description]
</task>

<requirements>
[specific requirements]
</requirements>

<examples>
<example>
<input>[input example]</input>
<output>[expected output]</output>
</example>
</examples>

<output_format>
[code in specified language]
</output_format>
```

### Data Extraction
```xml
<task>
Extract [specific fields] from the following text
</task>

<input_text>
[paste text]
</input_text>

<output_format>
JSON with keys: [list keys]
</output_format>
```

### Extended Thinking
```python
# API: Enable extended thinking
response = client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,
    thinking={
        "type": "enabled",
        "budget_tokens": 8192
    },
    messages=[{
        "role": "user",
        "content": """
<task>
[complex reasoning task]
</task>

Please show your reasoning step by step, then provide the final answer.
"""
    }]
)

# Response will include <thinking> block followed by <answer>
```

## Model Capabilities Reference

| Feature | Claude Sonnet 4.5 | Claude Haiku 4.5 | Claude Opus 4.5 | Notes |
|---------|-------------------|-----------------|-----------------|-------|
| **Context Window** | 200K / 1M (beta) | 200K | 200K | Sonnet 4.5: 1M with beta header |
| **Extended Thinking** | ✅ Yes | ✅ Yes | ✅ Yes | With tool use support |
| **Max Output** | 64K tokens | 64K tokens | 64K tokens | Unified across 4.5 |
| **Vision** | ✅ Yes | ✅ Yes | ✅ Yes | Image analysis |
| **Parallel Tool Use** | ✅ Yes | ✅ Yes | ✅ Yes | Claude 4.5 feature |
| **Memory Files** | ✅ Yes | ✅ Yes | ✅ Best | Local file knowledge |
| **Code** | ✅ Excellent | ✅ Good | ✅ Best | Opus 4.5: SOTA coding |
| **Speed** | Fast | Fastest | Moderate | Default: Sonnet 4.5 |

> **Recommendation**: Start with **Claude Sonnet 4.5** - best balance of intelligence, speed, and cost for most use cases. Use Opus 4.5 for complex coding, Haiku 4.5 for speed-critical tasks.

## Migration Notes (Claude 3 → 4.5)

If you're migrating from Claude 3.x to Claude 4.5:

| Change | Impact | Action |
|--------|--------|--------|
| **Default model** | Sonnet 3.5 → Sonnet 4.5 | Update model IDs in code |
| **Context window** | 200K → 1M (beta) available | Requires beta header for 1M |
| **Parallel tools** | New capability | Update prompts to leverage parallel execution |
| **Memory files** | New capability | Grant file access for persistent knowledge |
| **Extended thinking + tools** | New capability | Can now use tools during reasoning |
| **Max output** | 8K → 64K tokens | Adjust output expectations |

**API Migration:**
```python
# Old (Claude 3.5)
model="claude-sonnet-3-5-20240620"

# New (Claude 4.5)
model="claude-sonnet-4-5-20250929"  # or use alias "claude-sonnet-4-5"
```

Most prompting techniques remain unchanged—XML tags, system prompts, and structured outputs work identically.

## Prompt Element Checklist

When creating Claude prompts, consider including:

- [ ] **Task Context**: Overall purpose and setting
- [ ] **Tone Context**: How Claude should approach it
- [ ] **Input Data**: The actual content to process
- [ ] **Examples**: Few-shot demonstrations (if needed)
- [ ] **Task Description**: Specific instructions
- [ ] **Immediate Task**: What to do right now
- [ ] **Output Format**: Expected structure
- [ ] **Prefill**: Start of Claude's response (optional)

## See Also

- `references/basics.md` - Foundational Claude prompting concepts
- `references/techniques.md` - Detailed technique explanations
- `references/xml-formatting.md` - XML tag patterns and usage
- `references/patterns.md` - Reusable Claude prompt patterns
- `references/examples.md` - Concrete examples from Anthropic courses
- `grok-prompting` skill - For Grok/xAI-specific guidance
- `gemini-prompting` skill - For Google Gemini-specific guidance
