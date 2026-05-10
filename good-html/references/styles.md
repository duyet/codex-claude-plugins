# Good HTML Design System & Styles

This guide defines the aesthetic standards for `good-html` artifacts. Strictly follow these to avoid the "generic AI" look and produce professional, high-fidelity engineering documents.

## 1. Color Palettes
Avoid standard bright blue/purple gradients. Use these muted, sophisticated palettes.

### Core Palette (The "Engineering" Look)
*   `--ivory`: `#FAF9F5` (Main background)
*   `--paper`: `#FFFFFF` (Card background)
*   `--slate`: `#141413` (Main text)
*   `--clay`: `#D97757` (Primary accent / Warnings)
*   `--olive`: `#788C5D` (Success / Safe / Secondary accent)
*   `--oat`: `#E3DACC` (Borders / Background accents)
*   `--rust`: `#B04A3F` (Critical / Errors)

### Neutrals (Grays)
*   `--g100`: `#F0EEE6` (Code background / Section headers)
*   `--g200`: `#E6E3DA` (Subtle borders)
*   `--g300`: `#D1CFC5` (Prominent borders)
*   `--g500`: `#87867F` (Muted text / Captions)
*   `--g700`: `#3D3D3A` (Stronger accents)

## 2. Typography
Use robust system font stacks.

*   **Serif (Headers):** `ui-serif, Georgia, "Times New Roman", Times, serif;`
    *   *Usage:* Use for `h1`, `h2`, and quotes. It gives the document a "published" or "official report" feel.
*   **Sans (Body):** `system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;`
    *   *Usage:* Main body text, UI labels.
*   **Mono (Code):** `ui-monospace, "SF Mono", Menlo, Monaco, Consolas, monospace;`
    *   *Usage:* Code blocks, badges, technical IDs, and data labels.

## 3. UI Components Style
*   **Cards:** 1.5px solid borders (`--g300`), 12px border radius, subtle box-shadow (`0 4px 12px rgba(20,20,19,0.03)`).
*   **Badges:** 1.5px solid borders, monospaced font, small caps or all caps for labels.
*   **Spacing:** Use generous padding (48px top/bottom for pages, 24px for cards) and a tall `line-height: 1.55`.

## 4. Layout Rules
*   **Page Width:** Maximum `920px` for optimal readability.
*   **Grid Gap:** Standardize on `20px` or `24px`.
*   **Sticky Elements:** Always stick headers for long data tables or sidebars for multi-section reports to maintain context.
