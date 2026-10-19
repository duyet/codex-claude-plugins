---
name: ios-app-intents
description: Design App Intents, app entities, and App Shortcuts for iOS system surfaces. Use when exposing app actions or content to Shortcuts, Siri, Spotlight, widgets, or controls.
---

# iOS App Intents

Docs: <https://developer.apple.com/documentation/appintents>.

- Name intents with verbs (open, find, compose, continue). Do not mirror the whole navigation tree as intents.
- Add `AppEntity` and `EntityQuery` types only where the system needs to route or disambiguate.
- Put the system-facing layer in a dedicated intents target or module, with one predictable handoff into the main scene.
- Treat App Intents as system integration infrastructure, not only a Shortcuts feature.
