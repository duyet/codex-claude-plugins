---
name: good-html
description: Build or review a dense, interactive, self-contained HTML artifact such as a dashboard, PR review, implementation plan, or explainer. Use when asked to create HTML, or to review and update existing HTML in this style.
---

# Good HTML

Produce one `.html` file that works as a small app or document, not Markdown and not a generic page.

## Rules

1. One file. Styles in a `<style>` block, graphics as inline `<svg>`, no external CSS frameworks, fonts, or images.
2. Prefer CSS-only state: hidden radio inputs plus sibling selectors for tabs, native `<details>` for collapsible sections. Use `<script>` only when CSS cannot do it.
3. Use the palette and system font stacks in [references/styles.md](references/styles.md). Avoid purple or blue gradients and web fonts.
4. Pack information: CSS Grid for side-by-side comparisons, sticky headers or sidebars on long content, semantic severity colors (`.safe`, `.attention`, `.critical`).
5. Write the complete file. Do not truncate.

## Workflow

New artifact:

1. Pick the page type: comparison of options, PR review, code explainer, implementation plan, status or incident report, triage board, concept explainer, slide deck, or SVG diagram.
2. Start from [assets/boilerplate.html](assets/boilerplate.html). Page-type examples: [assets/pr-review.html](assets/pr-review.html), [assets/implementation-plan.html](assets/implementation-plan.html), [assets/research-explainer.html](assets/research-explainer.html).
3. Copy tabs, diffs, and timelines from [references/components.md](references/components.md).

Reviewing existing HTML, fix in this order:

1. Remove every external `<link>` and `<script src>`; inline what is needed.
2. Swap web fonts for system stacks and recolor to the palette.
3. Replace a single long column with a grid, and add sticky context for long scrolls.
4. Replace JS-driven simple state with the radio or `<details>` patterns.
5. Replace bitmap icons with inline SVG.
