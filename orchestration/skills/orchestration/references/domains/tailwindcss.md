# Tailwind CSS Orchestration

Patterns for building with Tailwind CSS utility-first framework.

## Project Setup

### Pattern: Modern Tailwind v4 Configuration

```
Fan-Out (setup steps):
├── Agent 1: Installation
│   ├── Package installation
│   ├── PostCSS configuration
│   └── Build tooling integration
│
├── Agent 2: Theme customization
│   ├── Color palette
│   ├── Typography scale
│   └── Spacing/sizing
│
├── Agent 3: Plugin configuration
│   ├── Official plugins
│   ├── Custom plugins
│   └── Third-party integrations
│
└── Agent 4: Content configuration
    ├── Content paths
    ├── Safelist patterns
    └── Blocklist patterns

Reduce:
→ Optimized Tailwind setup
→ Custom design tokens
→ Production-ready config
```

### Tailwind v4 CSS Configuration

```css
/* app.css - Tailwind v4 uses CSS-first configuration */
@import "tailwindcss";

/* Custom theme using CSS */
@theme {
  /* Colors */
  --color-primary-50: oklch(97% 0.02 250);
  --color-primary-100: oklch(94% 0.04 250);
  --color-primary-500: oklch(55% 0.25 250);
  --color-primary-600: oklch(48% 0.25 250);
  --color-primary-900: oklch(25% 0.15 250);

  /* Custom spacing */
  --spacing-18: 4.5rem;
  --spacing-112: 28rem;
  --spacing-128: 32rem;

  /* Typography */
  --font-family-display: "Cal Sans", system-ui, sans-serif;
  --font-family-body: "Inter", system-ui, sans-serif;

  /* Border radius */
  --radius-4xl: 2rem;

  /* Animations */
  --animate-fade-in: fade-in 0.3s ease-out;
}

@keyframes fade-in {
  from { opacity: 0; transform: translateY(-4px); }
  to { opacity: 1; transform: translateY(0); }
}

/* Custom utilities */
@utility text-balance {
  text-wrap: balance;
}

@utility scrollbar-hide {
  -ms-overflow-style: none;
  scrollbar-width: none;
  &::-webkit-scrollbar {
    display: none;
  }
}
```

### Legacy v3 Config (for reference)

```typescript
// tailwind.config.ts
import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  darkMode: "class",
  theme: {
    extend: {
      colors: {
        primary: {
          50: "#f0f9ff",
          500: "#3b82f6",
          600: "#2563eb",
          900: "#1e3a8a",
        },
      },
      fontFamily: {
        display: ["var(--font-display)", "system-ui"],
        body: ["var(--font-body)", "system-ui"],
      },
      animation: {
        "fade-in": "fade-in 0.3s ease-out",
      },
      keyframes: {
        "fade-in": {
          from: { opacity: "0", transform: "translateY(-4px)" },
          to: { opacity: "1", transform: "translateY(0)" },
        },
      },
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("@tailwindcss/forms"),
    require("@tailwindcss/container-queries"),
  ],
};

export default config;
```

## Design Patterns

### Pattern: Component Class Organization

```
Fan-Out (class organization):
├── Agent 1: Layout classes
│   ├── Flexbox/Grid
│   ├── Positioning
│   └── Sizing
│
├── Agent 2: Spacing classes
│   ├── Margin/padding
│   ├── Gap
│   └── Space utilities
│
├── Agent 3: Visual classes
│   ├── Colors
│   ├── Typography
│   └── Effects
│
└── Agent 4: Interactive classes
    ├── Hover states
    ├── Focus states
    └── Active states
```

### Class Order Convention

```tsx
// Recommended order for Tailwind classes
<div
  className={cn(
    // 1. Layout (display, position)
    "flex relative",
    // 2. Sizing
    "w-full max-w-md h-auto",
    // 3. Spacing (margin, padding)
    "mx-auto p-6",
    // 4. Typography
    "text-sm font-medium text-gray-900",
    // 5. Visual (bg, border, shadow)
    "bg-white rounded-lg border border-gray-200 shadow-sm",
    // 6. Interactivity
    "hover:shadow-md focus:ring-2 focus:ring-blue-500",
    // 7. Transitions
    "transition-shadow duration-200",
    // 8. Responsive (last)
    "md:p-8 lg:max-w-lg"
  )}
>
```

## Responsive Design

### Pattern: Mobile-First Approach

```tsx
// Mobile-first responsive design
<div className="
  // Mobile (default)
  flex flex-col gap-4 p-4

  // Tablet (md: 768px)
  md:flex-row md:gap-6 md:p-6

  // Desktop (lg: 1024px)
  lg:gap-8 lg:p-8

  // Large desktop (xl: 1280px)
  xl:max-w-6xl xl:mx-auto
">
  <aside className="
    // Mobile: full width, top
    w-full

    // Tablet+: sidebar
    md:w-64 md:shrink-0
  ">
    {/* Sidebar content */}
  </aside>

  <main className="
    // Mobile: full width
    flex-1 min-w-0
  ">
    {/* Main content */}
  </main>
</div>
```

### Container Queries (v3.2+)

```tsx
// Parent with container
<div className="@container">
  {/* Responsive to container, not viewport */}
  <div className="
    @sm:flex-row
    @md:grid @md:grid-cols-2
    @lg:grid-cols-3
  ">
    {/* Content adapts to container size */}
  </div>
</div>
```

## Dark Mode

### Pattern: Dark Mode Implementation

```tsx
// Class-based dark mode
<div className="
  bg-white dark:bg-gray-900
  text-gray-900 dark:text-gray-100
  border-gray-200 dark:border-gray-700
">

// Using CSS variables for theming
<div className="
  bg-background text-foreground
  border-border
">
```

### Theme Toggle

```tsx
import { useTheme } from "next-themes";
import { Moon, Sun } from "lucide-react";

export function ThemeToggle() {
  const { theme, setTheme } = useTheme();

  return (
    <button
      onClick={() => setTheme(theme === "dark" ? "light" : "dark")}
      className="
        p-2 rounded-md
        hover:bg-gray-100 dark:hover:bg-gray-800
        transition-colors
      "
    >
      <Sun className="h-5 w-5 rotate-0 scale-100 transition-transform dark:-rotate-90 dark:scale-0" />
      <Moon className="absolute h-5 w-5 rotate-90 scale-0 transition-transform dark:rotate-0 dark:scale-100" />
    </button>
  );
}
```

## Animation Patterns

### Pattern: Micro-Interactions

```css
/* Custom animations in CSS */
@theme {
  --animate-slide-up: slide-up 0.3s ease-out;
  --animate-slide-down: slide-down 0.3s ease-out;
  --animate-scale-in: scale-in 0.2s ease-out;
  --animate-spin-slow: spin 3s linear infinite;
}

@keyframes slide-up {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes scale-in {
  from { opacity: 0; transform: scale(0.95); }
  to { opacity: 1; transform: scale(1); }
}
```

```tsx
// Usage in components
<div className="animate-slide-up">
  Content slides up on mount
</div>

// Hover animations
<button className="
  transform transition-transform duration-200
  hover:scale-105 active:scale-95
">
  Interactive Button
</button>

// Staggered animations with delay
<ul>
  {items.map((item, i) => (
    <li
      key={item.id}
      className="animate-slide-up"
      style={{ animationDelay: `${i * 100}ms` }}
    >
      {item.name}
    </li>
  ))}
</ul>
```

## Layout Patterns

### Grid Systems

```tsx
// Responsive grid
<div className="
  grid gap-4
  grid-cols-1
  sm:grid-cols-2
  lg:grid-cols-3
  xl:grid-cols-4
">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>

// Auto-fit grid (responsive without breakpoints)
<div className="
  grid gap-4
  grid-cols-[repeat(auto-fit,minmax(280px,1fr))]
">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>

// Dashboard layout
<div className="
  grid gap-4
  grid-cols-12
">
  <div className="col-span-12 lg:col-span-8">Main content</div>
  <div className="col-span-12 lg:col-span-4">Sidebar</div>
</div>
```

### Flexbox Patterns

```tsx
// Center content
<div className="flex items-center justify-center min-h-screen">
  <div>Centered content</div>
</div>

// Space between header
<header className="flex items-center justify-between p-4">
  <Logo />
  <nav className="flex gap-4">
    <Link>Home</Link>
    <Link>About</Link>
  </nav>
</header>

// Stack with auto spacing
<div className="flex flex-col gap-4">
  <div>Item 1</div>
  <div>Item 2</div>
  <div className="mt-auto">Pushed to bottom</div>
</div>
```

## Typography

### Pattern: Prose Styling

```tsx
// Using @tailwindcss/typography
<article className="
  prose prose-lg
  dark:prose-invert
  prose-headings:font-display
  prose-a:text-primary-600
  prose-img:rounded-lg
  max-w-none
">
  {/* Rendered markdown content */}
</article>

// Custom typography scale
<h1 className="text-4xl font-bold tracking-tight sm:text-5xl lg:text-6xl">
  Hero Heading
</h1>
<p className="text-lg text-gray-600 dark:text-gray-400 leading-relaxed">
  Body text with good readability
</p>
```

## Performance Optimization

### Pattern: Production Optimization

```
Fan-Out (optimization areas):
├── Agent 1: Content configuration
│   ├── Precise content paths
│   ├── Exclude unused files
│   └── Safelist dynamic classes
│
├── Agent 2: CSS optimization
│   ├── Remove unused styles
│   ├── Minification
│   └── Critical CSS extraction
│
├── Agent 3: Build optimization
│   ├── JIT compilation
│   ├── Caching strategies
│   └── Incremental builds
│
└── Agent 4: Runtime optimization
    ├── Avoid runtime class generation
    ├── Use static class names
    └── Minimize dynamic styling
```

### Dynamic Classes (Safe Patterns)

```tsx
// DON'T: Dynamic class construction (won't be detected)
const color = "red";
<div className={`text-${color}-500`}> // Broken!

// DO: Complete class names
const colorClasses = {
  red: "text-red-500",
  blue: "text-blue-500",
  green: "text-green-500",
};
<div className={colorClasses[color]}> // Works!

// DO: Safelist if truly dynamic
// In tailwind.config.ts:
safelist: [
  { pattern: /^text-(red|blue|green)-500$/ },
]
```

## Best Practices

### Class Guidelines

| Do | Don't |
|----|-------|
| Use design tokens (colors, spacing) | Arbitrary values everywhere |
| Mobile-first responsive | Desktop-first approach |
| Consistent spacing scale | Random px values |
| Use `cn()` for conditional classes | Template literal conditionals |
| Extract repeated patterns | Copy-paste class strings |
| Use CSS variables for themes | Hardcode colors |

### Utility Extraction

```tsx
// styles/components.ts - Reusable class patterns
export const buttonBase = cn(
  "inline-flex items-center justify-center",
  "font-medium rounded-md",
  "transition-colors duration-200",
  "focus:outline-none focus:ring-2 focus:ring-offset-2"
);

export const buttonPrimary = cn(
  buttonBase,
  "bg-primary-600 text-white",
  "hover:bg-primary-700",
  "focus:ring-primary-500"
);

export const cardBase = cn(
  "rounded-lg border bg-card",
  "text-card-foreground shadow-sm"
);

// Usage
<button className={cn(buttonPrimary, "px-4 py-2")}>
  Click me
</button>
```

### Class Merging with cn()

```typescript
// lib/utils.ts
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// Usage - later classes override earlier ones
cn("px-4 py-2", "px-6") // → "py-2 px-6"
cn("text-red-500", condition && "text-blue-500")
cn("base-class", className) // Accept className prop
```
