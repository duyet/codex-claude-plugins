---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, or applications. Generates creative, polished code that avoids generic AI aesthetics.
---

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

## When to Invoke This Skill

Automatically activate for:
- Building UI components, pages, dashboards, or applications
- Creating landing pages, forms, or interactive interfaces
- Designing data visualizations or charts
- Implementing design systems or component libraries
- Any frontend work where visual quality matters

## Design Thinking

Before coding, understand the context and commit to a BOLD aesthetic direction:

1. **Purpose**: What problem does this interface solve? Who uses it?
2. **Tone**: Pick a distinctive aesthetic:
   - Brutally minimal | Maximalist chaos | Retro-futuristic
   - Organic/natural | Luxury/refined | Playful/toy-like
   - Editorial/magazine | Brutalist/raw | Art deco/geometric
   - Soft/pastel | Industrial/utilitarian | Neo-brutalist
   - Swiss/grid-based | Cyberpunk/neon | Scandinavian/calm
3. **Constraints**: Technical requirements (framework, performance, accessibility)
4. **Differentiation**: What makes this UNFORGETTABLE?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision.

## Technology Stack Preferences

### Component Libraries (Priority Order)
1. **shadcn/ui** - First choice for React projects. Copy components, full customization.
2. **Radix UI** - Accessible primitives when shadcn isn't available
3. **Headless UI** - For Tailwind-based projects
4. **Custom CSS** - When libraries aren't appropriate

### Data Visualization
1. **Recharts** - First choice for charts in React. Clean, composable, customizable.
2. **Tremor** - Dashboard-ready charts with great defaults
3. **Victory** - When Recharts doesn't fit
4. **D3.js** - For complex, custom visualizations only

### Styling
1. **Tailwind CSS** - Utility-first, consistent spacing/colors
2. **CSS Variables** - For theming and design tokens
3. **CSS Modules** - When Tailwind isn't available

### Animation
1. **Framer Motion** - First choice for React animations
2. **CSS animations** - For simple, performant effects
3. **GSAP** - For complex timeline animations

## Anti-Slop Design Rules

### NEVER Use These (AI Slop Indicators)

**Typography Slop**:
- Inter, Roboto, Arial, system-ui as primary fonts
- Font sizes that are too uniform (everything 14-16px)
- Generic font pairings (Inter + Inter)

**Color Slop**:
- Purple/violet gradients on white backgrounds
- Blue-to-purple CTA buttons
- Washed-out, low-contrast color schemes
- Rainbow gradients for no reason
- Generic blue (#3B82F6) as primary color

**Layout Slop**:
- Perfectly centered everything
- Cards with equal rounded corners (rounded-lg everywhere)
- Symmetric layouts with no visual hierarchy
- Grid of 3-4 identical cards pattern
- Hero with centered text + gradient background + floating shapes

**Component Slop**:
- Glassmorphism on everything
- Shadows that are too soft and uniform
- Generic avatar circles with gradient backgrounds
- Empty state illustrations that are too cute
- Progress bars with gradient fills

**Animation Slop**:
- Fade-in on scroll for everything
- Bounce effects on buttons
- Spinning loaders when skeleton screens work better
- Hover effects that all feel the same

### INSTEAD, Create Distinctive Design

**Typography That Stands Out**:
```
Display fonts: Clash Display, Cabinet Grotesk, Satoshi, Space Grotesk (sparingly),
               Instrument Serif, Fraunces, Playfair Display, Editorial New
Body fonts: Geist, Plus Jakarta Sans, DM Sans, Source Serif Pro, Literata
Monospace: JetBrains Mono, Fira Code, IBM Plex Mono
```
- Create contrast between display and body fonts
- Use larger type than feels comfortable (48px+ for headlines)
- Vary font weights dramatically (300 vs 700)

**Color With Intent**:
- Pick ONE dominant color and use it sparingly
- Use near-black (#0A0A0A, #111111) instead of pure black
- Create depth with subtle gradients in backgrounds
- Use color for meaning, not decoration
- Consider dark mode as primary (not afterthought)

**Layouts That Break the Grid**:
- Asymmetric compositions with clear hierarchy
- Overlapping elements that create depth
- Generous negative space OR intentional density
- Grid-breaking hero elements
- Varying content widths within the same page

**Components With Character**:
- Micro-interactions that feel tactile
- Loading states that match the brand
- Error states that are helpful and on-brand
- Empty states that guide rather than decorate
- Form inputs that feel substantial

## React Component Architecture

Design components like you are the creator of React. Think in composition, reusability, and elegance.

### Component Philosophy

**Small, Focused Components**:
- Each component does ONE thing well
- Prefer 20-50 lines per component
- If a component exceeds 100 lines, split it
- Name components by what they ARE, not what they DO

**Composition Over Configuration**:
```tsx
// BAD: Monolithic component with many props
<Card
  title="User Profile"
  subtitle="Settings"
  avatar={user.avatar}
  showBadge={true}
  badgeColor="green"
  actions={[...]}
/>

// GOOD: Composable components
<Card>
  <Card.Header>
    <Avatar src={user.avatar} />
    <Card.Title>User Profile</Card.Title>
    <Badge variant="success" />
  </Card.Header>
  <Card.Content>...</Card.Content>
  <Card.Actions>...</Card.Actions>
</Card>
```

### Props Design Principles

**Meaningful, Typed Props**:
```tsx
// Generic, reusable props
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost' | 'destructive';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  disabled?: boolean;
  children: React.ReactNode;
}

// State props that tell a story
interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  isLoading?: boolean;
  isEmpty?: boolean;
  onRowClick?: (row: T) => void;
  selectedRows?: Set<string>;
}
```

**Prop Patterns**:
- Use `children` for content (not `content` prop)
- Use render props for customization: `renderItem`, `renderEmpty`
- Use compound patterns for complex UIs
- Avoid boolean props when variants work better

### State Management

**Local State First**:
```tsx
// Keep state as close to where it's used as possible
function SearchInput({ onSearch }: { onSearch: (query: string) => void }) {
  const [query, setQuery] = useState('');
  const debouncedSearch = useDebouncedCallback(onSearch, 300);

  return (
    <Input
      value={query}
      onChange={(e) => {
        setQuery(e.target.value);
        debouncedSearch(e.target.value);
      }}
    />
  );
}
```

**Lift State Only When Needed**:
- Lift when siblings need to share state
- Lift when parent needs to control behavior
- Don't lift "just in case"

### Component Patterns

**1. Container/Presenter Pattern**:
```tsx
// Container: handles data fetching, state
function UserProfileContainer({ userId }: { userId: string }) {
  const { data: user, isLoading } = useUser(userId);
  if (isLoading) return <UserProfileSkeleton />;
  return <UserProfile user={user} />;
}

// Presenter: pure UI, receives props
function UserProfile({ user }: { user: User }) {
  return (
    <Card>
      <Avatar src={user.avatar} />
      <h2>{user.name}</h2>
    </Card>
  );
}
```

**2. Compound Components**:
```tsx
// Parent provides context
const TabsContext = createContext<TabsContextValue>(null);

function Tabs({ children, defaultValue }: TabsProps) {
  const [active, setActive] = useState(defaultValue);
  return (
    <TabsContext.Provider value={{ active, setActive }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

Tabs.List = TabsList;
Tabs.Tab = Tab;
Tabs.Panel = TabPanel;

// Usage
<Tabs defaultValue="overview">
  <Tabs.List>
    <Tabs.Tab value="overview">Overview</Tabs.Tab>
    <Tabs.Tab value="settings">Settings</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel value="overview">...</Tabs.Panel>
</Tabs>
```

**3. Render Props for Flexibility**:
```tsx
interface ListProps<T> {
  items: T[];
  renderItem: (item: T, index: number) => React.ReactNode;
  renderEmpty?: () => React.ReactNode;
  keyExtractor: (item: T) => string;
}

function List<T>({ items, renderItem, renderEmpty, keyExtractor }: ListProps<T>) {
  if (items.length === 0 && renderEmpty) return renderEmpty();
  return (
    <ul>
      {items.map((item, i) => (
        <li key={keyExtractor(item)}>{renderItem(item, i)}</li>
      ))}
    </ul>
  );
}
```

### File Organization

```
components/
├── ui/                    # Primitive components (Button, Input, Card)
│   ├── button.tsx
│   ├── input.tsx
│   └── card.tsx
├── patterns/              # Composed patterns (DataTable, Form, Modal)
│   ├── data-table/
│   │   ├── data-table.tsx
│   │   ├── data-table-header.tsx
│   │   ├── data-table-row.tsx
│   │   └── index.ts
│   └── form/
├── features/              # Feature-specific components
│   ├── dashboard/
│   └── settings/
└── layouts/               # Page layouts
    ├── sidebar-layout.tsx
    └── centered-layout.tsx
```

### Anti-Patterns to Avoid

**Component Slop**:
- Giant 500+ line components
- Props drilling through 5+ levels
- `useEffect` for everything
- Inline styles mixed with Tailwind
- `any` types on props

**Instead**:
- Split into smaller, focused components
- Use Context or composition for deep data
- Prefer derived state over effects
- Consistent styling approach
- Strict TypeScript types

## shadcn/ui Quick Reference

**Core Philosophy**: shadcn/ui is NOT a component library—it's how you build your component library. You get actual component code that you own and can modify.

### Quick Start

```bash
# Initialize shadcn/ui
npx shadcn@latest init

# Add components
npx shadcn@latest add button card dialog

# Search registry
npx shadcn@latest search @shadcn -q "button"
```

### Key Principles

1. **Open Code**: Full transparency, easy customization, AI-readable
2. **Composition**: Common, composable interface across all components
3. **Distribution**: Flat-file schema + CLI for easy installation
4. **Beautiful Defaults**: Great design out-of-the-box, easily customizable
5. **AI-Ready**: Open code structure for LLMs to understand and improve

### Component Categories

| Category | Components |
|----------|------------|
| **Form & Input** | Form, Field, Button, Input, Textarea, Checkbox, Radio, Select, Switch, Slider, Calendar, Date Picker, Combobox |
| **Layout & Navigation** | Accordion, Breadcrumb, Navigation Menu, Sidebar, Tabs, Separator, Scroll Area, Resizable |
| **Overlays & Dialogs** | Dialog, Alert Dialog, Sheet, Drawer, Popover, Tooltip, Hover Card, Context Menu, Dropdown Menu, Command |
| **Feedback & Status** | Alert, Toast, Progress, Spinner, Skeleton, Badge, Empty |
| **Display & Media** | Avatar, Card, Table, Data Table, Chart, Carousel, Aspect Ratio, Typography |

### Theming Basics

```tsx
// Color convention: background + foreground
<div className="bg-background text-foreground">Hello</div>
<div className="bg-primary text-primary-foreground">Primary</div>
<div className="bg-muted text-muted-foreground">Muted</div>
```

### Customization Tips

1. **Customize the theme** - Don't use defaults
   ```css
   :root {
     --radius: 0.5rem; /* or 0 for sharp corners */
     --primary: 220 13% 10%; /* custom primary */
   }
   ```

2. **Extend components** - Add custom variants, modify animations, adjust spacing

3. **Combine primitives** - Layer components for unique effects

### For Complete Documentation

See [references/shadcn.md](references/shadcn.md) for:
- Complete components.json configuration
- Full theming system with CSS variables
- Dark mode setup guide
- CLI commands reference
- MCP server integration
- Registry schema for publishing components

## Recharts Quick Reference

When creating charts:

1. **Style the chart to match the UI**
   ```jsx
   <ResponsiveContainer>
     <LineChart data={data}>
       <Line
         type="monotone"
         strokeWidth={2}
         dot={false}
         stroke="hsl(var(--primary))"
       />
       <XAxis
         tickLine={false}
         axisLine={false}
         tick={{ fill: 'hsl(var(--muted-foreground))' }}
       />
     </LineChart>
   </ResponsiveContainer>
   ```

2. **Remove visual clutter**
   - Hide axis lines when not needed
   - Use subtle grid lines or none
   - Custom tooltips that match your design

3. **Add meaningful interactions**
   - Hover states that reveal detail
   - Click handlers for drill-down
   - Animate data changes smoothly

## Implementation Checklist

Before considering frontend work complete:

- [ ] Typography creates clear hierarchy (display vs body)
- [ ] Colors are intentional and consistent (CSS variables)
- [ ] Spacing follows a rhythm (8px/4px grid)
- [ ] Interactive elements have hover/focus/active states
- [ ] Loading and empty states exist
- [ ] Dark mode works (if applicable)
- [ ] Animations are smooth (60fps, no jank)
- [ ] Accessibility: keyboard navigation, ARIA labels, color contrast
- [ ] Mobile responsive (or explicitly desktop-only)
- [ ] Code is production-ready (no console logs, proper error handling)

## Output Format

When implementing frontend:

1. **Explain the aesthetic direction** (2-3 sentences)
2. **List key design decisions** (typography, colors, key components)
3. **Provide complete, working code** with:
   - All imports and dependencies noted
   - CSS/Tailwind classes included
   - TypeScript types when applicable
   - Comments for non-obvious choices

Remember: Claude is capable of extraordinary creative work. Commit fully to a distinctive vision that could only have been designed for this specific context.

## Micro-Interaction Polish

The difference between good and exceptional interfaces lies in microscopic details that users feel but don't consciously notice. These patterns make interfaces feel "expensive" and polished.

### 1. Typography Enhancement

**Text Wrapping for Headlines**:
```css
/* Prevents awkward widows in headlines */
.hero-title {
  text-wrap: balance;  /* Optimizes line breaks for headlines */
}

/* For multi-line text where you want pretty breaks */
.description {
  text-wrap: pretty;   /* Last line minimum 4 characters */
}
```
- Use `balance` for headlines, titles, and short text blocks
- Use `pretty` for descriptions, summaries, and body text where you want to avoid orphans

**Font Smoothing**:
```css
body {
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}
```
- Critical for Mac rendering—removes "thin" look from fonts
- Makes text appear more substantial and premium
- Apply globally to `body` or typography containers

**Tabular Numbers**:
```css
.price, .metric, .stat {
  font-variant-numeric: tabular-nums;
}
```
- Essential for data, prices, metrics—prevents jitter when numbers animate
- Use for anything that changes value dynamically
- Avoids visual shifting during countdowns, tickers, or live data

### 2. Border Radius Consistency

**Concentric Formula**:
```css
/* Outer radius = Inner radius + padding */
.card {
  padding: 1.5rem;
  border-radius: 16px;
}

.card-inner {
  border-radius: calc(16px - 1.5rem); /* Concentric borders align perfectly */
}
```
- When nesting elements with borders, adjust inner radius by subtracting padding
- Creates perfect alignment between concentric rounded corners
- Prevents "thick border" appearance at corners

### 3. Icon Animation Patterns

**Contextual Icon States**:
```css
.icon {
  transition: all 0.2s ease;
  opacity: 0.6;
  transform: scale(1);
}

.icon:hover {
  opacity: 1;
  transform: scale(1.1);
}

.icon.active {
  opacity: 1;
  transform: scale(1);
  filter: drop-shadow(0 0 8px currentColor);
}
```
- Icons should breathe: subtle scale + opacity changes
- Use `filter: drop-shadow()` instead of `box-shadow` for icons (respects shape)
- Keep animations under 200ms for responsive feel

### 4. Animation Philosophy

**Interruptible Animations**:
```css
/* GOOD: CSS transitions—user can interrupt */
.button {
  transition: transform 0.2s ease, opacity 0.2s ease;
}
.button:hover {
  transform: translateY(-2px);
}

/* AVOID: Keyframes for interactions—can't be interrupted */
@keyframes slideUp {
  from { transform: translateY(20px); opacity: 0; }
  to { transform: translateY(0); opacity: 1; }
}
```
- Use CSS **transitions** for user-triggered animations (hover, click, focus)
- Transitions can be interrupted when user moves away/clicks quickly
- Reserve keyframes for continuous, non-interactive animations (loaders, backgrounds)

**Split and Stagger Enter**:
```css
/* Elements enter from different directions */
.card:nth-child(3n+1) { animation: slideFromLeft 0.4s ease forwards; }
.card:nth-child(3n+2) { animation: slideFromBottom 0.4s ease forwards; }
.card:nth-child(3n+3) { animation: slideFromRight 0.4s ease forwards; }

/* Stagger with delay */
.card:nth-child(1) { animation-delay: 0ms; }
.card:nth-child(2) { animation-delay: 50ms; }
.card:nth-child(3) { animation-delay: 100ms; }
```
- Vary entrance directions based on position for visual interest
- Stagger delays: 50-100ms between elements feels premium, not sluggish
- Never exceed 300ms total delay—users hate waiting for content

**Subtle Exit Animations**:
```css
.modal.closing {
  animation: fadeOut 0.15s ease forwards;
}
@keyframes fadeOut {
  to { opacity: 0; transform: scale(0.98); }
}
```
- Exits should be faster than enters (150ms vs 300-400ms)
- Users want to dismiss things quickly
- Skip exit animations if it delays navigation

### 5. Alignment Precision

**Optical vs Geometric Alignment**:
```css
/* Geometric center looks "off" with triangle icons */
.icon-triangle {
  transform: translateY(-1px); /* Nudge down for optical center */
}

/* Circles appear smaller than squares at same size */
.icon-circle {
  transform: scale(1.1); /* Slight scale for visual balance */
}
```
- Trust your eyes, not the grid
- Triangles, stars, and irregular shapes need optical adjustment
- Different shapes at same "size" need visual balancing
- Test: squint—if something feels off, adjust by 1-2px

### 6. Depth Without Borders

**Shadows Over Borders**:
```css
.card {
  /* Instead of: border: 1px solid #e5e5e5; */
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.08),
              0 1px 2px rgba(0, 0, 0, 0.04);
}

.card-elevated {
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1),
              0 2px 4px -1px rgba(0, 0, 0, 0.06);
}
```
- Shadows create depth without harsh edges
- Layer multiple shadows for subtle, natural elevation
- Borders can look "flat" or "boxed in"
- Exception: use borders for grouping, dividers, or interactive states

**Image Outlines**:
```css
.image-container {
  position: relative;
}

.image-container::after {
  content: '';
  position: absolute;
  inset: 0;
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: inherit;
  pointer-events: none;
}
```
- Ultra-subtle 1px border at 10% opacity adds polish to images
- Creates clean separation without visual weight
- Use on images, cards, or featured content
- In dark mode, use white with low opacity; light mode, use black

### 7. Micro-Interaction Timing

```css
/* Fast interactions feel responsive */
.fast-interaction { transition-duration: 150ms; }

/* Standard interactions feel smooth */
.standard-interaction { transition-duration: 200ms; }

/* Slow animations feel deliberate */
.deliberate-motion { transition-duration: 400ms; }
```
- 150ms: hover states, button clicks, toggle switches
- 200ms: card lifts, dropdown opens, tooltip appears
- 400ms+: page transitions, modal enters, complex animations
- Never use 1s+ for anything—feels sluggish

### Micro-Interaction Checklist

Before shipping UI:
- [ ] Headlines use `text-wrap: balance`
- [ ] Font smoothing is applied (`antialiased`)
- [ ] Numbers/data use `tabular-nums`
- [ ] Concentric borders align (radius - padding formula)
- [ ] Icons breathe (scale + opacity on hover)
- [ ] User interactions use transitions (not keyframes)
- [ ] Entrance animations are split/staggered
- [ ] Exit animations are faster than enter
- [ ] Irregular icons are optically aligned
- [ ] Depth uses shadows (not borders)
- [ ] Images have ultra-subtle outlines
- [ ] Animation timing feels responsive (≤200ms for interactions)
