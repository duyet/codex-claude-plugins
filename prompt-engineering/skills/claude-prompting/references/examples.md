# Claude Prompt Examples

Real-world examples from Anthropic's official courses and documentation.

---

## Example 1: Call Transcript Analysis

**From Anthropic Courses - Real World Prompting**

```xml
<task>
Analyze this customer support call transcript and extract structured information.
</task>

<transcript>
Agent: Thank you for calling Acme Smart Home Support. This is Alex. How may I assist you today?
Customer: Hi Alex, my Acme SmartTherm isn't maintaining the temperature I set. It's set to 72 but the house is much warmer.
Agent: I'm sorry to hear that. Let's troubleshoot. Is your SmartTherm connected to Wi-Fi?
Customer: Yes, the Wi-Fi symbol is showing on the display.
Agent: Great. Let's recalibrate your SmartTherm. Press and hold the menu button for 5 seconds.
Customer: Okay, done. A new menu came up.
Agent: Perfect. Navigate to "Calibration" and press select. Adjust the temperature to match your room thermometer.
Customer: Alright, I've set it to 79 degrees to match.
Agent: Great. Press select to confirm. It will recalibrate, which may take a few minutes. Check back in an hour to see if it's fixed.
Customer: Okay, I'll do that. Thank you for your help, Alex.
Agent: You're welcome! Is there anything else I can assist you with today?
Customer: No, that's all. Thanks again.
Agent: Thank you for choosing Acme Smart Home. Have a great day!
</transcript>

<examples>
<example>
<transcript>
[previous complete interaction example]
</transcript>

<analysis>
Main issue: SmartTherm not maintaining set temperature
Resolution: Guided customer through recalibration process
Follow-up: Not required, but customer should check effectiveness after an hour
Ambiguities: None identified
</analysis>

<output>
{
  "summary": {
    "customerIssue": "SmartTherm not maintaining set temperature",
    "resolution": "Guided customer through SmartTherm recalibration process",
    "followUpRequired": false,
    "followUpDetails": null
  },
  "status": "COMPLETE",
  "ambiguities": []
}
</output>
</example>

<example>
[insufficient data example]
</example>
</examples>

<output_format>
<analysis>
Main issue: [identify the problem]
Resolution: [how it was resolved]
Follow-up: [is follow-up needed?]
Ambiguities: [unclear information]
</analysis>

<json>
{
  "summary": {
    "customerIssue": "[issue description]",
    "resolution": "[how resolved]",
    "followUpRequired": [boolean],
    "followUpDetails": "[details or null]"
  },
  "status": "[COMPLETE/INSUFFICIENT_DATA]",
  "ambiguities": ["[list any ambiguities]"]
}
</json>
</output_format>
```

**Why It Works:**
- XML structure for clear organization
- Examples show exact output format expected
- Handles edge cases (insufficient data)
- Clear categorization of transcript elements

---

## Example 2: Document QA with Prompt Chaining

**From Anthropic Documentation**

### Step 1: Extract Relevant Quotes

```xml
<task>
You are a helpful assistant. Your task is to help answer a question given in a document.

The first step is to extract quotes relevant to the question from the document, delimited by ####.

Please output the list of quotes using <quotes></quotes> tags.

Respond with "No relevant quotes found!" if no relevant quotes were found.

####
[document text]
####
</task>

<question>
What are the main prompting techniques mentioned in the document?
</question>
```

**Response:**
```xml
<quotes>
<quote>Chain-of-thought (CoT) prompting</quote>
<quote>Generated knowledge prompting</quote>
<quote>Least-to-most prompting</quote>
<quote>Self-consistency decoding</quote>
<quote>Complexity-based prompting</quote>
</quotes>
```

### Step 2: Synthesize Answer

```xml
<task>
Given a set of relevant quotes (delimited by <quotes></quotes>) extracted from a document and the original document (delimited by ####), please compose an answer to the question.

Ensure that the answer is accurate, has a friendly tone, and sounds helpful.
</task>

<question>
What are the main prompting techniques mentioned in the document?
</question>

####
[original document]
####

<quotes>
[from Step 1 response]
</quotes>
```

**Why It Works:**
- Breaks complex task into verifiable steps
- Each step has clear output format
- Can debug intermediate results
- Reduces complexity of individual prompts

---

## Example 3: Code Review with Structured Output

```xml
<role>
You are a senior Python engineer conducting a code review. You are thorough but constructive, focused on correctness, maintainability, and performance.
</role>

<task>
Review this Python function for correctness, style, and best practices.
</task>

<code>
```python
def calculate_discount(price, customer_type):
    if customer_type == "vip":
        return price * 0.8
    elif customer_type == "regular":
        return price * 0.95
    else:
        return price
```
</code>

<output_format>
<review>
<summary>
[overall assessment - 1-2 sentences]
</summary>

<issues>
<issue>
<severity>[critical/major/minor]</severity>
<location>[function/line]</location>
<description>[what's wrong]</description>
<suggestion>[how to fix]</suggestion>
</issue>
</issues>

<positives>
<positive>[what's done well]</positive>
</positives>

<improved_version>
```python
[improved code with fixes]
```
</improved_version>
</review>
</output_format>
```

**Expected Response:**
```xml
<review>
<summary>
The function works correctly but lacks input validation, documentation, and flexibility for discount rates.
</summary>

<issues>
<issue>
<severity>major</severity>
<location>function signature</location>
<description>No type hints or docstring documenting parameters and return value</description>
<suggestion>Add type hints and comprehensive docstring</suggestion>
</issue>
<issue>
<severity>major</severity>
<location>price parameter</location>
<description>No validation that price is a positive number</description>
<suggestion>Add validation: if price <= 0: raise ValueError</suggestion>
</issue>
<issue>
<severity>minor</severity>
<location>customer_type parameter</location>
<description>Hardcoded discount rates make function inflexible</description>
<suggestion>Consider accepting discount rates as parameters or using a configuration dict</suggestion>
</issue>
</issues>

<positives>
<positive>Clear, simple logic that's easy to understand</positive>
<positive>Handles all customer_type cases with else clause</positive>
</positives>

<improved_version>
```python
from typing import Literal

def calculate_discount(
    price: float,
    customer_type: Literal["vip", "regular", "guest"]
) -> float:
    """
    Calculate discounted price based on customer type.

    Args:
        price: Original price (must be positive)
        customer_type: Type of customer ("vip", "regular", or "guest")

    Returns:
        Discounted price

    Raises:
        ValueError: If price is not positive
    """
    if price <= 0:
        raise ValueError("Price must be positive")

    discount_rates = {
        "vip": 0.20,      # 20% discount
        "regular": 0.05,  # 5% discount
        "guest": 0.00     # No discount
    }

    discount = discount_rates.get(customer_type, 0.00)
    return price * (1 - discount)
```
</improved_version>
</review>
```

---

## Example 4: Data Extraction with Schema

```xml
<task>
Extract structured event information from the following text.
</task>

<input_text>
The annual Tech Summit 2025 will be held at the Moscone Center in San Francisco from March 15-17. Early bird registration is open until February 1st at $499. Regular pricing is $699. The event features keynote speakers from major tech companies and workshops on AI, cloud computing, and cybersecurity. Contact events@techsummit.com for more information.
</input_text>

<schema>
{
  "type": "object",
  "properties": {
    "event_name": {"type": "string"},
    "dates": {
      "type": "object",
      "properties": {
        "start": {"type": "string"},
        "end": {"type": "string"}
      }
    },
    "location": {
      "type": "object",
      "properties": {
        "venue": {"type": "string"},
        "city": {"type": "string"}
      }
    },
    "pricing": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "tier": {"type": "string"},
          "price": {"type": "number"},
          "deadline": {"type": "string"}
        }
      }
    },
    "topics": {"type": "array", "items": {"type": "string"}},
    "contact": {"type": "string"}
  }
}
</schema>

<output_format>
JSON matching the above schema
</output_format>
```

**Expected Response:**
```json
{
  "event_name": "Tech Summit 2025",
  "dates": {
    "start": "March 15, 2025",
    "end": "March 17, 2025"
  },
  "location": {
    "venue": "Moscone Center",
    "city": "San Francisco"
  },
  "pricing": [
    {
      "tier": "early_bird",
      "price": 499,
      "deadline": "February 1, 2025"
    },
    {
      "tier": "regular",
      "price": 699,
      "deadline": null
    }
  ],
  "topics": ["AI", "cloud computing", "cybersecurity"],
  "contact": "events@techsummit.com"
}
```

---

## Example 5: Extended Thinking for Complex Reasoning

```xml
<thinking_budget_tokens>8192</thinking_budget_tokens>

<task>
A company has 100 employees distributed across 3 departments: Engineering (40 people), Sales (35 people), and Operations (25 people).

The company needs to form a cross-functional committee of 8 people with these requirements:
- At least 2 people from each department
- Exactly 1 committee chair (from any department)
- At least 3 people total from Engineering + Sales combined

How many different ways can the committee be formed?

Show your reasoning step by step.
</task>

<output_format>
<thinking>
[detailed reasoning process]
</thinking>

<answer>
[final answer with explanation]
</answer>
</output_format>
```

**Claude's Extended Thinking Output:**
```xml
<thinking>
Let me break this down systematically.

First, I need to understand the constraints:
- Total committee size: 8 people
- Minimum from each department: 2 people
- Exactly 1 chair (from any department)
- Engineering + Sales combined: at least 3 people

Let me think about the department distributions first...

The minimum distribution is 2-2-2 (Engineering-Sales-Operations), which uses 6 people.
We need 2 more people to reach 8.

The Engineering + Sales requirement of at least 3 means:
- If we have 2 Engineering and 2 Sales, that's 4 - which satisfies the requirement
- If we have 2 Engineering and 1 Sales (minimum), that's 3 - which satisfies
- If we have 1 Engineering and 2 Sales (minimum), that's 3 - which satisfies

So the E+S constraint is automatically satisfied by the "at least 2 from each" constraint.

[continues with detailed combinatorial analysis...]
</thinking>

<answer>
To solve this, I need to consider the distribution of committee members across departments, then account for the chair selection.

**Step 1: Department Distributions**

The constraint "at least 2 from each department" means we start with 2-2-2 (6 people) and need to add 2 more from any departments.

Possible distributions (E-S-O):
1. 4-2-2
2. 3-3-2
3. 3-2-3
4. 2-4-2
5. 2-3-3
6. 2-2-4

[continues with calculation...]

**Total: 1,353,120 different ways to form the committee**
</answer>
```

---

## Example 6: ReAct Pattern for Research

```xml
<task>
Research and answer: What were the key factors that led to the success of the iPhone when it launched in 2007?
</task>

<thought_1>
To answer this question comprehensively, I need to consider:
1. The technological context of 2007
2. What existing phones were like
3. What the iPhone introduced that was new
4. Market reception and reviews
5. Sales figures and impact

Let me start by researching the state of smartphones before the iPhone.
</thought_1>

<action_1>
<tool>search</tool>
<query>smartphone market before iPhone 2007 BlackBerry Nokia Windows Mobile</query>
</action_1>

<observation_1>
[search results showing phones required physical keyboards, styluses, had limited web browsing, etc.]
</observation_1>

<thought_2>
Now I understand the baseline. Let me research what the iPhone actually introduced and how it was different.
</thought_2>

<action_2>
<tool>search</tool>
<query>iPhone original launch features 2007 multi-touch touchscreen App Store mobile Safari</query>
</action_2>

<observation_2>
[search results about capacitive touchscreen, pinch-to-zoom, full web browsing, visual voicemail, iPod integration]
</observation_2>

<thought_3>
Now let me look at the initial reception and reviews to understand how it was perceived at launch.
</thought_3>

<action_3>
<tool>search</tool>
<query>iPhone 2007 launch reviews reception critics "Jesus phone" Walter Mossberg</query>
</action_3>

<observation_3>
[results about overwhelmingly positive reviews, "device that changed everything", etc.]
</observation_3>

<final_answer>
Based on my research, the key factors that led to the iPhone's success were:

**1. Revolutionary User Interface**
- Capacitive multi-touch screen (no stylus needed)
- Intuitive pinch-to-zoom and gesture controls
- Fluid, responsive animations

**2. Full Internet Experience**
- Mobile Safari that showed real web pages (not mobile versions)
- Best-in-class web browsing on a phone

**3. Integration of Multiple Devices**
- Combined iPod + phone + internet communicator
- Eliminated need to carry multiple devices

**4. Software Ecosystem Vision**
- App Store announced (though not available at launch)
- Set foundation for third-party applications

**5. Timing and Market Context**
- Existing smartphones were complex and required styluses
- BlackBerry focused on enterprise, not consumers
- Nokia and Windows Mobile had poor user experiences

The iPhone didn't just incrementally improve phones—it redefined what a phone could be.
</final_answer>
```

---

## Example 7: Few-Shot for Text Classification

```xml
<task>
Classify the customer support ticket into one of these categories:
- "technical_issue"
- "billing_question"
- "feature_request"
- "account_management"
</task>

<examples>
<example>
<input>
I can't log into my account. I keep getting "invalid password" even though I'm sure I'm using the right one.
</input>
<output>
{"category": "account_management", "confidence": 0.95, "reason": "Login/authentication issue"}
</output>
</example>

<example>
<input>
How much does the Pro plan cost? I don't see pricing on your website.
</input>
<output>
{"category": "billing_question", "confidence": 0.90, "reason": "Pricing inquiry"}
</output>
</example>

<example>
<input>
It would be great if you could add dark mode. The white background hurts my eyes at night.
</input>
<output>
{"category": "feature_request", "confidence": 0.98, "reason": "Suggestion for new functionality"}
</output>
</example>

<example>
<input>
The export to CSV feature isn't working. When I click it, nothing happens.
</input>
<output>
{"category": "technical_issue", "confidence": 0.92, "reason": "Functionality not working as expected"}
</output>
</example>
</examples>

<input>
I'd like to upgrade my subscription from Basic to Pro. How do I do that?
</input>

<output>
```

---

## Example Analysis Table

| Example | Key Techniques | Why Effective |
|---------|---------------|---------------|
| 1. Call Analysis | Few-shot, XML structure, edge cases | Shows exact output format |
| 2. Document QA | Prompt chaining, XML delimiters | Breaks complex task into steps |
| 3. Code Review | Role definition, structured output | Clear review criteria |
| 4. Event Extraction | Schema definition, precise format | Eliminates ambiguity |
| 5. Committee Math | Extended thinking, step-by-step | Shows reasoning process |
| 6. iPhone Research | ReAct pattern, thought-action-observation | Systematic research approach |
| 7. Ticket Classification | Few-shot with confidence levels | Shows classification reasoning |

---

## Key Takeaways from Anthropic's Examples

1. **XML Structure is Universal**: All official examples use XML-style tags
2. **Examples Drive Format**: Few-shot examples are crucial for format-sensitive tasks
3. **Break Down Complexity**: Prompt chaining for multi-step tasks
4. **Specify Everything**: Output format, constraints, requirements
5. **Handle Edge Cases**: Examples should cover what to do with insufficient data
6. **Show Reasoning**: Extended thinking or structured reasoning for complex tasks
7. **Use Roles**: Define Claude's persona for specialized tasks
