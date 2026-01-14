# Claude Prompt Patterns

Reusable prompt patterns optimized for Claude's structured approach and long-context capabilities.

---

## Document Analysis Patterns

### Document Summarization
```xml
<task>
Summarize the following document, focusing on key findings and implications.
</task>

<document>
[paste document up to 200K tokens]
</document>

<output_format>
<summary>
[executive summary - 2-3 sentences]
</summary>

<key_points>
<point>[key finding 1]</point>
<point>[key finding 2]</point>
<point>[key finding 3]</point>
</key_points>

<implications>
[implications of findings]
</implications>
</output_format>
```

### Quote Extraction
```xml
<task>
Extract all quotes relevant to [topic] from this document.
</task>

<document>
[paste document]
</document>

<output_format>
<quotes>
<quote>
<content>[quote text]</content>
<context>[surrounding context]</context>
<relevance>[why it's relevant]</relevance>
</quote>
</quotes>
</output_format>
```

### Multi-Document Comparison
```xml
<task>
Compare these documents on [criteria].
</task>

<documents>
<document id="1">
<title>[document title]</title>
<content>[content]</content>
</document>

<document id="2">
<title>[document title]</title>
<content>[content]</content>
</document>
</documents>

<output_format>
<comparison>
<similarities>
<similarity>[description]</similarity>
</similarities>

<differences>
<difference>
<aspect>[what differs]</aspect>
<doc1>[doc 1 position]</doc1>
<doc2>[doc 2 position]</doc2>
</difference>
</differences>

<synthesis>
[overall synthesis]
</synthesis>
</comparison>
</output_format>
```

---

## Data Extraction Patterns

### Structured Extraction
```xml
<task>
Extract the following fields from the text: [list fields]
</task>

<input_text>
[paste text]
</input_text>

<output_format>
JSON with keys: [field1], [field2], [field3]
</output_format>
```

### Entity Recognition
```xml
<task>
Identify and categorize named entities in the text.
</task>

<input_text>
[paste text]
</input_text>

<entity_types>
<type>PERSON</type>
<type>ORGANIZATION</type>
<type>LOCATION</type>
<type>DATE</type>
</entity_types>

<output_format>
<entities>
<entity>
<text>[span from text]</text>
<type>[entity type]</type>
<confidence>[high/medium/low]</confidence>
</entity>
</entities>
</output_format>
```

### Table Extraction
```xml
<task>
Extract structured data from this unstructured text.
</task>

<input_text>
[paste text with embedded data]
</input_text>

<schema>
JSON array of objects with properties: [field1], [field2], [field3]
</schema>

<output_format>
[
  {"[field1]": "value", "[field2]": "value", "[field3]": "value"},
  ...
]
</output_format>
```

---

## Content Transformation Patterns

### Text Rewriting
```xml
<task>
Rewrite the following text for [target audience].
</task>

<input_text>
[paste original text]
</input_text>

<constraints>
- Maintain factual accuracy
- Adapt tone appropriately
- Preserve key information
- Keep under [word count] words
</constraints>

<output_format>
[rewritten text]
</output_format>
```

### Format Conversion
```xml
<task>
Convert this [source format] to [target format].
</task>

<input>
[paste content in source format]
</input>

<conversion_rules>
- Preserve all data
- Adapt structure to target format
- Handle edge cases [specifically]
</conversion_rules>

<output_format>
[target format structure]
</output_format>
```

### Content Expansion
```xml
<task>
Expand this brief content into a comprehensive [article/guide/tutorial].
</task>

<brief_content>
[paste brief content]
</brief_content>

<requirements>
- Add relevant examples
- Include explanatory details
- Structure with clear sections
- Target length: [word count]
</requirements>

<output_format>
<expanded_content>
<title>[title]</title>
<introduction>[intro]</introduction>
<section>
<heading>[section heading]</heading>
<content>[content]</content>
</section>
<conclusion>[conclusion]</conclusion>
</expanded_content>
</output_format>
```

---

## Code Generation Patterns

### Function Implementation
```xml
<task>
Write a [language] function that [description].
</task>

<requirements>
- Function signature: [signature]
- Handle edge cases: [list cases]
- Include error handling
- Add docstring
</requirements>

<examples>
<example>
<input>[example input]</input>
<output>[expected output]</output>
</example>
</examples>

<output_format>
```[language]
[function code]
```
</output_format>
```

### Code Review
```xml
<role>
You are a senior [language] engineer conducting a code review.
</role>

<task>
Review this code for correctness, style, and best practices.
</task>

<code>
```[language]
[paste code]
```
</code>

<output_format>
<review>
<summary>[overall assessment]</summary>

<issues>
<issue>
<severity>[critical/major/minor]</severity>
<location>[where in code]</location>
<description>[what's wrong]</description>
<suggestion>[how to fix]</suggestion>
</issue>
</issues>

<positives>
<positive>[what's done well]</positive>
</positives>

<recommendations>
<recommendation>[improvement suggestion]</recommendation>
</recommendations>
</review>
</output_format>
```

### Code Explanation
```xml
<task>
Explain what this code does, line by line if necessary.
</task>

<code>
```[language]
[paste code]
```
</code>

<audience_level>
[beginner/intermediate/advanced]
</audience_level>

<output_format>
<explanation>
<overview>[high-level description]</overview>
<breakdown>
<line number="1">
<code>[code snippet]</code>
<explanation>[what it does]</explanation>
</line>
[continue for key lines]
</breakdown>
<key_concepts>
<concept>[important concept used]</concept>
</key_concepts>
</explanation>
</output_format>
```

---

## Analysis Patterns

### Sentiment Analysis
```xml
<task>
Analyze the sentiment of this [review/feedback/comment].
</task>

<input>
[paste text]
</input>

<output_format>
<sentiment_analysis>
<overall_sentiment>
[positive/negative/neutral]
<confidence>[1-10]</confidence>
</overall_sentiment>

<aspects>
<aspect>
<feature>[what's being discussed]</feature>
<sentiment>[positive/negative/neutral]</sentiment>
<quotes>
<quote>[supporting quote]</quote>
</quotes>
</aspect>
</aspects>

<key_phrases>
<phrase sentiment="[positive/negative]">[phrase]</phrase>
</key_phrases>
</sentiment_analysis>
</output_format>
```

### SWOT Analysis
```xml
<task>
Conduct a SWOT analysis for [company/product/initiative].
</task>

<subject>
[description of subject]
</subject>

<context>
[relevant background information]
</context>

<output_format>
<swot_analysis>
<strengths>
<strength>[description]</strength>
</strengths>

<weaknesses>
<weakness>[description]</weakness>
</weaknesses>

<opportunities>
<opportunity>[description]</opportunity>
</opportunities>

<threats>
<threat>[description]</threat>
</threats>

<strategic_implications>
[what SWOT means strategically]
</strategic_implications>
</swot_analysis>
</output_format>
```

### Root Cause Analysis
```xml
<task>
Perform a root cause analysis of this [problem/issue].
</task>

<problem_description>
[describe the problem]
</problem_description>

<available_information>
[what we know about the situation]
</available_information>

<output_format>
<root_cause_analysis>
<problem_statement>[clear problem statement]</problem_statement>

<contributing_factors>
<factor>[potential cause]</factor>
</contributing_factors>

<root_causes>
<cause>
<description>[root cause]</description>
<evidence>[supporting evidence]</evidence>
</cause>
</root_causes>

<recommended_actions>
<priority>[high/medium/low]</priority>
<action>[specific action]</action>
<expected_outcome>[what it should achieve]</expected_outcome>
</recommended_actions>
</root_cause_analysis>
</output_format>
```

---

## Decision Support Patterns

### Option Comparison
```xml
<task>
Compare these options for [decision context].
</task>

<options>
<option id="A">
<name>[option name]</name>
<description>[description]</description>
<criteria>
<criterion name="cost">[value]</criterion>
<criterion name="time">[value]</criterion>
<criterion name="quality">[value]</criterion>
</criteria>
</option>

<option id="B">
[...]
</option>
</options>

<output_format>
<comparison>
<trade_offs>
<trade_off>
<criterion>[what's being traded]</criterion>
<option_a>[A's position]</option_a>
<option_b>[B's position]</option_b>
<winner>[which wins this criterion]</winner>
</trade_off>
</trade_offs>

<recommendation>
[which option to choose and why]
</recommendation>

<caveats>
[important considerations or risks]
</caveats>
</comparison>
</output_format>
```

### Risk Assessment
```xml
<task>
Assess the risks associated with [proposed action/decision].
</task>

<proposal>
[describe what's being proposed]
</proposal>

<context>
[relevant context and constraints]
</context>

<output_format>
<risk_assessment>
<risks>
<risk>
<description>[what could go wrong]</description>
<probability>[low/medium/high]</probability>
<impact>[low/medium/high]</impact>
<mitigation>[how to address]</mitigation>
</risk>
</risks>

<overall_risk_level>
[low/medium/high]
</overall_risk_level>

<go_no_go>
[recommendation on whether to proceed]
</go_no_go>
</risk_assessment>
</output_format>
```

---

## Learning & Explanation Patterns

### Concept Explanation
```xml
<task>
Explain [concept] to [target audience].
</task>

<audience>
[description of audience knowledge level]
</audience>

<requirements>
- Start with basics
- Use analogies where helpful
- Include examples
- Address common misconceptions
- Target length: [duration/word count]
</requirements>

<output_format>
<explanation>
<introduction>
<hook>[engaging opening]</hook>
<definition>[clear definition]</definition>
<importance>[why it matters]</importance>
</introduction>

<core_concepts>
<concept>
<name>[concept name]</name>
<explanation>[explanation]</explanation>
<example>[concrete example]</example>
</concept>
</core_concepts>

<common_misconceptions>
<misconception>
<belief>[what people think]</belief>
<reality>[what's actually true]</reality>
</misconception>
</common_misconceptions>

<summary>
[key takeaways]
</summary>
</explanation>
</output_format>
```

### Step-by-Step Tutorial
```xml
<task>
Create a step-by-step tutorial for [how to do something].
</task>

<topic>
[what the tutorial covers]
</topic>

<skill_level>
[beginner/intermediate/advanced]
</skill_level>

<output_format>
<tutorial>
<title>[catchy title]</title>

<prerequisites>
<prerequisite>[what learners need before starting]</prerequisite>
</prerequisites>

<steps>
<step number="1">
<title>[step title]</title>
<description>[what to do]</description>
<code>[if applicable]</code>
<expected_result>[what should happen]</expected_result>
<troubleshooting>[common issues]</troubleshooting>
</step>
</steps>

<next_steps>
[what to learn next]
</next_steps>
</tutorial>
</output_format>
```

---

## Research & Synthesis Patterns

### Literature Review
```xml
<task>
Synthesize findings from these research papers on [topic].
</task>

<papers>
<paper>
<title>[paper title]</title>
<authors>[authors]</authors>
<key_findings>[findings]</key_findings>
</paper>
[...]
</papers>

<output_format>
<synthesis>
<themes>
<theme>
<name>[theme name]</name>
<supporting_papers>
<paper>[paper title]</paper>
</supporting_papers>
<consensus>[what papers agree on]</consensus>
<disagreements>[where they differ]</disagreements>
</theme>
</themes>

<research_gaps>
<gap>[what hasn't been studied]</gap>
</research_gaps>

<future_directions>
[recommended areas for future research]
</future_directions>
</synthesis>
</output_format>
```

### Competitive Analysis
```xml
<task>
Analyze the competitive landscape for [market/product category].
</task>

<focus>
[our company/product]
</focus>

<competitors>
[competitor information]
</competitors>

<output_format>
<competitive_landscape>
<market_overview>
[market size, growth, trends]
</market_overview>

<competitor_analysis>
<competitor>
<name>[company]</name>
<strengths>
<strength>[what they do well]</strength>
</strengths>
<weaknesses>
<weakness>[areas where they're weak]</weakness>
</weaknesses>
<market_position>[their positioning]</market_position>
</competitor>
</competitor_analysis>

<opportunities>
<opportunity>
<description>[market gap]</description>
<why_it_exists>[why competitors aren't addressing]</why_it_exists>
<how_to_win>[our advantage]</how_to_win>
</opportunity>
</opportunities>
</competitive_landscape>
</output_format>
```

---

## Pattern Selection Guide

| Goal | Pattern | Why |
|------|---------|-----|
| Summarize long content | Document Summarization | Leverages 200K context |
| Pull specific info | Quote Extraction | Targeted, structured |
| Convert unstructured data | Structured Extraction | Precise output control |
| Transform content | Content Transformation | Clear requirements |
| Generate code | Function Implementation | Examples + requirements |
| Analyze sentiment | Sentiment Analysis | Multi-aspect approach |
| Make decisions | Option Comparison | Structured trade-offs |
| Explain concepts | Concept Explanation | Audience-aware |
| Review literature | Literature Review | Synthesizes multiple sources |
