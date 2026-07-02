# Prompt Engineering Plugin

Model-specific prompt engineering guidance for Claude (Anthropic), Gemini (Google), and Grok (xAI), unified in a single skill.

## Overview

This plugin provides comprehensive prompt engineering guidance tailored to each major LLM platform's unique characteristics, capabilities, and best practices. Universal techniques are covered once and adapted per model, alongside model-specific optimizations.

## Skills

### prompt-engineering

Comprehensive prompt engineering guidance covering Claude, Gemini, and Grok. Use when crafting prompts to leverage each model's unique capabilities—XML-style tags for Claude, system instructions for Gemini, conversational style for Grok.

**Covers:**

- **Claude (Anthropic)** — XML-style tag formatting, 200K context, extended thinking, strong instruction following
- **Gemini (Google)** — system instructions, native multimodal (text/image/audio/video), 1M+ context, Flash/Pro models
- **Grok (xAI)** — conversational style, real-time X (Twitter) knowledge, direct/less-constrained responses

## Universal Techniques Covered

Each technique is covered once and adapted per model:

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

```
prompt-engineering/
├── SKILL.md                    # Unified skill documentation
└── references/
    ├── basics.md               # Foundational concepts
    ├── techniques.md           # Detailed technique explanations
    ├── claude.md               # Claude-specific guidance
    ├── gemini.md               # Gemini-specific guidance
    ├── grok.md                 # Grok-specific guidance
    └── examples.md             # Concrete examples
```

## Version

**Current Version:** 1.1.0

### Version History
- **1.1.0**: Merged grok/claude/gemini-prompting into a single unified `prompt-engineering` skill (synced with `@duyet/skills` canonical source)
- **1.0.0** (2025-01-14): Initial release with separate grok-prompting, claude-prompting, gemini-prompting skills

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
