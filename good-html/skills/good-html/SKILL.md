---
name: good-html
description: Generate or review high-density, interactive, self-contained HTML artifacts based on Thariq Shihipar's "Unreasonable Effectiveness of HTML" patterns. Use this skill when asked to "create HTML," "build a dashboard," "format a PR review," "make an interactive explainer," or when you need to "review and update" existing HTML using the "good-html" style.
---

# Good HTML Artifact Generator

This skill enables Claude to generate or refactor highly effective, visually distinct, and functional HTML artifacts rather than relying on standard Markdown or low-resolution HTML. It is based on the design patterns from Thariq Shihipar's "The Unreasonable Effectiveness of HTML".

The core philosophy is that a single HTML file can act as a high-density "mini-app" or interactive document that is completely self-contained and highly portable.

## Core Rules for HTML Generation & Review

1.  **Single-File Output Only:** The entire artifact must fit within one `.html` file.
2.  **Zero Dependencies:** Do NOT use external CSS frameworks (no Tailwind, Bootstrap, etc.) or external font files. 
3.  **Inline Everything:** All styles must be in a `<style>` block. Use inline `<svg>` for graphics.
4.  **Avoid "AI Defaults":** Do not use generic bright blue/purple gradients or basic Bootstrap aesthetics. Use the provided earthy, muted color palette and robust system fonts.

## Resources

When generating or reviewing an artifact, consult the following resources:

*   **[references/patterns.md](references/patterns.md):** Read this for specific architectural patterns, CSS-only interactivity, and the **Review Checklist**.
*   **[references/styles.md](references/styles.md):** The design system for colors, typography, and spacing.
*   **[references/components.md](references/components.md):** Use this for pre-built interactive components (tabs, diffs, timelines).
*   **[assets/boilerplate.html](assets/boilerplate.html):** Use this file as the structural starting point.

## Workflow

### For New Artifacts
1.  **Analyze Request:** Determine the optimal page type (see [references/page_types.md](references/page_types.md)).
2.  **Plan Layout:** Decide on the grid structure and interaction model.
3.  **Implement:** Use the boilerplate and component library to build the file.

### For Review & Refactoring
1.  **Audit:** Compare the current HTML against the **Review Checklist** in `patterns.md`.
2.  **Identify Bottlenecks:** Find external dependencies, generic styles, or low-density layouts.
3.  **Apply Surgical Updates:**
    *   Inline external CSS/JS.
    *   Swap web fonts for the system font stack.
    *   Update colors to the Ivory/Slate/Clay palette.
    *   Refactor lists or simple tables into high-density Grids or Tabs.
4.  **Verify Interactivity:** Ensure state handling (e.g. tabs) is refactored to use the CSS-only radio engine where appropriate.

## Output Code
Output the complete HTML code within a standard code block for the user to copy, or write it directly to an HTML file if instructed. Do not truncate the code.