---
name: backend-api-patterns
description: Rules for designing and implementing HTTP APIs and backend services. Use when adding endpoints, auth, database access, caching, or background work to a service.
---

# Backend API patterns

Follow the repo's framework, ORM, and error conventions first. Constraints that are easy to miss:

- Validate every input at the edge with a schema. One error envelope per service, no stack traces or raw DB errors.
- Check authorization per resource (does this user own this row), not only per route.
- Parameterize all SQL, including allowlisting `ORDER BY` columns.
- Paginate lists from day one and cap page size server-side.
- Retryable mutations take an idempotency key. Background jobs are safe to run twice.
- No external calls inside a DB transaction. Use an outbox or run after commit.
- Migrations are forward-only and safe under rolling deploys. Never rename or drop a column in the release that stops using it.
- Every outbound call has a timeout. Retry only idempotent calls.
- Cache only after measuring, with a named invalidation trigger, a TTL, and a fallback to the source.
- Never log credentials, tokens, or personal data in request bodies.
