# Claude Prompt Engineering - Techniques

Detailed guide to universal prompting techniques adapted specifically for Claude.

---

## 1. Zero-Shot Prompting

### What It Is
Asking Claude to perform a task without examples.

### Claude-Specific Approach
Claude excels at zero-shot when prompts are clear and well-structured.

### Examples

**Simple Extraction:**
```xml
<task>
Extract all product names and prices from the following text.
</task>

<input_text>
The iPhone 15 Pro costs $999, while the Samsung Galaxy S24 is priced at $899. The Google Pixel 8 comes in at $699.
</input_text>

<output_format>
JSON list of objects with "product" and "price" keys
</output_format>
```

**Analysis:**
```xml
<task>
Analyze the sentiment of this customer review.
</task>

<review>
I've been waiting for this feature for months! Absolutely love it and can't imagine going back.
</review>

<output_format>
Sentiment: [positive/negative/neutral]
Confidence: [1-10]
Key phrases: [list]
</output_format>
```

### Tips
- Always specify output format
- Use XML tags for structure
- Be explicit about requirements

---

## 2. Few-Shot Prompting (Multishot)

### What It Is
Providing examples to guide Claude's responses.

### Claude-Specific Approach
Use XML structure to organize examples clearly.

### Template

```xml
<task>
[description of what Claude should do]
</task>

<examples>
<example>
<input>[example input]</input>
<output>[expected output]</output>
</example>

<example>
<input>[example input]</input>
<output>[expected output]</output>
</example>
</examples>

<input>
[actual input to process]
</input>

<output>
[Claude completes here]
```

### Example: Text Classification

```xml
<task>
Classify the following email as "urgent", "normal", or "low_priority" based on its content.
</task>

<examples>
<example>
<input>
Subject: Meeting tomorrow
Hi, just confirming our meeting at 2pm tomorrow.
</input>
<output>
{"classification": "normal", "reason": "Routine scheduling matter"}
</output>
</example>

<example>
<input>
Subject: URGENT: Server down!!!
Production server is not responding. Need immediate assistance!
</input>
<output>
{"classification": "urgent", "reason": "Production system down"}
</output>
</example>

<example>
<input>
Subject: Monthly newsletter
Here's our monthly update with company news and events.
</input>
<output>
{"classification": "low_priority", "reason": "Routine informational content"}
</output>
</example>
</examples>

<input>
Subject: Quick question about the report
Hey, I had a question about one section in the Q3 report. When you have a chance...
</input>

<output>
```

### Tips
- 3-5 examples usually sufficient
- Examples should cover edge cases
- Format examples exactly as you want output

---

## 3. Chain-of-Thought Prompting

### What It Is
Prompting Claude to show its reasoning step-by-step.

### Claude-Specific Approach
Use the **Extended Thinking** feature or XML-structured reasoning.

### Option A: Extended Thinking (API)

```json
{
  "model": "claude-3-5-sonnet-20241022",
  "max_tokens": 4096,
  "thinking": {
    "type": "enabled",
    "budget_tokens": 8192
  },
  "messages": [
    {"role": "user", "content": "Solve this complex problem..."}
  ]
}
```

### Option B: XML-Structured Reasoning

```xml
<task>
Determine the most efficient delivery route for these packages.
</task>

<locations>
Warehouse: 123 Main St
Delivery 1: 456 Oak Ave
Delivery 2: 789 Pine Rd
Delivery 3: 321 Elm Blvd
</locations>

<thinking>
First, let me consider the distances between locations...

Then I need to account for traffic patterns at different times...

The package priority/urgency factors are...

Let me calculate the most efficient sequence...
</thinking>

<route>
[final recommendation]
</route>
```

### Example: Math Problem

```xml
<task>
The odd numbers in this group add up to an even number: 15, 32, 5, 13, 82, 7, 1.

Is this true or false? Show your reasoning.
</task>

<thinking>
I need to identify all the odd numbers in the group: 15, 5, 13, 7, 1

Now I'll add them: 15 + 5 = 20, 20 + 13 = 33, 33 + 7 = 40, 40 + 1 = 41

41 is an odd number, not an even number.

Therefore, the statement is false.
</thinking>

<answer>
False. The sum of odd numbers (15, 5, 13, 7, 1) is 41, which is odd.
</answer>
```

### Tips
- Use Extended Thinking for complex reasoning
- Budget tokens must be ≥1024 and < max_tokens
- `<thinking>` tags structure reasoning well

---

## 4. Zero-Shot CoT

### What It Is
Adding a simple phrase to trigger reasoning without examples.

### Claude-Specific Triggers

| Trigger | Best For |
|---------|----------|
| "Let's think step by step" | Sequential reasoning |
| "Walk me through your reasoning" | Explanatory responses |
| "Show your work" | Mathematical/technical problems |
| "Think through this carefully" | Complex analysis |

### Examples

```
A company has 100 employees. If 20% work in engineering, 15% in sales, and the rest in operations, how many work in operations?

Let's think step by step.
```

```
I need to decide between these two software architectures. Here are the requirements...

Walk me through your analysis of each approach.
```

---

## 5. Prompt Chaining

### What It Is
Breaking complex tasks into sequential prompts.

### Claude-Specific Approach
Use XML tags to pass outputs between chain steps.

### Example: Document Analysis Chain

**Step 1: Extract Quotes**
```xml
<task>
Extract all quotes relevant to "artificial intelligence" from the following document.
</task>

<document>
[paste long document]
</document>

<output_format>
<quotes>
<quote>[quote 1]</quote>
<quote>[quote 2]</quote>
</quotes>
</output_format>
```

**Step 2: Summarize**
```xml
<task>
Summarize the extracted quotes and identify key themes.
</task>

<quotes>
[from step 1 output]
</quotes>

<output_format>
<summary>[executive summary]</summary>
<themes>
<theme>[theme 1]</theme>
<theme>[theme 2]</theme>
</themes>
</output_format>
```

**Step 3: Synthesize**
```xml
<task>
Create a final report combining the document content with your analysis.
</task>

<document>
[original document]
</document>

<analysis>
[from step 2]
</analysis>

<output_format>
<report>
<introduction>...</introduction>
<key_findings>...</key_findings>
<conclusion>...</conclusion>
</report>
</output_format>
```

### Benefits
- Each step is verifiable
- Can adjust based on intermediate results
- Reduces complexity of individual prompts
- More transparent process

---

## 6. ReAct Prompting

### What It Is
Interleaving reasoning with actions (tool use).

### Claude's Strength
Excellent tool use and function calling capabilities.

### Pattern

```xml
<question>
[research question]
</question>

<thought_1>
[initial analysis of what's needed]
</thought_1>

<action_1>
<tool_name>[search_tool]</tool_name>
<parameters>
<query>[search query]</query>
</parameters>
</action_1>

<observation_1>
[tool results]
</observation_1>

<thought_2>
[analysis of results and next step]
</thought_2>

<action_2>
[additional tool use if needed]
</action_2>

<final_answer>
[conclusion based on gathered information]
</final_answer>
```

### Example: Research Task

```xml
<question>
What are the current regulations around AI in healthcare in the EU?
</question>

<thought_1>
I need to search for current EU AI regulations, specifically related to healthcare applications.
</thought_1>

<action_1>
<tool>search</tool>
<query>EU AI Act healthcare regulations 2025</query>
</action_1>

<observation_1>
[search results about EU AI Act]
</observation_1>

<thought_2>
The results mention the EU AI Act. I should search for more specific information about healthcare classification and requirements.
</thought_2>

<action_2>
<tool>search</tool>
<query>EU AI Act high-risk AI healthcare classification requirements</query>
</action_2>

<observation_2>
[detailed requirements]
</observation_2>

<final_answer>
Based on my research, the EU AI Act classifies healthcare AI as "high-risk" and requires...
</final_answer>
```

---

## 7. Tree of Thoughts (ToT)

### What It Is
Exploring multiple reasoning paths before concluding.

### Claude-Specific Approach
Use XML to structure thought branches.

### Example: Strategic Decision

```xml
<problem>
Our startup needs to choose a pricing strategy. Options: freemium, free trial, or paid-only.
</problem>

<thought_paths>
<path_1>
<strategy>Freemium</strategy>
<analysis>
Pros:
- Largest user base potential
- Network effects
- Data collection for product improvement

Cons:
- High conversion costs
- Free users don't pay
- Support burden for non-paying users

</analysis>
<expected_outcome>
Large user base but potentially low revenue per user
</expected_outcome>
</path_1>

<path_2>
<strategy>Free Trial</strategy>
<analysis>
Pros:
- Users can experience full value
- Conversion rates typically higher than freemium
- Clear upgrade path

Cons:
- Smaller top of funnel
- Users may not sign up without free tier
- Churn after trial period

</analysis>
<expected_outcome>
Smaller but more qualified user base, better revenue per user
</expected_outcome>
</path_2>

<path_3>
<strategy>Paid-Only</strategy>
<analysis>
Pros:
- Revenue from day one
- Serious, committed users
- Lower support costs

Cons:
- Highest barrier to entry
- Smallest total addressable market
- Harder to prove value before purchase

</analysis>
<expected_outcome>
Smallest but highest-quality user base, maximum revenue per user
</expected_outcome>
</path_3>
</thought_paths>

<recommendation>
For an early-stage B2B SaaS, I recommend [choice] because...

[synthesized reasoning]
</recommendation>
```

---

## Technique Selection Guide for Claude

| Scenario | Best Technique | Why |
|----------|---------------|-----|
| Simple extraction | Zero-shot | Claude's strong instruction following |
| Format-sensitive tasks | Few-shot | Shows exact output structure |
| Complex reasoning | CoT + Extended Thinking | Shows reasoning process |
| Multi-step workflows | Prompt chaining | Verifiable intermediate steps |
| Research with tools | ReAct | Excellent tool use |
| Strategic exploration | Tree of Thoughts | Structures multiple paths |
| Long document analysis | Zero-shot with XML tags | 200K context handles it |

---

## Advanced: Combining Techniques

### Example: Comprehensive Analysis

```xml
<task>
Analyze this competitive landscape and provide strategic recommendations.
</task>

<context>
We are a [company type] entering the [market] market.
</context>

<competitors>
[competitor data]
</competitors>

<examples>
<example>
<analysis>[brief example of desired analysis style]</analysis>
</example>
</examples>

<reasoning_approach>
Let's think through this systematically by analyzing:
1. Each competitor's strengths
2. Each competitor's weaknesses
3. Market gaps
4. Our positioning opportunities
</reasoning_approach>

<output_format>
<analysis>
[competitor analysis]
</analysis>

<opportunities>
[opportunity 1]
[opportunity 2]
</opportunities>

<recommendations>
[priority recommendations]
</recommendations>
</output_format>
```

This combines:
- Few-shot (examples)
- CoT (reasoning approach)
- XML structure (output format)
- Clear context setting
