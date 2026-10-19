---
name: frontend-design
description: Build distinctive, production-grade frontend interfaces and avoid generic AI-looking design. Use when building web components, pages, dashboards, or apps where visual quality matters.
---

# Frontend design

Write real working code with a deliberate visual identity. Match the project's existing framework and conventions first.

## Commit to a direction before coding

State the purpose, the audience, and one aesthetic (for example editorial, brutalist, retro-futuristic, soft and organic, industrial, Swiss grid, luxury). Pick the one thing the user will remember. Execute that direction consistently and drop everything that does not serve it.

## Stack defaults

Use what the project already has. Otherwise prefer:
- Components: shadcn/ui, then Radix UI primitives, then Headless UI. Read the current shadcn docs or its MCP server instead of recalling the API.
- Styling: Tailwind with CSS variables for design tokens.
- Charts: Recharts for standard charts, D3 only for custom ones.
- Motion: CSS first, Framer Motion for orchestrated React animation.

## Avoid these tells

- Type: Inter, Roboto, Arial, or system-ui as the display face. All text at 14 to 16px. One family everywhere.
- Color: purple or blue-violet gradients, default `#3B82F6` primary, low-contrast pastels, gradient progress bars.
- Layout: everything centered, a row of three identical cards, the centered hero over a gradient with floating shapes, the same radius on every element.
- Decoration: glassmorphism everywhere, soft uniform shadows, fade-in-on-scroll for every block, bounce on buttons, cute empty-state art.

## Do this instead

- Pair a distinctive display face with a plain body face, and push the contrast: headlines at 48px or more, weights far apart (300 against 700). Use fonts with character such as Instrument Serif, Fraunces, Cabinet Grotesk, Satoshi, Geist, DM Sans, JetBrains Mono.
- One dominant color used sparingly, near-black instead of `#000`, color that carries meaning. Design dark mode as a first-class theme.
- Asymmetric composition with a clear hierarchy, overlap for depth, and either generous space or deliberate density. Vary content widths on one page.
- Tactile micro-interactions, loading states that skeleton the real layout, error and empty states that tell the user what to do next.

## Implementation rules

- Server Components by default in Next.js. Add `"use client"` only for state, effects, or browser APIs, and keep those leaves small.
- Fetch in parallel, stream slow parts behind Suspense.
- Keep components small and composed. Split a file over about 100 lines.
- Accessible by default: semantic elements, visible focus, labeled controls, contrast that passes WCAG AA, `prefers-reduced-motion` respected.
- Responsive from the first draft.

## Before finishing

Confirm no item in "Avoid these tells" remains, the direction is recognizable in the first screen, and the build, lint, and types pass.
