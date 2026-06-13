---
name: apple-intelligence
description: Apple Intelligence participation layer. Wire an app's actions and content into Siri, Spotlight, Writing Tools, Image Playground, and summaries via App Intents, entities, and schemas. Use before adding App Intents/schemas, Spotlight indexing, Writing Tools, or Image Playground; defer custom generative features and on-device model files to the sibling skills.
---

# Apple Intelligence

## Overview

Apple Intelligence is the personal intelligence system behind built-in capabilities
across Apple platforms. It runs on-device on Apple silicon and in Private Cloud
Compute. Your app participates by teaching the system about its **actions** and
**content** so system features — Siri, Spotlight, Shortcuts, Writing Tools, Image
Playground, Visual Intelligence, Genmoji, and summaries — can use them.

The participation contract is the **App Intents** framework: an `AppIntent` wraps one
of your app's actions; an `AppEntity` represents the data those actions operate on.
Apple Intelligence uses donated intents/entities, your Spotlight index, and declared
schemas to find and act on your content — even when described vaguely.

Two sibling skills handle the custom-model side and are out of scope here:

- **`foundation-models`** — the Foundation Models framework for custom generative
  features (prompting, guided generation, tool calling, Private Cloud Compute).
- **`core-ai`** — running your own deep-learning model files (`.aimodel`) on-device.

This skill covers only the built-in intelligence surfaces an app adopts.

## Device eligibility and availability

Apple Intelligence requires Apple silicon (iPhone 15 Pro and later, iPad with A17 Pro
or M-series, Mac with M-series). It is opt-in via the Apple Intelligence toggle in
Settings. Before exposing intelligence features, branch on the system model's
`availability` rather than assuming it is on:

```swift
import FoundationModels

private var model = SystemLanguageModel.default

switch model.availability {
case .available:
    // Show your intelligence UI.
case .unavailable(.deviceNotEligible):
    // Show an alternative UI.
case .unavailable(.appleIntelligenceNotEnabled):
    // Ask the person to turn on Apple Intelligence.
case .unavailable(.modelNotReady):
    // Model is downloading or not ready.
case .unavailable(let other):
    // Unknown reason.
}
```

## How an app participates: App Intents, entities, schemas

The single biggest lever. Make the system aware of your actions and data via the App
Intents framework:

- **App intents** — a custom type encapsulating one action. Ship in your app or an app
  extension so the action runs even when the app isn't open. Each intent performs an
  action in `perform()`, returns a result/error, declares parameters, and provides a
  localized title Siri and Shortcuts can display.
- **App entities** — lightweight versions of your data objects. Define them only for
  the subset of data people see and might reference with Siri ("this photo", "this
  album"). Real data objects stay the source of truth.
- **App enums** — enumerate fixed choices (e.g. repeat options) so the system can
  resolve parameters.
- **Donations** — when someone performs an action in your UI, donate the matching
  intent/entity. Donations give Apple Intelligence behavioral cues to predict and
  disambiguate. Donate only direct UI interactions, not actions Siri or Shortcuts
  initiated.
- **Schemas (domains)** — the predefined intent/entity shapes for common actions (mail,
  messaging, files, etc.). Prefer building from a schema over a custom intent; schemas
  are the contract Apple Intelligence uses to match everyday phrases.

Grounded minimal `AppIntent` shape:

```swift
struct OrderAlbum: AppIntent {
    static var title: LocalizedStringResource { "Order Album" }
    static var description = IntentDescription("Order a vinyl record album.")

    @Parameter(title: "Album", description: "The name of the album to order.")
    var albumName: String

    @Dependency
    private var albumManager: AlbumDataManager

    func perform() async throws -> some IntentResult {
        // Perform the action...
        return .result()
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Order \(\.$albumName)")
    }
}
```

> For full intent/entity/schema implementation patterns, see the sibling
> `ios-app-intents` skill.

## App Shortcuts

An `AppShortcut` bundles an `AppIntent` with a title, image, preconfigured parameters,
and spoken phrases so it appears polished in Shortcuts and other system experiences.
The compiler generates system metadata, so shortcuts are available the moment someone
installs your app — no registration needed. Define them in a type adopting the
`AppShortcutProvider` protocol, alongside the intents they use. Surface them in-app
with tip views.

## Apple Intelligence + Siri AI: the extra steps

Beyond a basic App Intents adoption, make content discoverable by Apple Intelligence
specifically:

- **Index entities into Spotlight** — Apple Intelligence uses Spotlight's semantic
  search to find your content even when described vaguely. This is what makes "the
  email from Mei about the Q3 plan" work.
- **Choose transferable types** — conform entities/values to transferable types so the
  system can move content across apps for cross-app Siri tasks.
- **Adopt schemas** — the contract the system uses to identify, query, and understand
  actions and content, and to match them to conversational phrases.
- **Associate entities with views / user activities** — gives Apple Intelligence
  onscreen context so someone can refer to what's visible ("this photo").
- **Donate actions and content** — behavioral cues for prediction and disambiguation.

## Spotlight / semantic indexing

Indexing your app's content makes it findable in search and lets Siri and other system
features locate app-specific data. If you define app entities for your data, index
those entities with the rest of your content. When a search finds your content, the
system uses the associated entity to open your app and navigate to it. Apple
Intelligence retrieves entities it finds in your Spotlight index to interact with your
content.

## Writing Tools and Genmoji

Writing Tools (proofreading, rewrite, summaries) integrate into standard system text
views automatically:

- Adopt `NSAttributedString` / attributed strings as the backing store for text content.
- Use standard text views whenever possible and customize via their configuration
  options.
- Use the Writing Tools API directly only if you have a custom text-editing engine or
  can't use system views.
- Genmoji is built into system text views. In custom views, add Genmoji text
  attachments and read/write them correctly when persisting to a custom file format.

## Image Playground

The ImagePlayground framework gives a system interface to generate images from a text
description, an optional source image, and a style. Present a system sheet (SwiftUI) or
view controller (UIKit/AppKit); the system manages all interaction and delivers the
resulting image. Key API surface:

- `ImagePlaygroundViewController` — the standard system interface (UIKit/AppKit).
- `ImagePlaygroundConcept` — text elements specifying content to include.
- `ImagePlaygroundStyle` / `ImagePlaygroundOptions` — style and generation options.
- `ImageCreator` — generate images programmatically without the UI.
- SwiftUI sheet modifier:

```swift
imagePlaygroundSheet(
    isPresented: Binding<Bool>,
    concept: String,          // or concepts: [ImagePlaygroundConcept]
    sourceImage: Image?,      // or sourceImageURL: URL
    onCompletion: (URL) -> Void,
    onCancellation: (() -> Void)?
)
```

## Visual Intelligence

For object/scene scanning via Camera Control, adopt Visual Intelligence. The framework
detects content and exchanges information with your app using App Intents — so your App
Intents participation is also what makes you a destination for Visual Intelligence
results.

## Checklist

- [ ] Check `SystemLanguageModel.default.availability` before showing intelligence UI;
      handle `.deviceNotEligible` and `.appleIntelligenceNotEnabled`.
- [ ] Identified the user-visible actions and data; modeled them as `AppIntent` and
      `AppEntity`.
- [ ] Built common actions from built-in schema domains (not bespoke intents) where one
      exists.
- [ ] Each intent has `perform()`, a result/error, declared `@Parameter`s, and a
      localized `title`.
- [ ] Entities are lightweight and cover only what people see/reference.
- [ ] Donating intents/entities on direct UI interactions (not Siri/Shortcuts ones).
- [ ] App entities indexed into Spotlight (enables semantic search by Apple
      Intelligence).
- [ ] Entities associated with views/user activities for onscreen context.
- [ ] Conformed entities to transferable types for cross-app Siri tasks.
- [ ] App Shortcuts defined via `AppShortcutProvider` for headline actions.
- [ ] Text content backed by attributed strings; Writing Tools and Genmoji handled in
      custom text views.
- [ ] Image Playground adopted via `imagePlaygroundSheet` / `ImagePlaygroundViewController`
      (or `ImageCreator` for programmatic generation).
- [ ] Custom generative features delegated to `foundation-models`; on-device model files
      to `core-ai`.
- [ ] Tested intents end-to-end (Siri, Spotlight, Shortcuts) on a real eligible device.

## Resources

- Apple Intelligence overview — <https://developer.apple.com/documentation/technologyoverviews/apple-intelligence>
- Built-in intelligence (on-device vision/speech/NLP) — <https://developer.apple.com/documentation/technologyoverviews/built-in-intelligence>
- Generative models overview — <https://developer.apple.com/documentation/technologyoverviews/generative-models>
- Apple Intelligence and Siri AI — <https://developer.apple.com/documentation/appintents/apple-intelligence-and-siri-ai>
- Spotlight integration — <https://developer.apple.com/documentation/appintents/spotlight>
- Donations and discovery — <https://developer.apple.com/documentation/appintents/donations-and-discovery>
- Getting started with App Intents — <https://developer.apple.com/documentation/appintents/getting-started-with-the-app-intents-framework>
- App entities — <https://developer.apple.com/documentation/appintents/app-entities>
- App Shortcuts — <https://developer.apple.com/documentation/appintents/app-shortcuts>
- AppIntent protocol — <https://developer.apple.com/documentation/appintents/appintent>
- Image Playground — <https://developer.apple.com/documentation/imageplayground>
- Foundation Models quick start (eligibility code) — <https://developer.apple.com/documentation/foundationmodels/generating-content-and-performing-tasks-with-foundation-models>
- Sibling skills: `foundation-models`, `core-ai`, `ios-app-intents`
