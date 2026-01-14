# Claude XML-Style Formatting Guide

Official XML tag patterns from Anthropic's documentation and courses.

---

## Why XML Tags for Claude?

Claude's official documentation and training materials extensively use XML-style tags because they:
- Provide clear structure and separation
- Help Claude understand prompt organization
- Enable effective long-context prompting
- Match Anthropic's recommended best practices

---

## Core XML Tags

### `<task>` or `<instruction>`
**Purpose**: Define what Claude should do

```xml
<task>
Extract all email addresses from the following text.
</task>
```

```xml
<instruction>
Summarize this document in 3-5 bullet points.
</instruction>
```

### `<context>`
**Purpose**: Provide background information

```xml
<context>
You are a technical writer specializing in API documentation for developers.
</context>

<task>
Write documentation for this endpoint...
</task>
```

### `<input>` or `<input_text>`
**Purpose**: The actual data to process

```xml
<task>
Classify the sentiment of this review.
</task>

<input_text>
I've been waiting months for this feature! Absolutely love it!
</input_text>
```

### `<output>` or `<output_format>`
**Purpose**: Specify expected output structure

```xml
<output_format>
JSON with keys: "sentiment", "confidence", "keywords"
</output_format>
```

```xml
<output>
{
  "sentiment": "[positive/negative/neutral]",
  "confidence": [1-10],
  "keywords": ["keyword1", "keyword2"]
}
</output>
```

---

## Complex Structures

### `<examples>`
**Purpose**: Few-shot learning demonstrations

```xml
<examples>
<example>
<input>
The conference is March 15, 2025 in San Francisco.
</input>
<output>
{"date": "2025-03-15", "event": "conference", "location": "San Francisco"}
</output>
</example>

<example>
<input>
Meeting on June 22nd at the main office.
</input>
<output>
{"date": "2025-06-22", "event": "meeting", "location": "main office"}
</output>
</example>
</examples>
```

### `<document>`
**Purpose**: Long-form content (Claude's 200K context shines here)

```xml
<task>
Summarize the key findings from this research paper.
</task>

<document>
[entire paper - up to 200K tokens]
</document>

<output_format>
<summary>
[executive summary]
</summary>

<key_findings>
<finding>[finding 1]</finding>
<finding>[finding 2]</finding>
</key_findings>
</output_format>
```

### `<thinking>`
**Purpose**: Show Claude's reasoning (works with Extended Thinking or naturally)

```xml
<thinking>
Let me break this down:

1. First, I need to identify the core issue...
2. Then consider the available options...
3. Evaluate each option against the criteria...
4. Make a recommendation...

The key factors are...
</thinking>

<answer>
[final response]
</answer>
```

---

## Hierarchical Prompt Structure

From Anthropic's official courses:

```xml
<!-- 1. Task Context - Overall setting -->
<task_context>
You are analyzing customer feedback for a SaaS product to identify common pain points and feature requests.
</task_context>

<!-- 2. Tone Context - How to approach -->
<tone_context>
Be analytical but empathetic to user frustrations. Look for patterns, not isolated incidents.
</tone_context>

<!-- 3. Input Data - The actual data -->
<input_data>
<feedback_list>
<feedback>
User: "I can't figure out how to export my data. This should be easier."
Date: 2025-01-10
</feedback>
<feedback>
User: "Love the product but the dark mode hurts my eyes. Need better contrast."
Date: 2025-01-09
</feedback>
<!-- more feedback... -->
</feedback_list>
</input_data>

<!-- 4. Examples - Few-shot demonstrations -->
<examples>
<example>
<input>User: "Can't find the settings button anywhere."</input>
<analysis>
Category: UX/Navigation
Severity: Medium
Pattern: UI discoverability issue
</analysis>
</example>
</examples>

<!-- 5. Task Description - Specific instructions -->
<task_description>
Categorize each piece of feedback and identify recurring themes. Group related issues together.
</task_description>

<!-- 6. Immediate Task - What to do now -->
<immediate_task>
Analyze the feedback and produce a summary report.
</immediate_task>

<!-- 7. Output Formatting - Expected structure -->
<output_formatting>
<report>
<summary>[brief overview]</summary>
<themes>
<theme>
<name>[theme name]</name>
<count>[how many mentions]</count>
<examples>[example quotes]</examples>
</theme>
</themes>
<priorities>
<priority>
<issue>[description]</priority>
<severity>[high/medium/low]</severity>
<suggested_action>[recommendation]</suggested_action>
</priority>
</priorities>
</report>
</output_formatting>
```

---

## Special Purpose Tags

### `<constraints>`
**Purpose**: Limit what Claude should do

```xml
<constraints>
- Output must be under 500 words
- Use only provided information (no external knowledge)
- Maintain neutral, objective tone
- Do not include speculative statements
</constraints>
```

### `<role>` or `<persona>`
**Purpose**: Define Claude's role/persona

```xml
<role>
You are a senior software engineer conducting a code review. You are:
- Thorough but constructive
- Focused on correctness and maintainability
- Aware of performance implications
</role>
```

### `<rules>` or `<guidelines>`
**Purpose**: Behavioral guidelines

```xml
<guidelines>
1. Always cite sources when making claims
2. Indicate confidence levels for uncertain information
3. Offer alternative viewpoints when appropriate
4. Flag potential ethical concerns
</guidelines>
```

### `<formatting>`
**Purpose**: Style guidelines

```xml
<formatting>
- Use Markdown for structure
- Include headers for major sections
- Use code blocks for technical content
- Include tables for comparison data
</formatting>
```

---

## Working with Data

### `<data>` or `<dataset>`
**Purpose**: Structured data input

```xml
<task>
Find the top 3 products by revenue.
</task>

<data>
<products>
<product>
<name>Widget A</name>
<revenue>125000</revenue>
<units_sold>500</units_sold>
</product>
<product>
<name>Gadget B</name>
<revenue>89000</revenue>
<units_sold>445</units_sold>
</product>
<!-- more products -->
</products>
</data>
```

### `<schema>`
**Purpose**: Define output schema

```xml
<schema>
{
  "type": "object",
  "properties": {
    "summary": {"type": "string"},
    "findings": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "category": {"type": "string"},
          "description": {"type": "string"},
          "priority": {"type": "string"}
        }
      }
    }
  }
}
</schema>
```

---

## Prefilling Claude's Response

Start the output tag to guide format:

```xml
<task>
Analyze this user's request and categorize it.
</task>

<user_message>
I've been trying to reset my password but I'm not receiving the email. I've checked spam and tried multiple times.
</user_message>

<output>
<analysis>
Category: Account & Authentication

Subcategory: Password Reset

Severity: High (user cannot access account)

Details:
- User not receiving password reset email
- Has checked spam folder
- Multiple attempts failed
</analysis>

<suggested_response>
[Claude continues from here]
```

---

## Cache Control with XML

Optimize repeated prompts:

```xml
<cached_content cache_control='{"type": "ephemeral", "ttl": "1h"}'>
<system_prompt>
You are a customer support agent for [company]. You are:
- Friendly and empathetic
- Solution-oriented
- Knowledgeable about our products
</system_prompt>

<product_information>
[large product catalog that doesn't change]
</product_information>

<support_policies>
[support policies and procedures]
</support_policies>
</cached_content>

<task>
Handle this customer inquiry:
</task>

<customer_message>
[specific customer message - varies each time]
</customer_message>
```

---

## Common Patterns

### Document Analysis Pattern
```xml
<task>[analysis task]</task>
<document>[content]</document>
<output_format>[format]</output_format>
```

### Extraction Pattern
```xml
<task>[what to extract]</task>
<input_text>[source text]</input_text>
<output_format>[desired format]</output_format>
```

### Classification Pattern
```xml
<task>[classification task]</task>
<item>[item to classify]</item>
<categories>[valid categories]</categories>
<output_format>[format]</output_format>
```

### Generation Pattern
```xml
<task>[what to generate]</task>
<requirements>[specific requirements]</requirements>
<constraints>[limitations]</constraints>
<output_format>[format]</output_format>
```

---

## Tag Reference Table

| Tag | Purpose | When to Use |
|-----|---------|-------------|
| `<task>` | Define what to do | Almost every prompt |
| `<context>` | Provide background | Setting, persona, scenario |
| `<input>` | Data to process | Extraction, analysis tasks |
| `<output>` | Specify format | Format-sensitive tasks |
| `<examples>` | Few-shot learning | When format/examples matter |
| `<document>` | Long content | Doc analysis, summarization |
| `<thinking>` | Show reasoning | Complex problems, Extended Thinking |
| `<constraints>` | Limit behavior | Need to restrict output |
| `<role>` | Define persona | When Claude has a specific role |
| `<data>` | Structured input | Working with datasets |
| `<schema>` | Output structure | Complex output requirements |

---

## Best Practices

1. **Be Consistent**: Use the same tag names throughout your prompts
2. **Nest Appropriately**: Put related content in parent tags
3. **Close All Tags**: Always close tags properly
4. **Use Descriptive Names**: `<user_feedback>` vs `<data>`
5. **Keep Readable**: Proper indentation for complex structures
6. **Escape Content**: Use `<![CDATA[...]]>` for content with XML characters
