---
name: typescript-patterns
description: Typing rules and anti-patterns for TypeScript code. Use when writing or reviewing TypeScript where type safety at boundaries, error handling, or module structure matters.
---

# TypeScript patterns

Follow the repo's `tsconfig` and lint config. If `strict` is off in a new package, turn it on. Also enable `noUncheckedIndexedAccess` unless the codebase cannot absorb it.

## Boundaries

- Data from outside (HTTP, JSON.parse, env, storage, queues, LLM output) is `unknown` until validated. Parse with a schema library already in the repo and infer the type from the schema, so the type and the check cannot drift.
- Validate environment variables once at startup into a typed config object. Fail loudly on missing values. Do not read `process.env` throughout the code.
- Do not cast with `as` to silence an error. A cast is acceptable only right after a runtime check the compiler cannot see, with a comment saying which check.
- `any` is banned in new code. Use `unknown` and narrow. If `any` is unavoidable at a library edge, confine it to one function and return a real type.
- `// @ts-ignore` is never acceptable. `// @ts-expect-error` needs a reason and is for tests or known upstream bugs.
- Avoid `!` non-null assertions. Handle the null case or change the type so it cannot occur.

## Modeling

- Model states as discriminated unions with a literal tag, not several optional fields. Use an exhaustive `switch` with a `never` check so new variants fail to compile.
- Prefer `satisfies` to keep literal types while checking shape. Use `as const` for fixed tables.
- Brand IDs only when mixing them has caused or would cause real bugs (user id vs order id).
- Prefer `type` unions and `interface` for object shapes that are extended. Do not use `enum`. Use a string-literal union or `as const` object.
- Derive types (`Pick`, `Omit`, `ReturnType`, `Awaited`, indexed access) instead of copying shapes by hand.
- Do not export a type that duplicates one from a dependency.

## Errors

- Throw `Error` subclasses (or use `cause`), never strings or plain objects. Catch variables are `unknown`, so narrow before use.
- For expected failures that callers must handle, return a result type (`{ ok: true, value } | { ok: false, error }`). Keep exceptions for unexpected failures.
- Never swallow errors with an empty `catch`. Log with context or rethrow.
- Every promise is awaited, returned, or deliberately handled. Enable `no-floating-promises`.

## Generics

- Add a type parameter only when it relates two positions (input and output). A generic used once should be its concrete type.
- Constrain with `extends` and avoid default type arguments that hide mistakes.
- If a type needs more than two conditional or mapped layers, simplify the API instead.

## Modules

- Use `import type` for type-only imports.
- Avoid barrel files in application code. They slow builds and create cycles. Keep them only for a package's public entry point.
- Inject dependencies as function parameters or a small interface at construction. Do not add a DI container.
- No default exports in shared modules, so names stay greppable.

## Anti-patterns

- `Object` or `{}` as a type. Use `Record<string, unknown>` or a real shape.
- Optional fields that are required in some states. Use a union.
- Re-declaring a response type by hand on the client and server. Share one schema.
- `Promise<any>` and untyped `catch (e: any)`.
- Duplicating runtime validation and static types as separate definitions.
