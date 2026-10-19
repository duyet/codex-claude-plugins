---
name: react-nextjs-patterns
description: Conventions for React and Next.js App Router code. Use when building or reviewing components, pages, data fetching, caching, or Server Actions in a Next.js app.
---

# React and Next.js patterns

Check the installed Next.js and React versions in `package.json` and read the matching docs before using caching or routing APIs. Caching defaults and API names have changed between major versions.

## Server and client boundary

- Components are server components by default. Add `"use client"` only for state, effects, event handlers, refs, or browser APIs.
- Put the boundary on the smallest leaf that needs interactivity. A button with a click handler is a client component, the page around it is not.
- Server components can pass server components to client components as `children` or props. Use this to keep large subtrees on the server.
- Only serializable props cross the boundary. No functions (except Server Actions), class instances, or Dates you expect to stay Dates.
- Never import server-only code (database clients, secrets) into a client file. Mark such modules with `import "server-only"`.
- Third-party components that use hooks need a thin `"use client"` wrapper file. Do not mark whole pages client to work around this.

## Data fetching

- Fetch in server components, next to where the data is used. Do not add `useEffect` plus `fetch` for initial data.
- Start independent requests together with `Promise.all`. Sequential awaits create waterfalls.
- Deduplicate shared reads within a request with React `cache()` instead of passing data down as props.
- Wrap slow, non-critical sections in `<Suspense>` with a skeleton, and add `loading.tsx` for route-level fallbacks. Do not block the whole page on the slowest query.
- Client-side fetching is for data that depends on user interaction or needs polling. Use the project's existing query library, not a new one.

## Caching

- Decide per route whether it is static, revalidated, or dynamic, and write the choice down in the code (route segment config or fetch options), not by accident.
- Reading `cookies()`, `headers()`, or request search params makes the route dynamic. Do that in a small component under Suspense when the rest can stay static.
- After a mutation, revalidate by tag or path. Prefer tags so related pages update together.
- Per-user data must never land in a shared cache. Check this whenever a cached function reads a session.

## Server Actions

- Treat every Server Action as a public endpoint. Authenticate and authorize inside the action, and validate input with a schema. Do not rely on the UI hiding the button.
- Use actions for mutations from forms and client components. Use route handlers for webhooks, third-party callers, and non-form clients.
- Return typed results (`{ ok: false, error }`) for expected failures. Throw only for unexpected ones.
- Call revalidation inside the action, then redirect if needed. `redirect()` throws, so do not wrap it in try/catch.

## Client component rules

- Derive values during render. Do not mirror props or other state into `useState` with an effect.
- Effects are for syncing with external systems. If an effect only sets state from other state, delete it.
- Use `key` to reset component state, not an effect that watches an id.
- Do not add `useMemo`, `useCallback`, or `memo` without a measured problem. If the project has the React Compiler enabled, do not add them at all.
- Lists need stable keys from data ids, never the array index when items reorder or delete.
- Use `next/image`, `next/font`, and `next/link` instead of raw `img`, font links, and `a` for internal routes.

## Anti-patterns

- `"use client"` at the top of a page or layout.
- Fetching your own route handler from a server component. Call the function directly.
- Passing a whole database row to a client component when it needs two fields.
- Global client context wrapping the whole app for data that only one subtree reads.
- Storing server data in client state libraries when a server component can render it.
