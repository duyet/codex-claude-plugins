# HTML Effectiveness Patterns

This document outlines the core patterns identified by Thariq Shihipar in "The Unreasonable Effectiveness of HTML". When generating HTML artifacts, strictly adhere to these patterns to produce high-density, interactive, and professional outputs.

## 1. The "Self-Contained" Architecture
* **Single-File Artifact:** The output MUST be a single `.html` file.
* **Zero External Dependencies:** Do NOT use external CSS frameworks (like Tailwind CDN) or external font files.
* **Inline Everything:** All CSS must be inside a `<style>` block in the `<head>`. All JS (if absolutely necessary, but prefer CSS-only state) must be in `<script>` blocks.
* **Inline SVG:** Use `<svg>` directly in the HTML for icons and diagrams instead of linking external images.

## 2. Professional Aesthetics (Avoid "AI Defaults")
* **Typography:** Use robust system font stacks. Avoid web fonts that require network requests.
  * Serif: `ui-serif, Georgia, 'Times New Roman', serif;`
  * Sans: `system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;`
  * Mono: `ui-monospace, 'SF Mono', Menlo, Monaco, monospace;`
* **Color Palette:** Use subtle, earthy, or muted tones instead of harsh primary colors or typical "AI" gradients. 
  * Examples: `--ivory: #FAF9F5;`, `--slate: #141413;`, `--clay: #D97757;`, `--olive: #788C5D;`
* **Spacing:** Be generous with whitespace (e.g., `line-height: 1.55;`, `padding: 48px`).

## 3. High-Density Layouts
* **Side-by-Side Comparisons:** Use CSS Grid (`display: grid; grid-template-columns: 1fr 1fr; gap: 20px;`) to present alternatives next to each other rather than in a long vertical list.
* **Sticky Headers/Context:** Use `position: sticky; top: 0;` for elements like table headers or summary sidebars so the user retains context while scrolling through long content (e.g., code diffs).
* **Severity Color-Coding:** Use semantic CSS classes (e.g., `.safe { color: var(--olive); }`, `.attention { color: var(--clay); }`) to make data scannable.

## 4. Interactive Elements (CSS-Only Preferred)
* **The "Radio State" Engine:** Use hidden `<input type="radio">` elements paired with labels and CSS sibling selectors (`+` or `~` or `:has()`) to create interactive tabs or expanding sections without JavaScript.
* **Collapsible Sections:** Use native `<details>` and `<summary>` elements to hide secondary information (like large code blocks) until needed.
* **Hover Effects:** Add subtle `transition: transform 150ms ease, box-shadow 150ms ease;` to cards and interactive elements.

## 5. Review Checklist (Audit Guide)
When reviewing existing HTML to update it to this style, check for the following:

- [ ] **Portability:** Are there any external `<link>` or `<script src="...">` tags? (Should be 0).
- [ ] **Aesthetics:** Does it use "AI Defaults" (Inter font, purple gradients)? (Swap for system fonts and Ivory/Slate/Clay palette).
- [ ] **Density:** Is information presented in a single long column? (Use CSS Grid for side-by-side comparisons).
- [ ] **Context:** Does the user lose context when scrolling? (Add sticky headers/sidebars).
- [ ] **Interactivity:** Does it use heavy JS for simple state? (Refactor to Radio State Engine or `<details>`).
- [ ] **Visuals:** Are there bitmapped icons/images? (Swap for Inline SVGs).

## Example Use Cases
* **PR Reviews:** Render diffs with inline margin annotations.
* **Implementation Plans:** Use grid layouts for milestones and color-coded risk matrices.
* **Architecture Diagrams:** Draw interactive SVGs that show data flow.