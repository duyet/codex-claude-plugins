---
name: typescript-patterns
description: Typing rules and anti-patterns for TypeScript code. Use when writing or reviewing TypeScript where type safety at boundaries, error handling, or module structure matters.
---

# TypeScript patterns

Follow the repo's `tsconfig` and lint config. Rules that matter most:

- External data (HTTP, JSON.parse, env, storage, LLM output) is `unknown` until parsed by the repo's schema library. Infer the type from the schema.
- No `any`, `@ts-ignore`, or `as` casts to silence errors. A cast is allowed only after a runtime check, with a comment naming it.
- Model states as discriminated unions with an exhaustive `never` check, not optional fields.
- Throw `Error` subclasses, never strings. No empty `catch`. No floating promises.
- Add a generic parameter only when it relates two positions.
- Use `import type` for type-only imports. No `enum`, no barrel files outside a package entry point.
- Share one schema between client and server instead of redeclaring types.
