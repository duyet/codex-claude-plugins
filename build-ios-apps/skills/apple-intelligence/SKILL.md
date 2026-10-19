---
name: apple-intelligence
description: Wire app actions and content into Siri, Spotlight, Writing Tools, and Image Playground via App Intents and schemas. Use before adding intents, schemas, Spotlight indexing, Writing Tools, or Image Playground.
---

# Apple Intelligence

Docs: <https://developer.apple.com/documentation/appintents> and <https://developer.apple.com/apple-intelligence/>. Custom generative features use `foundation-models`. On-device model files use `core-ai`.

- Apple Intelligence needs supported Apple silicon devices. Gate features on availability and keep a non-AI path.
- Prefer building from an Apple schema over a custom intent.
- Keep app entities lightweight and limited to what people see or reference. Donate only direct UI interactions.
- Use standard text views so Writing Tools works for free. Use the Writing Tools API directly only for a custom text engine.
