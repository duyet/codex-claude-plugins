---
name: foundation-models
description: Build on-device generative AI with Apple's Foundation Models framework. Use for text generation, @Generable structured output, tool calling, or multimodal prompts through a LanguageModelSession.
---

# Foundation Models

Docs: <https://developer.apple.com/documentation/foundationmodels>. APIs are new, so check current docs instead of answering from memory.

- Check model availability before use and provide a fallback UI.
- Prefer guided generation (`@Generable`, `@Guide`, or `GenerationSchema`) over parsing free text.
- Private Cloud Compute needs the `com.apple.developer.private-cloud-compute` entitlement.
