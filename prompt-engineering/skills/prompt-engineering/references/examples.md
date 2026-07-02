# Prompt Engineering Examples

Concrete examples and templates for common prompt engineering tasks.

## Document Analysis

### Extract Key Information (Claude)
```xml
<task>
Extract all dates, locations, and action items from this meeting transcript.
</task>

<transcript>
[paste transcript]
</transcript>

<output_format>
<meeting_summary>
<date>[meeting date]</date>
<location>[meeting location]</location>
<attendees>
<attendee>[name]</attendee>
</attendees>
<action_items>
<action>
<owner>[person]</owner>
<task>[description]</task>
<deadline>[date]</deadline>
</action>
</action_items>
</meeting_summary>
</output_format>
```

### Summarize Long Document (Gemini)
```json
{
  "system_instruction": {
    "parts": [{"text": "You are a document summarization expert. You create concise, accurate summaries highlighting key points, conclusions, and action items."}]
  },
  "contents": [{
    "parts": [{"text": "Summarize this document in 3 paragraphs:\n\n1. Main topic and purpose\n2. Key findings and insights\n3. Conclusions and recommendations\n\n[document]"}]
  }]
}
```

### Comparative Analysis (Grok)
```
Let's compare these two documents:

[Document 1]

[Document 2]

What are the main differences? Where do they agree? What's the most interesting contrast between them?
```

## Code Generation

### Function with Error Handling (Claude)
```xml
<task>
Write a Python function to validate email addresses.
</task>

<requirements>
- Use regex for pattern matching
- Return tuple: (is_valid: bool, error_message: str)
- Handle edge cases (null, empty string, non-string types)
- Include comprehensive docstring
- Add type hints
</requirements>

<examples>
<example>
<input>validate_email("user@example.com")</input>
<output>(True, "")</output>
</example>
<example>
<input>validate_email("invalid")</input>
<output>(False, "Invalid email format")</output>
</example>
</examples>

<output_format>
Python code with comments explaining the logic.
</output_format>
```

### API Integration (Gemini)
```
<system_instruction>
You are a backend developer specializing in API integrations. You provide clean, production-ready code with proper error handling and logging.
</system_instruction>

Write a Python function to fetch data from a REST API with:
- Exponential backoff on retries
- Timeout handling
- Response validation
- Proper error messages

Endpoint: https://api.example.com/users/{id}
```

### Script with Comments (Grok)
```
Write a bash script that backs up a database. Make it robust with error handling and add some personality to the comments explaining what each part does.

Requirements:
- Backup PostgreSQL database
- Compress with gzip
- Add timestamp to filename
- Clean up backups older than 7 days
```

## Data Extraction

### Structured Data from Text (Claude)
```xml
<task>
Extract product information from these descriptions.
</task>

<input_texts>
<text>
Apple iPhone 15 Pro Max, 256GB, Titanium Blue - $1,199
</text>
<text>
Samsung Galaxy S24 Ultra, 512GB, Phantom Black - $1,299
</text>
</input_texts>

<output_format>
JSON array with objects containing:
- brand (string)
- model (string)
- storage (string)
- color (string)
- price (number, in USD)
</output_format>
```

### Entity Recognition (Gemini)
```json
{
  "system_instruction": {
    "parts": [{"text": "You are an entity extraction specialist. Identify and categorize entities in text."}]
  },
  "contents": [{
    "parts": [{
      "text": "Extract all people, organizations, and locations from this text:\n\n[text]\n\nOutput JSON only.",
      "generation_config": {
        "response_mime_type": "application/json",
        "response_schema": {
          "type": "OBJECT",
          "properties": {
            "people": {"type": "ARRAY", "items": {"type": "STRING"}},
            "organizations": {"type": "ARRAY", "items": {"type": "STRING"}},
            "locations": {"type": "ARRAY", "items": {"type": "STRING"}}
            }
          }
        }
      }
    }]
  }]
}
```

### Sentiment Analysis (Grok)
```
Analyze the sentiment of these reviews and tell me which products are getting love and which are getting hate:

[Review 1]
[Review 2]
[Review 3]

Give me the vibe check for each one.
```

## Creative Tasks

### Marketing Copy (Claude)
```xml
<task>
Write marketing copy for a new product launch.
</task>

<product>
- Name: CloudSync Pro
- Category: File synchronization software
- Key features: Real-time sync, end-to-end encryption, version history
- Target audience: Remote teams and freelancers
</product>

<tone>
Professional yet approachable, emphasizing productivity and security
</tone>

<output_format>
- Headline (catchy, under 10 words)
- Subheadline (value proposition)
- 3 bullet points highlighting key benefits
- Call to action
</output_format>
```

### Brainstorming Ideas (Gemini)
```json
{
  "system_instruction": {
    "parts": [{"text": "You are a creative brainstorming partner. You generate innovative, feasible ideas across domains."}]
  },
  "contents": [{
    "parts": [{
      "text": "Generate 10 unconventional marketing ideas for:\n\nProduct: [description]\nTarget: [audience]\nBudget: [constraints]\n\nFocus on ideas that would grab attention and go viral."
    }]
  }]
}
```

### Wild Ideas (Grok)
```
I need marketing ideas that would actually make people stop scrolling. Give me 5 wild, unconventional ideas for promoting [product]. Don't hold back—what would actually get people talking?
```

## Analysis & Reasoning

### Pros and Cons (Claude)
```xml
<task>
Analyze the trade-offs of this technical decision.
</task>

<decision>
Should we migrate from PostgreSQL to MongoDB for our analytics platform?
</decision>

<context>
- Current data volume: 100GB, growing 20% monthly
- Team expertise: Strong PostgreSQL, limited MongoDB
- Query patterns: Mostly aggregations, some complex joins
- Performance requirements: Sub-second response times
</context>

<output_format>
<table>
<tr><th>Factor</th><th>PostgreSQL</th><th>MongoDB</th></tr>
[analysis rows]
</table>

<recommendation>
[clear recommendation with rationale]
</recommendation>

<risks>
[key risks and mitigation strategies]
</risks>
</output_format>
```

### Complex Problem Solving (Gemini)
```json
{
  "system_instruction": {
    "parts": [{"text": "You are an analytical problem solver. You break down complex issues systematically and provide evidence-based recommendations."}]
  },
  "contents": [{
    "parts": [{
      "text": "I need to decide between [option A] and [option B]. Here are the factors:\n\n[factors]\n\nAnalyze this systematically and give me a clear recommendation with the reasoning."
    }]
  }]
}
```

### Honest Assessment (Grok)
```
I'm trying to decide between [option A] and [option B].

Here's what I know:
- [context A]
- [context B]

Give it to me straight—which one should I choose and why? Don't sugarcoat it.
```

## Multimodal

### Image Description (Claude)
```xml
<task>
Describe this image in detail for alt text.
</task>

<image>
[image data or reference]
</image>

<output_format>
Concise description (1-2 sentences) followed by:
- Main subject
- Key visual elements
- Mood/atmosphere
- Any text visible in image
</output_format>
```

### Visual Analysis (Gemini)
```json
{
  "contents": [{
    "parts": [
      {"text": "Analyze this data visualization and extract all insights:"},
      {"inline_data": {"mime_type": "image/png", "data": "[base64]"}}
    ]
  }]
}
```

### Creative Caption (Grok)
```
Check out this image and give me a witty caption for social media. Something that would actually get engagement.

[image]
```

## Task Decomposition

### Project Breakdown (Claude)
```xml
<task>
Break this project down into actionable tasks.
</task>

<project>
Launch a mobile app for food delivery in 3 months.
</project>

<constraints>
- Budget: $50,000
- Team: 5 developers, 1 designer
- Must launch on iOS and Android
</constraints>

<output_format>
<phases>
<phase name="[phase name]" duration="[weeks]">
<tasks>
<task priority="[high/medium/low]">[task description]</task>
</tasks>
<deliverables>[what's completed]</deliverables>
</phase>
</phases>
</output_format>
```

### Implementation Plan (Gemini)
```json
{
  "system_instruction": {
    "parts": [{"text": "You are a technical project manager. You create detailed implementation plans with clear dependencies and timelines."}]
  },
  "contents": [{
    "parts": [{"text": "Create an implementation plan for:\n\n[project description]\n\nInclude phases, tasks, dependencies, and estimated effort."}]
  }]
}
```

### Roadmap (Grok)
```
I need to build [project]. Help me figure out what the actual roadmap should be—what should I build first, what can wait, and what are the gotchas I should watch out for?
```
