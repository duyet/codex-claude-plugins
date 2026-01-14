# Prompt Engineering Plugin

Model-specific prompt engineering skills for Grok (xAI), Claude (Anthropic), and Gemini (Google).

## Overview

This plugin provides comprehensive prompt engineering guidance tailored to each major LLM platform's unique characteristics, capabilities, and best practices. Each skill includes universal techniques adapted for the specific model, along with model-specific optimizations.

## Skills

### grok-prompting

Prompt engineering guidance for Grok (xAI) with conversational prompting patterns and real-time knowledge integration.

**Key Features:**
- Conversational, less-structured prompt style
- Real-time X (Twitter) knowledge access
- Less content-constrained responses
- Witty, rebellious personality considerations

**Best For:**
- Current events analysis
- Topics that might be filtered by other models
- Direct, honest feedback
- Creative, conversational applications

### claude-prompting

Prompt engineering guidance for Claude (Anthropic) with XML-style tags, long-context optimization, and extended thinking.

**Key Features:**
- XML-style tag formatting
- 200K token context window
- Extended thinking feature
- Strong instruction following
- Constitutional AI foundation

**Best For:**
- Long document analysis
- Complex reasoning tasks
- Precise instruction following
- Code generation and review
- Structured output requirements

### gemini-prompting

Prompt engineering guidance for Gemini (Google) with system instructions, multimodal prompting, and ultra-long context.

**Key Features:**
- System instructions for behavior control
- Native multimodal (text, images, audio, video)
- 1M+ token context window
- Flash (fast) and Pro (capable) models

**Best For:**
- Multimodal applications
- Very large document analysis
- Image/video understanding
- Code generation
- Multilingual tasks

## Universal Techniques Covered

Each skill covers these prompt engineering techniques, adapted for the specific model:

| Technique | Description |
|-----------|-------------|
| **Zero-Shot Prompting** | Direct questioning without examples |
| **Few-Shot Prompting** | In-context learning with examples |
| **Chain-of-Thought (CoT)** | Step-by-step reasoning |
| **Zero-Shot CoT** | "Let's think step by step" |
| **Prompt Chaining** | Breaking tasks into subtasks |
| **ReAct Prompting** | Reasoning + Acting with tools |
| **Tree of Thoughts (ToT)** | Exploration with backtracking |

## Quick Reference

### Model Comparison

| Aspect | Grok | Claude | Gemini |
|--------|------|--------|--------|
| **Context** | ~128K | 200K | 1M+ |
| **Prompt Style** | Conversational | XML-structured | System instructions |
| **Strength** | Real-time knowledge | Long-context analysis | Multimodal |
| **Personality** | Witty, rebellious | Helpful, honest | Neutral, capable |
| **Best For** | Current events | Document analysis | Multimodal tasks |

### When to Use Each Model

**Use Grok when:**
- You need current, real-time information
- Discussing topics that might be filtered elsewhere
- You want direct, unfiltered opinions
- Conversational interaction style

**Use Claude when:**
- Working with long documents (up to 200K tokens)
- You need precise instruction following
- Complex reasoning with extended thinking
- Strong ethical considerations required
- Structured, formatted output needed

**Use Gemini when:**
- Processing images, audio, or video
- Working with massive documents (1M+ tokens)
- Building multimodal applications
- Need fast responses (Flash model)
- System instruction-based behavior control

## Skill Structure

Each skill follows this structure:

```
[skill-name]/
├── SKILL.md                    # Main skill documentation
└── references/
    ├── basics.md               # Foundational concepts
    ├── techniques.md           # Detailed technique explanations
    ├── patterns.md             # Reusable prompt patterns
    └── examples.md             # Concrete examples
```

**Claude additionally includes:**
- `xml-formatting.md` - XML tag patterns

**Gemini additionally includes:**
- `system-instructions.md` - System instruction guide
- `multimodal.md` - Multimodal prompting

## Usage

### Invoking a Skill

Each skill can be invoked automatically when crafting prompts for that specific model, or manually referenced for guidance.

Example skill invocation:
```
@claude-prompting
I need to analyze this 100-page document and extract key findings...

@gemini-prompting
I have this product image and need marketing copy...

@grok-prompting
What's the latest sentiment on crypto Twitter about Bitcoin?
```

### Combining Techniques

The skills teach universal techniques that can be combined:

```
**Prompt Chaining + CoT:**
Step 1: Extract relevant quotes (document analysis)
Step 2: Synthesize findings (chain-of-thought reasoning)
Step 3: Generate final report (structured output)
```

## Version

**Current Version:** 1.0.0

### Version History
- **1.0.0** (2025-01-14): Initial release
  - grok-prompting skill
  - claude-prompting skill
  - gemini-prompting skill

## Contributing

This plugin follows semantic versioning. When contributing:

- **Patch** (1.0.0 → 1.0.1): Documentation updates, bug fixes
- **Minor** (1.0.0 → 1.1.0): New techniques, additional reference materials
- **Major** (1.0.0 → 2.0.0): Breaking changes to structure

## Author

**duyetbot** <duyetbot@users.noreply.github.com>

## License

Part of the claude-plugins project.

## See Also

- [promptingguide.ai](https://www.promptingguide.ai) - Comprehensive prompt engineering guide
- [Anthropic Documentation](https://docs.anthropic.com) - Official Claude documentation
- [Google Gemini Documentation](https://ai.google.dev/gemini-api/docs) - Official Gemini documentation
- [xAI Documentation](https://docs.x.ai) - Official Grok documentation
