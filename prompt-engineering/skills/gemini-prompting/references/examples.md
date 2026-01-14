# Gemini Prompt Examples

Real-world examples demonstrating effective Gemini prompting.

---

## Example 1: System Instruction with Reasoning

**From Official Gemini Documentation**

```json
{
  "system_instruction": {
    "parts": [{
      "text": "You are a very strong reasoner and planner. Use these critical instructions to structure your plans, thoughts, and responses.\n\nBefore taking any action, you must proactively, methodically, and independently plan and reason about:\n\n1) Logical dependencies and constraints\n2) Risk assessment\n3) Abductive reasoning and hypothesis exploration\n4) Outcome evaluation and adaptability\n5) Information availability\n6) Precision and Grounding\n7) Completeness\n8) Persistence and patience\n9) Inhibit your response: only act after completing above reasoning"
    }]
  },
  "contents": [{
    "parts": [{
      "text": "I need to plan a migration from a monolithic architecture to microservices. What should I consider?"
    }]
  }]
}
```

**Why It Works:**
- Comprehensive reasoning framework
- Systematic approach to complex planning
- Prevents premature conclusions
- Ensures thoroughness

---

## Example 2: Multimodal Analysis (Legacy SDK)

```python
import google.generativeai as genai
import PIL.Image

model = genai.GenerativeModel("gemini-2.5-pro")
image = PIL.Image.open("product.jpg")

response = model.generate_content([
    """Analyze this product image and create:

1. **Product Name**: Creative, memorable name
2. **Tagline**: Catchy one-line description
3. **Features**: 5 key features based on what you see
4. **Target Audience**: Who would buy this
```

## Example 2: Multimodal Analysis (New SDK)

```python
from google import genai
import PIL.Image

client = genai.Client()
image = PIL.Image.open("product.jpg")

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents=[
        """Analyze this product image and create:

1. **Product Name**: Creative, memorable name
2. **Tagline**: Catchy one-line description
3. **Features**: 5 key features based on what you see
4. **Target Audience**: Who would buy this
5. **Price Suggestion**: Reasonable price point
6. **Marketing Copy**: 2-paragraph product description

Format as Markdown with proper headers.""",
    image
])
```

---

## Example 3: Long-Context Document Analysis

```json
{
  "system_instruction": {
    "parts": [{
      "text": "You are a legal analyst specializing in contract review and risk identification."
    }]
  },
  "contents": [{
    "parts": [{
      "text": "Review this services agreement and identify:\n\n1. **Unusual Terms**: Anything non-standard\n2. **Risks**: Potential issues for our company\n3. **Missing Protections**: What should be added\n4. **Negotiation Points**: What to push back on\n5. **Overall Assessment**: Favorable or unfavorable\n\n<contract>\n[Full contract - can be hundreds of pages]\n</contract>\n\nOur company is a [company description] and this is for [purpose]."
    }]
  }]
}
```

---

## Example 4: Code Generation with System Instruction

```python
model = genai.GenerativeModel(
    "gemini-2.5-flash",
    system_instruction="""You are a senior Python engineer specializing in:
- Clean, PEP 8 compliant code
- Comprehensive error handling
- Type hints (Python 3.10+)
- Docstrings (Google style)
- Unit test examples

You never write code without proper validation and error handling."""
)

response = model.generate_content("""
Write a Python function that validates and processes credit card information.

Requirements:
- Validate card number using Luhn algorithm
- Identify card type (Visa, Mastercard, Amex)
- Validate expiration date
- Validate CVV length based on card type
- Return (valid: bool, card_type: str, errors: list[str])

Include usage examples and unit tests.
""")
```

---

## Example 5: Video Analysis

```python
import google.generativeai as genai

model = genai.GenerativeModel("gemini-2.5-pro")

video = genai.upload_file("tutorial.mp4")

response = model.generate_content([
    """Analyze this tutorial video and extract:

1. **Topic**: What is being taught
2. **Key Steps**: Chronological list of steps shown
3. **Tools/Technologies**: What software or tools are used
4. **Difficulty Level**: Beginner/Intermediate/Advanced
5. **Prerequisites**: What viewers need to know beforehand
6. **Timestamps**: Key moments with timestamps
7. **Summary**: 2-3 sentence overview

Format as structured Markdown.""",
    video
])
```

---

## Example 6: Comparative Analysis

```
<system_instruction>
You are a technology analyst specializing in cloud infrastructure and cost optimization.
</system_instruction>

Compare AWS Lambda, Google Cloud Functions, and Azure Functions for this use case:

<use_case>
We need to process user-uploaded images:
- Resize to multiple formats
- Apply watermarks
- Store in CDN
- Average 10,000 images/day
- Burst capacity up to 100,000/day
- Cost-sensitive startup
</use_case>

<comparison_criteria>
- Pricing (cold starts, execution time, requests)
- Performance (cold start time, max execution time)
- Ecosystem (integrations, monitoring)
- Scalability (concurrent execution limits)
- Ease of deployment
</comparison_criteria>

<output_format>
## Comparison Table

| Feature | AWS Lambda | Cloud Functions | Azure Functions |
|---------|------------|-----------------|----------------|
| [rows for each criterion] |

## Analysis

### For Our Use Case

**Recommendation**: [which service and why]

**Cost Estimate**: [monthly cost estimate]

**Implementation Notes**: [specific considerations]

**Risks**: [potential issues]
```

---

## Example 7: Research Synthesis with Long Context

```json
{
  "system_instruction": {
    "parts": [{
      "text": "You are a research scientist conducting a literature review on AI safety."
    }]
  },
  "contents": [{
    "parts": [{
      "text": "Synthesize these 50 research papers on AI alignment and safety.\n\n<documents>\n[Papers 1-50 - full text using 1M context]\n</documents>\n\nProvide:\n\n1. **Key Themes**: What are the main research areas?\n2. **Consensus**: What do most researchers agree on?\n3. **Debates**: What are the major disagreements?\n4. **Methodologies**: What approaches are being used?\n5. **Gaps**: What hasn't been studied?\n6. **Future Directions**: Where is the field heading?\n\nCite specific papers when making claims."
    }]
  }]
}
```

---

## Example 8: Educational Content Creation

```
<system_instruction>
You are an expert educator who creates engaging learning materials for programming students.
</system_instruction>

Create an interactive tutorial explaining async/await in JavaScript.

<requirements>
- Target audience: Intermediate JS developers
- Include: concepts, examples, exercises
- Use analogies for complex concepts
- Build from simple to complex
- Include common mistakes
</requirements>

<output_format>
# Tutorial: Async/Await in JavaScript

## Learning Objectives
- [objectives]

## Prerequisites
- [what students need]

## Concepts
### [Concept 1]
[Explanation with analogy]
[Code example]
[Why it matters]

### [Concept 2]
[...]

## Common Mistakes
| Mistake | Why It's Wrong | Correct Approach |
|---------|---------------|-----------------|
| [table of mistakes]

## Practice Exercises
### Exercise 1: [title]
[problem]
<details>
<summary>Solution</summary>
[solution code]
</details>

## Summary
[key takeaways]

## Further Reading
[resources]
</output_format>
```

---

## Example 9: Strategic Planning

```json
{
  "system_instruction": {
    "parts": [{
      "text": "You are a strategic planning consultant with 20 years of experience helping tech companies scale."
    }]
  },
  "contents": [{
    "parts": [{
      "text": "Create a 12-month strategic plan for our SaaS startup.\n\n<current_state>\n- Product: B2B project management tool\n- Stage: Series A, $5M ARR\n- Team: 30 people\n- Growth: 15% MoM\n- Churn: 5% monthly\n- CAC: $500\n- LTV: $3,000\n</current_state>\n\n<goals>\n1. Reach $15M ARR\n2. Reduce churn to 3%\n3. Launch enterprise tier\n4. Expand to EU market\n</goals>\n\nProvide:\n- Q1-Q4 priorities\n- Key metrics to track\n- Team hiring plan\n- Budget allocation\n- Risk mitigation\n\nBe specific and actionable."
    }]
  }]
}
```

---

## Example 10: Multimodal RAG

```python
model = genai.GenerativeModel("gemini-2.5-pro")

# Reference materials
logo = genai.upload_file("company-logo.png")
style_guide = genai.upload_file("brand-guidelines.pdf")

response = model.generate_content([
    """Create marketing copy for our new product launch.

<context>
Our brand is: [company description]
Our audience is: [target demographic]
This product is: [product details]
</context>

<brand_guidelines>
Based on the attached style guide and logo, ensure the copy:
- Matches our tone (professional yet approachable)
- Uses our color scheme terminology
- Aligns with our brand values
</brand_guidelines>

Create:
1. Headline (5-7 words)
2. Subheadline (one sentence)
3. 3 bullet point benefits
4. Call-to-action

Ensure everything feels authentic to our brand.""",
    logo,
    style_guide
])
```

---

## Example 11: Data Analysis Pattern

```
<system_instruction>
You are a data scientist and business analyst.
</system_instruction>

<dataset>
[Large dataset - can use up to 1M tokens]
</dataset>

<analysis_request>
Perform exploratory data analysis and provide:

1. **Data Overview**: Structure, dimensions, types
2. **Summary Statistics**: Key metrics by category
3. **Patterns**: Trends, correlations, anomalies
4. **Insights**: Business-relevant findings
5. **Recommendations**: Data-driven suggestions
6. **Visualizations**: Suggested charts/plots with descriptions
</analysis_request>

<output_format>
## Data Overview
[summary of dataset]

## Summary Statistics
| Metric | Value |
|--------|-------|
[statistics table]

## Key Findings

### Trend 1: [description]
- **Evidence**: [supporting data]
- **Impact**: [business implication]
- **Action**: [recommendation]

### Trend 2: [...]

## Anomalies
[unexpected findings worth investigating]

## Recommendations
Prioritized list of actions based on insights.
</output_format>
```

---

## Example 12: Agent Reasoning for Complex Tasks

```json
{
  "system_instruction": {
    "parts": [{
      "text": "You are an autonomous agent that plans and executes complex multi-step tasks. Before taking any action:\n\n1. **Plan**: Break down the task into steps\n2. **Dependencies**: Identify what each step needs\n3. **Risks**: Consider what could go wrong\n4. **Alternatives**: Have backup plans\n\nOnly after thorough planning, execute the steps systematically."
    }]
  },
  "contents": [{
    "parts": [{
      "text": "Help me migrate this WordPress site to a headless architecture with Next.js.\n\n<current_site>\n- URL: example.com\n- Posts: 1,200\n- Pages: 50\n- Plugins: 15 active\n- Theme: Custom\n- Traffic: 50k monthly visitors\n</current_site>\n\nPlan and execute the migration considering:\n- Content migration\n- SEO preservation\n- Performance optimization\n- Downtime minimization\n- Rollback plan"
    }]
  }]
}
```

---

## Example Analysis Table

| Example | Key Techniques | Why Effective |
|---------|---------------|---------------|
| 1. System Instruction | Agent reasoning framework | Systematic thinking |
| 2. Multimodal | Image + structured output | Clear formatting requirements |
| 3. Long Context | Full document analysis | Leverages 1M token window |
| 4. Code Generation | System instruction for standards | Consistent code quality |
| 5. Video Analysis | Timestamped extraction | Structured video understanding |
| 6. Comparison | Criteria-based evaluation | Framework-driven analysis |
| 7. Research Synthesis | Pattern recognition across papers | Comprehensive synthesis |
| 8. Educational | Progressive difficulty | Learning-oriented structure |
| 9. Strategic Planning | 12-month breakdown | Actionable business planning |
| 10. Multimodal RAG | Brand consistency | Combines multiple references |
| 11. Data Analysis | Statistical + business | Technical + practical |
| 12. Agent Planning | Multi-step reasoning | Complex task breakdown |

## Key Takeaways

1. **System Instructions** are powerful for setting behavior
2. **Long Context** enables analysis not possible elsewhere
3. **Multimodal** combinations create unique capabilities
4. **Structured Output** ensures consistent formatting
5. **Agent Reasoning** pattern improves complex task handling
6. **Few-Shot** examples guide format and style
