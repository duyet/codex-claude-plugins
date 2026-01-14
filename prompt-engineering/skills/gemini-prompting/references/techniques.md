# Gemini Prompt Engineering - Techniques

Detailed guide to universal prompting techniques adapted specifically for Gemini.

---

## 1. Zero-Shot Prompting

### What It Is
Asking Gemini to perform a task without providing examples.

### Gemini-Specific Approach
Gemini excels at zero-shot when paired with effective system instructions.

### Examples

**Simple Query:**
```python
from google import genai

client = genai.Client()
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Explain the difference between supervised and unsupervised machine learning."
)
```

**With System Instruction:**
```python
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Classify this customer review sentiment.",
    config=genai.types.GenerateContentConfig(
        system_instruction="You are a sentiment analyst. Classify text as positive, negative, or neutral."
    )
)
```

**Structured Output Request:**
```python
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="""
Extract the following information from this text:
- Company names
- Technologies mentioned
- Key challenges

Text: [paste text]

Output as JSON.
"""
)
```

### Tips
- Always specify output format when structure matters
- Use system instructions to set behavior
- Be explicit about requirements
- Leverage Gemini's instruction following

---

## 2. Few-Shot Prompting

### What It Is
Providing examples to guide Gemini's responses through in-context learning.

### Gemini-Specific Approach
Use clear, well-formatted examples. Gemini learns patterns from demonstrations.

### Template

```python
from google import genai

client = genai.Client()

examples = """
Example 1:
Input: This product is amazing!
Output: {"sentiment": "positive", "confidence": 0.95}

Example 2:
Input: Terrible experience, would not recommend.
Output: {"sentiment": "negative", "confidence": 0.92}

Example 3:
Input: It's okay, does what it says.
Output: {"sentiment": "neutral", "confidence": 0.75}
"""

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents=examples + "\nInput: The delivery was fast and the quality is great!\nOutput:"
)
```

### Example: Code Style

```python
response = client.models.generate_content(
    model="gemini-2.5-flash",
    config=genai.types.GenerateContentConfig(
        system_instruction="You are a Python code formatter following PEP 8 standards."
    ),
    contents="""
Here are examples of properly formatted Python code:

Example 1:
def calculate_sum(a,b):return a+b

Formatted:
def calculate_sum(a: int, b: int) -> int:
    \"\"\"Calculate the sum of two integers.\"\"\"
    return a + b

Example 2:
def get_user(id):return db.query(f'SELECT * FROM users WHERE id={id}')

Formatted:
def get_user(user_id: int) -> User:
    \"\"\"Retrieve a user by ID from the database.\"\"\"
    query = 'SELECT * FROM users WHERE id = ?'
    return db.query(query, (user_id,)).fetchone()

Now format this code:
def process(data):results=[transform(x)for x in data if x];return results
"""
)
```

### Tips
- 3-5 examples usually sufficient
- Examples should cover edge cases
- Format examples exactly as you want output
- Show both input and expected output clearly

---

## 3. Chain-of-Thought Prompting

### What It Is
Prompting Gemini to show its reasoning step-by-step.

### Gemini-Specific Approach
Use explicit reasoning prompts. Gemini's strong reasoning capabilities shine with structured CoT.

### Template

```python
response = client.models.generate_content(
    model="gemini-2.5-flash",
    config=genai.types.GenerateContentConfig(
        system_instruction="You are a strong reasoner. Always show your step-by-step thinking process."
    ),
    contents="""
The odd numbers in this group add up to an even number: 4, 8, 9, 15, 12, 2, 1.

Let's think through this systematically:
"""
)
```

### Example: Math Problem

```python
response = client.models.generate_content(
    model="gemini-2.5-pro",
    contents="""
A train leaves Station A at 2:00 PM traveling at 60 mph. Another train leaves Station B at 3:00 PM traveling at 80 mph toward Station A. The stations are 300 miles apart.

At what time do the trains meet?

Think through this step by step:
1. Identify what we know
2. Determine when both trains are moving
3. Calculate the combined speed
4. Find the meeting time

Show your work.
"""
)
```

### Example: Logical Reasoning

```python
response = client.models.generate_content(
    model="gemini-2.5-pro",
    contents="""
If all Bloops are Razzles and all Razzles are Lazzles, then all Bloops are definitely Lazzles.

Is this reasoning valid? Think through it step by step:

1. Understand the given premises
2. Identify the logical structure
3. Apply transitive property
4. Verify the conclusion

Explain each step.
"""
)
```

### Tips
- Use "step by step" or "systematically" as triggers
- For complex problems, enumerate the steps
- Gemini Pro is better for complex reasoning
- Useful for math, logic, planning problems

---

## 4. Zero-Shot CoT

### What It Is
Adding a simple phrase to trigger reasoning without examples.

### Gemini-Specific Triggers

| Trigger | Best For |
|---------|----------|
| "Think step by step" | Sequential reasoning |
| "Let's work through this systematically" | Structured analysis |
| "Show your reasoning" | Explanatory responses |
| "Walk me through your thinking" | Teaching/explaining |
| "Break this down" | Complex problems |

### Examples

```python
# Math problem
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="""
If 3 machines can produce 15 widgets in 6 minutes, how many widgets can 5 machines produce in 12 minutes?

Let's think step by step.
"""
)

# Decision making
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="""
Should I invest in index funds or individual stocks?

Let's work through this systematically by considering:
- Risk tolerance
- Time horizon
- Investment goals
- Market conditions
"""
)

# Debugging
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="""
This code is throwing a NullReferenceException. Help me debug it.

[code]

Walk me through your reasoning process.
"""
)
```

### Tips
- Simple addition to any prompt
- Effective for both simple and complex tasks
- Combine with system instruction for consistency
- Pro model gives deeper reasoning

---

## 5. Prompt Chaining

### What It Is
Breaking complex tasks into sequential prompts, where each prompt's output informs the next.

### Gemini-Specific Advantage
Ultra-long context (1M+ tokens) enables extensive chaining without losing context.

### Example: Document Analysis Chain

**Chain Step 1: Extract**
```python
response1 = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="""
<task>
Extract all mentions of "AI safety" and "alignment" from this document.
</task>

<document>
[paste large document]
</document>

<output_format>
Extract relevant quotes using <quote> tags.
</output_format>
"""
)
extracted_quotes = response1.text
```

**Chain Step 2: Synthesize**
```python
response2 = client.models.generate_content(
    model="gemini-2.5-flash",
    contents=f"""
<task>
Synthesize these extracted quotes into key themes about AI safety.
</task>

<quotes>
{extracted_quotes}
</quotes>

<output_format>
<themes>
<theme>
<name>[theme name]</name>
<summary>[description]</summary>
<related_quotes>[list]</related_quotes>
</theme>
</themes>
</output_format>
"""
)
themes = response2.text
```

**Chain Step 3: Generate Report**
```python
response3 = client.models.generate_content(
    model="gemini-2.5-pro",
    contents=f"""
<task>
Create a comprehensive report on AI safety based on the themes extracted.
</task>

<themes>
{themes}
</themes>

<original_document>
[paste document]
</original_document>

<output_format>
<report>
<executive_summary>[2-3 paragraphs]</executive_summary>
<key_findings>[bullet points]</key_findings>
<recommendations>[action items]</recommendations>
</report>
</output_format>
"""
)
```

### Benefits
- Each step is verifiable
- Can adjust based on intermediate results
- Reduces complexity of individual prompts
- Leverages Gemini's long context window

### Tips
- Use clear delimiters between chain steps
- Pass full context when needed (Gemini can handle it)
- Document the chain for reproducibility
- Can run chains in parallel if independent

---

## 6. ReAct Prompting (Reason + Act)

### What It Is
Interleaving reasoning with actions (tool use, API calls, searches).

### Gemini's Strength
Excellent tool use with native function calling support.

### Pattern

```python
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="""
<question>
What is the current stock price of NVIDIA and what was the price one week ago?
</question>

<thought_1>
I need to find current NVIDIA stock information and historical data from one week ago.
</thought_1>

<action_1>
<tool>search</tool>
<query>NVDA stock price today current</query>
</action_1>

<observation_1>
[search result with current price]
</observation_1>

<thought_2>
Now I need to find the price from one week ago. One week ago from today was [specific date].
</thought_2>

<action_2>
<tool>search</tool>
<query>NVDA stock price [date one week ago]</query>
</action_2>

<observation_2>
[historical price data]
</observation_2>

<thought_3>
I now have both pieces of information. Let me calculate the difference and provide the answer.
</thought_3>

<final_answer>
Based on my search:
- Current NVDA price: [current price]
- Price one week ago: [past price]
- Change: [difference and percentage]
</final_answer>
"""
)
```

### With Actual Function Calling

```python
from google import genai
from google.genai import types

client = genai.Client()

# Define tools
get_weather = types.FunctionDeclaration(
    name="get_weather",
    description="Get current weather for a location",
    parameters=types.Schema(
        type=types.Type.OBJECT,
        properties={
            "location": types.Schema(
                type=types.Type.STRING,
                description="City name, e.g., San Francisco"
            )
        },
        required=["location"]
    )
)

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="What's the weather like in Tokyo and Paris?",
    config=types.GenerateContentConfig(
        tools=[get_weather]
    )
)
```

### Tips
- Gemini handles tool natively with function calling
- Specify clear thought/action/observation structure
- Useful for research, data gathering, multi-step tasks
- Flash model is fast and capable for most ReAct patterns

---

## 7. Tree of Thoughts (ToT)

### What It Is
Exploring multiple reasoning paths before concluding, with lookahead and backtracking.

### Gemini-Specific Approach
Use structured XML to organize thought branches. Gemini's strong reasoning excels at exploration.

### Template

```python
response = client.models.generate_content(
    model="gemini-2.5-pro",
    contents="""
<problem>
Our startup needs to choose a pricing strategy. Options: freemium, free trial, or paid-only.
We have $50K in funding, 5K active users, and 20% month-over-month growth.
</problem>

<thought_paths>
<path_1>
<strategy>Freemium</strategy>
<reasoning>
Pros:
- Largest user base potential
- Data collection for product improvement
- Network effects

Cons:
- High conversion costs
- Free users don't pay
- Support burden

Expected: 50K free users, 500 paying (1% conversion)
Revenue: $500/month at $10/month
</reasoning>
<expected_outcome>
Large user base but low revenue initially. Break-even in ~20 months.
</expected_outcome>
</path_1>

<path_2>
<strategy>Free Trial (14 days)</strategy>
<reasoning>
Pros:
- Higher conversion rates than freemium
- Users experience full value
- Clear upgrade path

Cons:
- Smaller top of funnel
- Users may not sign up without free tier

Expected: 10K trial users, 2K paying (20% conversion)
Revenue: $20,000/month at $10/month
</reasoning>
<expected_outcome>
Smaller user base but better revenue. Break-even in ~3 months.
</expected_outcome>
</path_2>

<path_3>
<strategy>Paid-Only ($29/month)</strategy>
<reasoning>
Pros:
- Revenue from day one
- Serious, committed users
- Lower support costs

Cons:
- Highest barrier to entry
- Smallest total addressable market

Expected: 2K paying users directly
Revenue: $58,000/month
</reasoning>
<expected_outcome>
Highest immediate revenue but slowest growth.
</expected_outcome>
</path_3>
</thought_paths>

<recommendation>
For our situation ($50K funding, need runway), I recommend:

<strong>Free Trial (14 days)</strong>

Rationale:
1. Within our runway constraints
2. 20% conversion is realistic for our product
3. $20K/month gives us 7.5 months of runway
4. Can pivot to freemium later if needed

<strong>Not recommended:</strong> Paid-only (too risky for our stage) or Freemium (burns cash too fast)
</recommendation>
"""
)
```

### Example: Technical Decision

```python
response = client.models.generate_content(
    model="gemini-2.5-pro",
    contents="""
<problem>
We need to choose a database for our new SaaS application:
- 100K daily active users expected
- Heavy read workload (95% reads, 5% writes)
- Need real-time analytics
- Budget: $2K/month for infrastructure
</problem>

<thought_paths>
<path_1>
<choice>PostgreSQL with read replicas</choice>
<analysis>
Strengths:
- Mature, reliable
- ACID compliance
- Good for complex queries

Weaknesses:
- Write scaling is vertical only
- Real-time analytics requires separate system
- Cost scales with load

Cost estimate: $1,500/month for primary + replicas
</analysis>
<verdict>Good fit, but analytics will need separate solution</verdict>
</path_1>

<path_2>
<choice> MongoDB with sharding</choice>
<analysis>
Strengths:
- Horizontal scaling
- Good write performance
- Flexible schema

Weaknesses:
- No joins for complex queries
- Eventual consistency
- Higher operational complexity

Cost estimate: $1,200/month for sharded cluster
</analysis>
<verdict>Strong candidate if we can handle eventual consistency</verdict>
</path_2>

<path_3>
<choice>Amazon Aurora PostgreSQL</choice>
<analysis>
Strengths:
- Auto-scaling storage
- Read replicas up to 15
- 5x performance improvement
- Managed service

Weaknesses:
- Vendor lock-in
- Higher cost per compute
- Learning curve

Cost estimate: $1,800/month
</analysis>
<verdict>Over budget but excellent capabilities</verdict>
</path_3>

<path_4>
<choice>PostgreSQL + Redis + ClickHouse</choice>
<analysis>
Strengths:
- PostgreSQL for transactional data
- Redis for caching (reduces DB load)
- ClickHouse for real-time analytics

Weaknesses:
- Three systems to manage
- Data synchronization complexity
- Higher operational overhead

Cost estimate: $1,000/month total

<analysis>
Most flexible solution within budget
</analysis>
</path_4>
</thought_paths>

<synthesis>
<recommendation>
<path_4>PostgreSQL + Redis + ClickHouse</path_4>

<justification>
1. Fits within $2K budget at $1K/month
2. Meets all requirements: transactions, real-time analytics, read-heavy workload
3. Industry-standard stack (PostgreSQL) with proven caching strategy (Redis)
4. ClickHouse is purpose-built for real-time analytics
5. Room to grow within budget constraints

<implementation_plan>
Phase 1: PostgreSQL + Redis (start)
Phase 2: Add ClickHouse when analytics needs grow
Phase 3: Scale PostgreSQL read replicas as needed
</implementation_plan>

<risks>
- Operational complexity of three systems
- Mitigation: Use managed services (RDS, ElastiCache, ClickHouse Cloud)
</risks>
</justification>
</recommendation>
</synthesis>
"""
)
```

### Tips
- Use Gemini Pro for complex ToT (better reasoning)
- Structure thoughts clearly with XML
- Consider 2-5 paths (not too many)
- Include expected outcomes for each path
- Provide clear recommendation with justification

---

## Technique Selection Guide for Gemini

| Scenario | Best Technique | Why |
|----------|---------------|-----|
| Quick question | Zero-shot | Fast, direct |
| Format-sensitive task | Few-shot | Shows exact pattern |
| Complex reasoning | CoT or Zero-Shot CoT | Shows thinking process |
| Multi-step workflow | Prompt chaining | Verifiable steps |
| Research with tools | ReAct | Tool calling support |
| Strategic exploration | Tree of Thoughts | Explores options |
| Large document analysis | Zero-shot + chaining | 1M context handles it |
| Image analysis | Zero-shot + system instruction | Multimodal native |
| Code generation | Zero-shot + few-shot | Strong code capabilities |

---

## Advanced: Combining Techniques

### Few-Shot + CoT

```python
response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="""
Here are examples of how I want you to reason through problems:

Example 1:
Input: If it takes 5 machines 5 minutes to make 5 widgets, how long for 100 machines to make 100 widgets?
Reasoning:
- Each machine makes 1 widget in 5 minutes
- 100 machines operating simultaneously
- Each makes 1 widget in 5 minutes
- Total: 5 minutes
Answer: 5 minutes

Example 2:
Input: A bat and ball cost $1.10. The bat costs $1.00 more than the ball. How much does the ball cost?
Reasoning:
- Let ball cost = x
- Then bat cost = x + $1.00
- Total: x + (x + $1.00) = $1.10
- 2x + $1.00 = $1.10
- 2x = $0.10
- x = $0.05
Answer: The ball costs $0.05

Now solve this showing your reasoning:
Input: 3 machines can produce 15 widgets in 6 minutes. How many widgets can 5 machines produce in 12 minutes?
"""
)
```

### Prompt Chaining + ReAct

```python
# Step 1: Research
response1 = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="""
<task>
Research the latest developments in AI regulation in the EU.
</task>

<thought_1>
I need to search for current EU AI regulations and recent updates.
</thought_1>

<action_1>
<tool>search</tool>
<query>EU AI Act 2025 latest developments compliance</query>
</action_1>
"""
)

# Step 2: Analyze
response2 = client.models.generate_content(
    model="gemini-2.5-flash",
    contents=f"""
<task>
Analyze the research findings and identify key compliance requirements for a startup.
</task>

<research_findings>
{response1.text}
</research_findings>

<thought>
I need to extract the most relevant requirements for a small AI startup.
</thought>
"""
)

# Step 3: Recommend
response3 = client.models.generate_content(
    model="gemini-2.5-pro",
    contents=f"""
<task>
Provide actionable compliance recommendations based on the analysis.
</task>

<analysis>
{response2.text}
</analysis>

<context>
We are a 10-person AI startup building a content moderation tool.
</context>
"""
)
```

### Tree of Thoughts + Multimodal

```python
response = client.models.generate_content(
    model="gemini-2.5-pro",
    config=genai.types.GenerateContentConfig(
        system_instruction="You are a UX consultant analyzing design options."
    ),
    contents=[
        "Analyze these three UI mockups and recommend the best approach:",

        "\n\n<thought_paths>",

        "\n<path_1>",
        "\n<mockup_a_description>",
        "\n<analysis>",
        "\nStrengths: Clean layout, clear CTA",
        "\nWeaknesses: Low information density",
        "\n</analysis>",
        "\n</path_1>",

        "\n<path_2>",
        "\n<mockup_b_description>",
        "\n<analysis>",
        "\nStrengths: High information density",
        "\nWeaknesses: May overwhelm users",
        "\n</analysis>",
        "\n</path_2>",

        "\n<path_3>",
        "\n<mockup_c_description>",
        "\n<analysis>",
        "\nStrengths: Balanced approach",
        "\nWeaknesses: CTA not prominent enough",
        "\n</analysis>",
        "\n</path_3>",

        "\n</thought_paths>",

        "\n<recommendation>",
        "\nChoose path_3 with modifications: increase CTA prominence.",
        "\n</recommendation>"
    ]
)
```

---

## Troubleshooting

### Issue: Not Following Instructions

**Symptoms:** Gemini ignores format requirements or constraints.

**Solutions:**
1. Move requirements to system instruction
2. Be more specific about output format
3. Use few-shot examples to demonstrate
4. Use explicit output tags like `<output_format>`

### Issue: Too Verbose

**Symptoms:** Responses are longer than needed.

**Solutions:**
1. Add verbosity constraint to system instruction
2. Specify word/character limits
3. Use "be concise" in task description
4. Use Flash model (faster, more concise)

### Issue: Missing Key Information

**Symptoms:** Responses omit important details.

**Solutions:**
1. Provide comprehensive examples
2. List all required output fields
3. Use CoT to force thorough reasoning
4. Ask for specific details explicitly

### Issue: Inconsistent Format

**Symptoms:** Output format varies between requests.

**Solutions:**
1. Use few-shot examples
2. Specify exact output structure
3. Use JSON schema with structured outputs
4. Add format validation in system instruction
