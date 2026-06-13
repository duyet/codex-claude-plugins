---
name: foundation-models
description: Build on-device generative AI with Apple's Foundation Models framework. Use the system language model (Apple Intelligence) for text generation, structured output via @Generable and GenerationSchema, tool calling, and multimodal prompts through a LanguageModelSession.
---

# Foundation Models

## Overview

Foundation Models is Apple's generative-AI framework for intelligent app features. You
drive a language model through a `LanguageModelSession` — generating text, structuring
output into Swift types with guided generation (`@Generable`, `GenerationSchema`), and
letting the model call your own `Tool`s during generation. The default backend is the
**system language model** (`SystemLanguageModel`), which runs on Apple Intelligence
(iPhone, iPad, and Mac with Apple silicon). The same session API also targets
**Private Cloud Compute** (`PrivateCloudComputeLanguageModel`, server-side) or a
**custom language model provider**, so session code is portable across backends.

Before any feature, gate on availability — the model can be unavailable for several
reasons:

```swift
private var model = SystemLanguageModel.default

switch model.availability {
case .available:
    // Show your intelligence UI.
case .unavailable(.deviceNotEligible):
    // Device can't run the model; offer an alternative.
case .unavailable(.appleIntelligenceNotEnabled):
    // Ask the person to turn on Apple Intelligence.
case .unavailable(.modelNotReady):
    // Still downloading or otherwise not ready.
case .unavailable(let other):
    // Other system reason.
}
```

## Essentials

Create a session and respond to a prompt. `respond(to:)` is async and throws.

```swift
let session = LanguageModelSession()
let response = try await session.respond(to: "Write a profile for a dog breed.")
print(response.content)
```

Instructions give the session persistent behavior; `GenerationOptions` (e.g.
`temperature`) tunes sampling; `ContextOptions` manages the context window:

```swift
let session = LanguageModelSession(instructions: """
    Suggest five related topics. Keep them concise (three to seven words).
    """)

let response = try await session.respond(to: "Making homemade bread")

// More creative sampling.
let session2 = LanguageModelSession()
let r = try await session2.respond(
    to: "Write me a story about coffee.",
    options: GenerationOptions(temperature: 1.0)
)
```

Use `LanguageModelSession(model:)` to target a backend, and the session's streaming API
to receive output incrementally for long generations.

## Structured Output (Guided Generation)

Generate typed data instead of free text. For primitives, pass the type directly:

```swift
let r = try await session.respond(to: "How many tablespoons are in a cup?",
                                  generating: Float.self)
```

For custom types, conform to `Generable` and guide fields with `@Guide` (supports
constraints such as `.range(...)`):

```swift
@Generable(description: "Basic profile information about a cat")
struct CatProfile {
    var name: String

    @Guide(description: "The age of the cat", .range(0...20))
    var age: Int

    @Guide(description: "A one sentence profile about the cat's personality")
    var profile: String
}

let r = try await session.respond(to: "Generate a cute rescue cat",
                                  generating: CatProfile.self)
```

For schemas built at runtime, assemble `DynamicGenerationSchema` nodes into a
`GenerationSchema`, then pass `schema:`:

```swift
let menuSchema = DynamicGenerationSchema(
    name: "Menu",
    properties: [
        DynamicGenerationSchema.Property(
            name: "dailySoup",
            schema: DynamicGenerationSchema(
                name: "dailySoup",
                anyOf: ["Tomato", "Chicken Noodle", "Clam Chowder"]
            )
        )
        // Add additional properties.
    ]
)

let schema = try GenerationSchema(root: menuSchema, dependencies: [])
let r = try await session.respond(to: "What is today's menu?", schema: schema)
```

## Tool Calling

Let the model invoke your code during generation. Conform to `Tool`; describe arguments
with `@Generable` and return simple, model-friendly content from `call(arguments:)`:

```swift
struct BreadDatabaseTool: Tool {
    let name = "searchBreadDatabase"
    let description = "Searches a local database for bread recipes."

    @Generable struct Arguments {
        @Guide(description: "The type of bread to search for")
        var searchTerm: String

        @Guide(description: "The number of recipes to get", .range(1...6))
        var limit: Int
    }

    func call(arguments: Arguments) async throws -> [String] {
        // Retrieve recipes from your database, then return formatted strings.
        return []
    }
}

let session = LanguageModelSession(tools: [BreadDatabaseTool()])
let r = try await session.respond(to: "Find three sourdough bread recipes")
```

## Choosing a Backend

- `SystemLanguageModel.default` — on-device, Apple Intelligence. Private and
  offline-capable; the default for most features.
- `PrivateCloudComputeLanguageModel` — same session API, runs server-side on Apple's
  cloud. Requires the `com.apple.developer.private-cloud-compute` entitlement. Use when
  you need a larger cloud model; reuse your existing session code.
- Custom language model provider — bring your own model behind the same session API.

Attach images with `Attachment` / `ImageAttachmentContent` for multimodal prompting and
image analysis.

## Checklist

- [ ] Check `SystemLanguageModel.default.availability`; provide a fallback for each case.
- [ ] Use `LanguageModelSession`, with `instructions:` for persistent guidance.
- [ ] Prefer guided generation (`@Generable` / `@Guide` or `GenerationSchema`) over
      parsing free text.
- [ ] Constrain numeric fields with `@Guide` ranges; validate generated values.
- [ ] Expose app capabilities as `Tool`s that return simple, model-friendly content.
- [ ] Pick the backend deliberately: system vs Private Cloud Compute vs custom provider.
- [ ] Stream long responses and manage the context window with `ContextOptions`.
- [ ] Evaluate prompts and responses, and apply safety guidance for generative output.

## Related skills

- `apple-intelligence` — the participation layer (Siri, Spotlight, Writing Tools, Image
  Playground) that surrounds on-device generation.
- `core-ai` — running your own model files (`.aimodel`) at the tensor level, for
  features that are not language-model shaped.

## Resources

- Apple — Foundation Models: <https://developer.apple.com/documentation/foundationmodels>
- Generating content and performing tasks with Foundation Models
- Generating Swift data structures with guided generation
- Expanding generation with tool calling
- Prefer Apple docs for up-to-date API details; web-search the current Foundation Models
  documentation alongside this skill.
