# Prompt Engineering Techniques

Detailed explanations of prompt engineering techniques and when to use them.

## 1. Zero-Shot Prompting

**Definition:** Giving the model a task without any examples.

**When to Use:**
- Straightforward, well-defined tasks
- Tasks the model has seen frequently during training
- When examples aren't necessary for understanding

**Example:**
```
Translate this text to French:
Hello, how are you today?
```

**Pros:**
- Simple and direct
- Works well for common tasks
- Minimal token usage

**Cons:**
- May fail for complex or unfamiliar tasks
- Output format may be inconsistent
- Higher chance of misunderstandings

## 2. Few-Shot Prompting (Multishot)

**Definition:** Providing examples (shots) to demonstrate the desired pattern.

**When to Use:**
- Classification tasks
- Transformation tasks with specific format requirements
- When output consistency is critical
- For complex or ambiguous instructions

**Optimal Number of Shots:**
- **2-3 shots**: Usually sufficient for clear patterns
- **5+ shots**: For complex patterns with edge cases
- **More isn't always better**: Can confuse or waste context

**Example Structure:**
```xml
<examples>
<example>
<input>[input 1]</input>
<output>[expected output 1]</output>
</example>
<example>
<input>[input 2]</input>
<output>[expected output 2]</output>
</example>
</examples>

<input>
[actual input]
</input>

<output>
```

**Best Practices:**
- Use diverse examples covering edge cases
- Match example complexity to task complexity
- Keep examples consistent in format
- Place examples immediately before the actual task

## 3. Chain-of-Thought (CoT) Prompting

**Definition:** Asking the model to show its reasoning step by step.

**When to Use:**
- Mathematical reasoning
- Logic puzzles
- Complex decision-making
- Multi-step problems

**Implementation Methods:**

### Explicit CoT
```
Let's think step by step:

[problem]
```

### Zero-Shot CoT
```
[problem]

Let's work through this methodically:
```

### Structured CoT (Claude)
```xml
<task>
[complex problem]
</task>

<thinking>
[Show reasoning here]
</thinking>

<answer>
[Final answer]
</answer>
```

**Model-Specific Notes:**
- **Claude**: Use Extended Thinking API feature for best results
- **Gemini**: Use `thinking_config` parameter
- **Grok**: Natural language "Let's think through this" works well

## 4. Prompt Chaining

**Definition:** Breaking complex tasks into sequential prompts, feeding output of one into input of next.

**When to Use:**
- Very complex tasks that would exceed single prompt capacity
- When you need to verify or adjust intermediate results
- For multi-stage workflows

**Example Chain:**

**Prompt 1:**
```
Extract all company names from this document.
```

**Prompt 2 (using output from 1):**
```
For each company extracted, categorize by industry.
```

**Prompt 3:**
```
Summarize the industry breakdown with statistics.
```

**Best Practices:**
- Verify intermediate outputs before chaining
- Keep individual prompts focused
- Document the chain for reproducibility
- Consider saving intermediate results

## 5. ReAct (Reasoning + Acting)

**Definition:** Iterative loop of Thought → Action → Observation.

**When to Use:**
- Tasks requiring tool use
- Research with multiple information sources
- Problem-solving with unknown factors
- Agent workflows

**Pattern:**
```
[Question/Task]

Thought 1: [What I need to do first]
Action 1: [Tool or search to perform]
Observation 1: [Result from action]
Thought 2: [What to do next based on observation]
Action 2: [Next action]
...
Final Answer: [Conclusion]
```

**Best Practices:**
- Make thoughts explicit and clear
- Use specific actions (not vague ones)
- Always synthesize observations into next thought
- End with clear final answer

## 6. Tree of Thoughts (ToT)

**Definition:** Exploring multiple reasoning paths before selecting the best one.

**When to Use:**
- Creative problem-solving
- Strategic planning
- Tasks with multiple valid approaches
- When exploration is valuable

**Pattern:**
```
[Problem]

Let's explore different approaches:

Approach 1: [Description]
Reasoning: [Step-by-step]
Expected Outcome: [What would happen]

Approach 2: [Description]
Reasoning: [Step-by-step]
Expected Outcome: [What would happen]

Approach 3: [Description]
Reasoning: [Step-by-step]
Expected Outcome: [What would happen]

Synthesis: [Which approach is best and why]
```

**Best Practices:**
- Ensure approaches are genuinely different
- Consider edge cases in each path
- Be explicit about evaluation criteria
- Use for exploration, not just confirmation

## 7. Self-Consistency

**Definition:** Running the same prompt multiple times and selecting the most common answer.

**When to Use:**
- Critical tasks requiring high confidence
- Mathematical or logical problems
- When consistency matters more than speed

**Implementation:**
1. Run prompt N times (3-5 is typical)
2. Collect all outputs
3. Select most frequent answer (majority vote)
4. Optionally, have model explain reasoning for selection

## 8. Generated Knowledge

**Definition:** First generating relevant knowledge, then using that knowledge to answer.

**When to Use:**
- Tasks requiring domain knowledge
- When model might lack specific information
- For improving accuracy on specialized topics

**Pattern:**
```
Step 1: Generate relevant knowledge about [topic]

Step 2: Using the knowledge above, answer:
[question]
```

## 9. Least-to-Most Prompting

**Definition:** Decomposing complex problems into simpler sub-problems, solving sequentially.

**When to Use:**
- Multi-step math problems
- Complex reasoning tasks
- When earlier steps inform later ones

**Pattern:**
```
[Complex problem]

Questions we need to answer:
1. [Sub-problem 1]
2. [Sub-problem 2]
3. [Sub-problem 3]

Answer 1: [Solution to sub-problem 1]

Using Answer 1, Answer 2: [Solution to sub-problem 2]

Using Answer 2, Answer 3: [Solution to sub-problem 3]
```

## 10. Role Prompting

**Definition:** Assigning a specific role or persona to the model.

**When to Use:**
- Wanting specific expertise or perspective
- Tailoring tone and style
- For specialized domains

**Examples:**
```
You are a senior software engineer conducting a code review.
You are a creative copywriter at an ad agency.
You are a patient teacher explaining to a beginner.
You are a skeptical analyst evaluating claims.
```

**Best Practices:**
- Be specific about the role's expertise
- Define the role's communication style
- Match role to the task requirements
- Combine with other techniques for best results

## Technique Selection Guide

| Technique | Best For | Complexity | Model Preference |
|-----------|----------|------------|------------------|
| Zero-Shot | Simple, common tasks | Low | All |
| Few-Shot | Format consistency | Low-Medium | All |
| CoT | Reasoning, math, logic | Medium | Claude (Extended Thinking) |
| Chaining | Multi-stage workflows | High | All |
| ReAct | Tool use, research | High | All |
| ToT | Creative exploration | Medium-High | Grok (creative), Claude |
| Self-Consistency | Critical accuracy | Medium | All |
| Least-to-Most | Multi-step problems | High | Claude, Gemini |

## Combining Techniques

Most effective prompts combine multiple techniques:

**Example Combination (Few-Shot + CoT + Role):**
```
You are a data analyst specializing in customer behavior analysis.

Here are examples of how to analyze customer feedback:

Example 1:
Feedback: "The app crashes every time I try to upload"
Analysis: This is a critical bug affecting core functionality. Priority: High, Category: Technical Issue

Example 2:
Feedback: "I wish the dark mode was darker"
Analysis: This is a feature request, not a bug. Priority: Low, Category: Enhancement

Now analyze this feedback step by step:
"The new update is confusing, I can't find anything"
```

## Common Pitfalls

1. **Over-complicating**: Don't use complex techniques when simple will work
2. **Inconsistent examples**: Ensure few-shot examples follow the same pattern
3. **Unclear thoughts**: In CoT, thoughts should be explicit and clear
4. **Too many branches**: ToT with 5+ branches becomes unmanageable
5. **Missing verification**: Always verify outputs in critical applications
