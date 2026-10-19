---
name: react-nextjs-patterns
description: Conventions for React and Next.js App Router code. Use when building or reviewing components, pages, data fetching, caching, or Server Actions in a Next.js app.
---

# React and Next.js patterns

Check the installed versions in `package.json` and read the matching docs (<https://nextjs.org/docs>) before using caching or routing APIs. Defaults changed across majors.

- Server components by default. Put `"use client"` on the smallest leaf that needs it, never on a page or layout.
- Fetch in server components. Start independent requests together. Stream slow sections with Suspense.
- Per-user data must never reach a shared cache.
- Treat every Server Action as a public endpoint: authenticate, authorize, and validate input inside it.
- Server-only modules import `server-only`. Only serializable props cross the client boundary.
- Derive values during render. An effect that only sets state from state should be deleted.
- No `useMemo`, `useCallback`, or `memo` without a measured problem, and none with the React Compiler.
- Stable list keys from data ids. Use `next/image`, `next/font`, and `next/link`.
