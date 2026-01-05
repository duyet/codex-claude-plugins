# shadcn/ui Orchestration

Patterns for building with shadcn/ui component library and design system.

## Core Philosophy

shadcn/ui is NOT a component library—it's a collection of reusable components you copy into your project. You own the code, you customize freely.

## Project Setup

### Pattern: Initial Configuration

```
Fan-Out (setup steps):
├── Agent 1: CLI initialization
│   ├── npx shadcn@latest init
│   ├── Style selection
│   └── Tailwind configuration
│
├── Agent 2: Theme configuration
│   ├── CSS variables setup
│   ├── Color scheme design
│   └── Dark mode preparation
│
├── Agent 3: Component structure
│   ├── components/ui organization
│   ├── Import path aliases
│   └── Barrel exports
│
└── Agent 4: Typography setup
    ├── Font loading
    ├── Prose styles
    └── Heading scales

Reduce:
→ Complete shadcn setup
→ Custom theme applied
→ Ready for component addition
```

### components.json Template

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.ts",
    "css": "app/globals.css",
    "baseColor": "zinc",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui",
    "lib": "@/lib",
    "hooks": "@/hooks"
  },
  "iconLibrary": "lucide"
}
```

## Component Patterns

### Pattern: Component Composition

```
Fan-Out (component building):
├── Agent 1: Base component
│   ├── Primitive from Radix
│   ├── Accessibility built-in
│   └── Unstyled foundation
│
├── Agent 2: Styling layer
│   ├── Tailwind classes
│   ├── Variant system (cva)
│   └── Dark mode support
│
├── Agent 3: Compound components
│   ├── Context provider
│   ├── Sub-components
│   └── Composition API
│
└── Agent 4: Extended variants
    ├── Size variants
    ├── Color variants
    └── State variants
```

### Component Structure

```typescript
// Button with variants using cva
import { cva, type VariantProps } from "class-variance-authority";
import { cn } from "@/lib/utils";

const buttonVariants = cva(
  // Base styles
  "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground shadow hover:bg-primary/90",
        destructive: "bg-destructive text-destructive-foreground shadow-sm hover:bg-destructive/90",
        outline: "border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground",
        secondary: "bg-secondary text-secondary-foreground shadow-sm hover:bg-secondary/80",
        ghost: "hover:bg-accent hover:text-accent-foreground",
        link: "text-primary underline-offset-4 hover:underline",
      },
      size: {
        default: "h-9 px-4 py-2",
        sm: "h-8 rounded-md px-3 text-xs",
        lg: "h-10 rounded-md px-8",
        icon: "h-9 w-9",
      },
    },
    defaultVariants: {
      variant: "default",
      size: "default",
    },
  }
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  asChild?: boolean;
}

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : "button";
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    );
  }
);
```

## Theming System

### Pattern: Custom Theme Creation

```
Fan-Out (theme aspects):
├── Agent 1: Color palette
│   ├── Primary/secondary colors
│   ├── Semantic colors (success, warning, error)
│   └── Neutral scale
│
├── Agent 2: Spacing & sizing
│   ├── Consistent scale
│   ├── Component spacing
│   └── Layout spacing
│
├── Agent 3: Typography
│   ├── Font families
│   ├── Size scale
│   └── Line heights
│
└── Agent 4: Effects
    ├── Border radius scale
    ├── Shadow scale
    └── Animation timing
```

### CSS Variables Structure

```css
@layer base {
  :root {
    /* Background colors */
    --background: 0 0% 100%;
    --foreground: 240 10% 3.9%;

    /* Card surfaces */
    --card: 0 0% 100%;
    --card-foreground: 240 10% 3.9%;

    /* Popover surfaces */
    --popover: 0 0% 100%;
    --popover-foreground: 240 10% 3.9%;

    /* Primary brand color */
    --primary: 240 5.9% 10%;
    --primary-foreground: 0 0% 98%;

    /* Secondary surfaces */
    --secondary: 240 4.8% 95.9%;
    --secondary-foreground: 240 5.9% 10%;

    /* Muted elements */
    --muted: 240 4.8% 95.9%;
    --muted-foreground: 240 3.8% 46.1%;

    /* Accent highlights */
    --accent: 240 4.8% 95.9%;
    --accent-foreground: 240 5.9% 10%;

    /* Destructive actions */
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 0 0% 98%;

    /* Borders and inputs */
    --border: 240 5.9% 90%;
    --input: 240 5.9% 90%;
    --ring: 240 5.9% 10%;

    /* Border radius scale */
    --radius: 0.5rem;

    /* Chart colors */
    --chart-1: 12 76% 61%;
    --chart-2: 173 58% 39%;
    --chart-3: 197 37% 24%;
    --chart-4: 43 74% 66%;
    --chart-5: 27 87% 67%;
  }

  .dark {
    --background: 240 10% 3.9%;
    --foreground: 0 0% 98%;
    /* ... dark mode overrides */
  }
}
```

## Form Patterns

### Pattern: React Hook Form + Zod + shadcn

```
Fan-Out (form building):
├── Agent 1: Schema definition
│   ├── Zod validation schema
│   ├── Type inference
│   └── Error messages
│
├── Agent 2: Form structure
│   ├── useForm hook setup
│   ├── FormProvider context
│   └── Field registration
│
├── Agent 3: Field components
│   ├── FormField wrapper
│   ├── FormItem layout
│   └── FormMessage errors
│
└── Agent 4: Submission handling
    ├── onSubmit handler
    ├── Loading states
    └── Success/error feedback
```

### Form Implementation

```typescript
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

const formSchema = z.object({
  email: z.string().email("Invalid email address"),
  password: z.string().min(8, "Password must be at least 8 characters"),
});

type FormValues = z.infer<typeof formSchema>;

export function LoginForm() {
  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      email: "",
      password: "",
    },
  });

  async function onSubmit(values: FormValues) {
    // Handle submission
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email</FormLabel>
              <FormControl>
                <Input placeholder="you@example.com" {...field} />
              </FormControl>
              <FormDescription>
                We'll never share your email.
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="password"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Password</FormLabel>
              <FormControl>
                <Input type="password" {...field} />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button type="submit" disabled={form.formState.isSubmitting}>
          {form.formState.isSubmitting ? "Signing in..." : "Sign in"}
        </Button>
      </form>
    </Form>
  );
}
```

## Data Display Patterns

### Pattern: Data Table

```typescript
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  ColumnDef,
  flexRender,
  getCoreRowModel,
  useReactTable,
  getPaginationRowModel,
  getSortedRowModel,
  getFilteredRowModel,
} from "@tanstack/react-table";

interface DataTableProps<TData, TValue> {
  columns: ColumnDef<TData, TValue>[];
  data: TData[];
}

export function DataTable<TData, TValue>({
  columns,
  data,
}: DataTableProps<TData, TValue>) {
  const table = useReactTable({
    data,
    columns,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
  });

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          {table.getHeaderGroups().map((headerGroup) => (
            <TableRow key={headerGroup.id}>
              {headerGroup.headers.map((header) => (
                <TableHead key={header.id}>
                  {header.isPlaceholder
                    ? null
                    : flexRender(
                        header.column.columnDef.header,
                        header.getContext()
                      )}
                </TableHead>
              ))}
            </TableRow>
          ))}
        </TableHeader>
        <TableBody>
          {table.getRowModel().rows?.length ? (
            table.getRowModel().rows.map((row) => (
              <TableRow key={row.id}>
                {row.getVisibleCells().map((cell) => (
                  <TableCell key={cell.id}>
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </TableCell>
                ))}
              </TableRow>
            ))
          ) : (
            <TableRow>
              <TableCell colSpan={columns.length} className="h-24 text-center">
                No results.
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </div>
  );
}
```

## Component Categories

### Quick Reference

| Category | Components |
|----------|------------|
| **Layout** | Card, Separator, Tabs, Accordion, Collapsible, Resizable |
| **Navigation** | NavigationMenu, Breadcrumb, Pagination, Sidebar |
| **Forms** | Form, Input, Textarea, Select, Checkbox, RadioGroup, Switch, Slider, Calendar, DatePicker |
| **Feedback** | Alert, AlertDialog, Toast, Sonner, Progress, Skeleton |
| **Overlay** | Dialog, Sheet, Drawer, Popover, Tooltip, HoverCard, ContextMenu, DropdownMenu |
| **Data Display** | Table, DataTable, Avatar, Badge, Command |

## Best Practices

### Component Guidelines

| Do | Don't |
|----|-------|
| Copy and customize components | Keep components unchanged |
| Use CSS variables for theming | Hardcode colors |
| Compose compound components | Create monolithic components |
| Add custom variants as needed | Override with arbitrary classes |
| Use cn() for class merging | String concatenation for classes |
| Keep components accessible | Remove ARIA attributes |

### File Organization

```
components/
├── ui/                    # shadcn/ui primitives
│   ├── button.tsx
│   ├── input.tsx
│   ├── dialog.tsx
│   └── ...
├── forms/                 # Form compositions
│   ├── login-form.tsx
│   └── signup-form.tsx
├── layout/               # Layout components
│   ├── header.tsx
│   ├── sidebar.tsx
│   └── footer.tsx
└── features/             # Feature-specific
    ├── dashboard/
    └── settings/
```

### CLI Commands

```bash
# Add components
npx shadcn@latest add button card dialog

# Add multiple components
npx shadcn@latest add button input label form

# Update components
npx shadcn@latest add button --overwrite

# View available components
npx shadcn@latest add --all
```
