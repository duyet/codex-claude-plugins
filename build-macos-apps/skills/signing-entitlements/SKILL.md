---
name: signing-entitlements
description: Inspect macOS signing, entitlements, and Gatekeeper issues. Use when diagnosing code signing, sandbox, hardened runtime, or trust failures.
---

# Signing and entitlements

Use `codesign -dvvv --entitlements :-`, `spctl --assess -vv`, and `plutil` to read facts.

- Never invent entitlements. Read them from the binary or source files.
- Name the failure class: identity, provisioning, hardened runtime, sandbox, or trust policy.
- Do not conflate notarization with local debug signing.
