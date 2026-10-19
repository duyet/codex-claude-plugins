---
name: backend-api-patterns
description: Rules for designing and implementing HTTP APIs and backend services. Use when adding endpoints, auth, database access, caching, or background work to a service.
---

# Backend API patterns

Follow the existing framework, ORM, and error conventions in the repo first. These rules fill the gaps.

## API design

- Validate every input at the edge with a schema (body, query, params, headers). Reject unknown shapes with 400 and field-level errors. Never trust types alone.
- Use one error envelope across the service, with a stable machine-readable `code`, a human `message`, and a request id. Never return stack traces or raw database errors.
- Status codes: 400 invalid input, 401 unauthenticated, 403 authenticated but not allowed, 404 missing (also for resources the caller may not know exist), 409 conflict, 422 only if the repo already uses it, 429 rate limited.
- List endpoints paginate from day one. Prefer cursor pagination for large or changing data, and cap page size server-side.
- Mutations that clients may retry (payments, creates from queues) accept an idempotency key.
- Version only when a breaking change ships. Adding fields is not breaking. Removing or retyping them is.

## Layering

- Handlers parse, call a service, and map the result to a response. No business logic or SQL in handlers.
- Services hold business rules and own transaction boundaries. Repositories hold queries. Do not add a repository layer in a service that only has a handful of queries.
- Pass the authenticated principal into services explicitly. Do not read it from globals inside business code.

## Auth

- Authorization is checked per resource (does this user own this row), not only per route. Missing ownership checks are the most common API bug.
- Hash passwords with argon2id or bcrypt. Never log, return, or store tokens and secrets in plain text.
- Short-lived access tokens, rotating refresh tokens stored hashed server-side, revocation on password change.
- Compare secrets with constant-time functions. Rate limit login and token endpoints per account and per IP.
- CORS: explicit origin allowlist. Never reflect arbitrary origins when credentials are allowed.

## Database

- Parameterize every query. No string-built SQL, including `ORDER BY` columns (allowlist them).
- Find N+1 patterns by checking query counts in tests for list endpoints. Batch or join.
- Select only needed columns on hot paths. Index columns used in `WHERE`, `JOIN`, and `ORDER BY`, and confirm with `EXPLAIN` before and after.
- Wrap multi-write operations in one transaction. Do not call external services (HTTP, email) inside a transaction, use an outbox or run them after commit.
- Migrations are forward-only and safe under rolling deploys. Add nullable column, backfill, then add constraint. Never rename or drop in the same release that stops using the column.
- Set statement and connection timeouts and a bounded pool size.

## Caching

- Cache only after measuring. Name the invalidation trigger before adding a cache.
- Key by every input that changes the result, including tenant and user id for per-user data.
- Always set a TTL. Add jitter for hot keys and request coalescing to prevent stampedes.
- A cache failure must fall back to the source, not return 500.

## Reliability

- Every outbound call has a timeout. Retry only idempotent calls, with backoff and a cap.
- Background jobs are idempotent and safe to run twice.
- Log structured events with the request id. Never log credentials, tokens, or full request bodies with personal data.
- Health endpoints check dependencies the service cannot work without, not every downstream.

## Anti-patterns

- Returning 200 with an error body.
- Catching an error, logging it, and continuing as if it succeeded.
- Authorization done only in the client or gateway.
- Unbounded queries, loops over network calls, or in-memory pagination of full tables.
- Shared mutable module state for per-request data.
