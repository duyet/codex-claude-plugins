# TypeScript Orchestration

Patterns for TypeScript development, type system usage, and modern best practices.

## Project Setup

### Pattern: Modern TypeScript Configuration

```
Fan-Out (project scaffolding):
├── Agent 1: tsconfig configuration
│   ├── Strict mode settings
│   ├── Module resolution
│   └── Path aliases
│
├── Agent 2: Build tooling
│   ├── ESBuild / SWC / tsc
│   ├── Bundle configuration
│   └── Source maps
│
├── Agent 3: Quality tooling
│   ├── ESLint with typescript-eslint
│   ├── Prettier configuration
│   └── Husky + lint-staged
│
└── Agent 4: Testing setup
    ├── Vitest / Jest configuration
    ├── Type-safe mocking
    └── Coverage settings

Reduce:
→ Complete project template
→ Strict type safety enabled
→ Modern tooling configured
```

### tsconfig.json Template

```json
{
  "compilerOptions": {
    // Strict type checking
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "exactOptionalPropertyTypes": true,

    // Module settings
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "esModuleInterop": true,
    "isolatedModules": true,

    // Output settings
    "target": "ES2022",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,

    // Path aliases
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    },

    // Quality
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## Type System Mastery

### Pattern: Advanced Types

```
Fan-Out (type techniques):
├── Agent 1: Generic patterns
│   ├── Constrained generics
│   ├── Generic inference
│   └── Higher-kinded types simulation
│
├── Agent 2: Utility types
│   ├── Built-in utilities
│   ├── Custom mapped types
│   └── Template literal types
│
├── Agent 3: Conditional types
│   ├── Type narrowing
│   ├── Distributive conditionals
│   └── Infer keyword
│
└── Agent 4: Type guards
    ├── User-defined guards
    ├── Assertion functions
    └── Discriminated unions
```

### Advanced Type Patterns

```typescript
// Branded/Nominal types
type Brand<T, B> = T & { __brand: B };
type UserId = Brand<string, "UserId">;
type OrderId = Brand<string, "OrderId">;

function createUserId(id: string): UserId {
  return id as UserId;
}

// Type-safe builder
type Builder<T, Built extends Partial<T> = {}> = {
  set<K extends keyof T>(
    key: K,
    value: T[K]
  ): Builder<T, Built & Pick<T, K>>;
  build(): Built extends T ? T : never;
};

// Exhaustive switch
function assertNever(x: never): never {
  throw new Error(`Unexpected value: ${x}`);
}

type Status = "pending" | "active" | "done";

function handleStatus(status: Status): string {
  switch (status) {
    case "pending": return "Waiting";
    case "active": return "In progress";
    case "done": return "Complete";
    default: return assertNever(status);
  }
}

// Deep readonly
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object
    ? DeepReadonly<T[K]>
    : T[K];
};

// Type-safe event emitter
type EventMap = {
  userCreated: { id: string; name: string };
  userDeleted: { id: string };
};

class TypedEmitter<Events extends Record<string, unknown>> {
  on<E extends keyof Events>(
    event: E,
    listener: (data: Events[E]) => void
  ): void { /* ... */ }

  emit<E extends keyof Events>(event: E, data: Events[E]): void { /* ... */ }
}
```

## Zod Schema Patterns

### Pattern: Schema-First Development

```
Fan-Out (schema usage):
├── Agent 1: Input validation
│   ├── API request schemas
│   ├── Form validation
│   └── Environment variables
│
├── Agent 2: Type inference
│   ├── z.infer<typeof schema>
│   ├── Shared types between FE/BE
│   └── API contracts
│
├── Agent 3: Transformations
│   ├── transform()
│   ├── preprocess()
│   └── refine()
│
└── Agent 4: Error handling
    ├── Custom error messages
    ├── Error formatting
    └── Partial parsing
```

### Zod Patterns

```typescript
import { z } from "zod";

// Complex schema with refinements
const UserSchema = z.object({
  id: z.string().uuid(),
  email: z.string().email(),
  age: z.number().int().min(0).max(150),
  role: z.enum(["admin", "user", "guest"]),
  metadata: z.record(z.string(), z.unknown()).optional(),
  createdAt: z.coerce.date(),
});

type User = z.infer<typeof UserSchema>;

// Schema with transformations
const ApiResponseSchema = z.object({
  data: z.array(UserSchema),
  pagination: z.object({
    page: z.number(),
    total: z.number(),
  }),
}).transform((val) => ({
  users: val.data,
  ...val.pagination,
}));

// Discriminated unions
const EventSchema = z.discriminatedUnion("type", [
  z.object({ type: z.literal("click"), x: z.number(), y: z.number() }),
  z.object({ type: z.literal("keypress"), key: z.string() }),
  z.object({ type: z.literal("scroll"), delta: z.number() }),
]);

// Environment validation
const EnvSchema = z.object({
  NODE_ENV: z.enum(["development", "production", "test"]),
  DATABASE_URL: z.string().url(),
  API_KEY: z.string().min(32),
  PORT: z.coerce.number().default(3000),
});

export const env = EnvSchema.parse(process.env);

// Partial and async validation
async function validateUser(input: unknown): Promise<User> {
  return UserSchema.parseAsync(input);
}

function safeValidate(input: unknown) {
  const result = UserSchema.safeParse(input);
  if (result.success) {
    return { data: result.data, error: null };
  }
  return { data: null, error: result.error.format() };
}
```

## Error Handling

### Pattern: Result Types

```typescript
// Result type implementation
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function Ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

function Err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

// Usage
async function fetchUser(id: string): Promise<Result<User, ApiError>> {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (!response.ok) {
      return Err({ code: "NOT_FOUND", message: "User not found" });
    }
    const data = await response.json();
    return Ok(UserSchema.parse(data));
  } catch (error) {
    return Err({ code: "NETWORK", message: String(error) });
  }
}

// Pattern matching
const result = await fetchUser("123");
if (result.ok) {
  console.log(result.value.name);
} else {
  console.error(result.error.message);
}

// neverthrow library pattern
import { ResultAsync, errAsync, okAsync } from "neverthrow";

function safeDivide(a: number, b: number): Result<number, string> {
  if (b === 0) return Err("Division by zero");
  return Ok(a / b);
}
```

## Testing Strategy

### Pattern: Type-Safe Testing

```
Fan-Out (test types):
├── Agent 1: Unit tests
│   ├── Pure function tests
│   ├── Type tests (tsd)
│   └── Mock type safety
│
├── Agent 2: Integration tests
│   ├── API testing
│   ├── Database testing
│   └── Service integration
│
├── Agent 3: E2E tests
│   ├── Playwright/Cypress
│   ├── Visual regression
│   └── Accessibility
│
└── Agent 4: Type testing
    ├── expectType assertions
    ├── Negative type tests
    └── Generic inference tests
```

### Vitest Patterns

```typescript
import { describe, it, expect, vi, beforeEach } from "vitest";
import type { Mock } from "vitest";

// Type-safe mocking
interface UserService {
  getUser(id: string): Promise<User>;
  createUser(data: CreateUserData): Promise<User>;
}

const mockUserService: {
  [K in keyof UserService]: Mock<UserService[K]>;
} = {
  getUser: vi.fn(),
  createUser: vi.fn(),
};

describe("UserController", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it("should fetch user", async () => {
    const user: User = { id: "1", name: "Test", email: "test@test.com" };
    mockUserService.getUser.mockResolvedValue(user);

    const result = await controller.getUser("1");

    expect(result).toEqual(user);
    expect(mockUserService.getUser).toHaveBeenCalledWith("1");
  });
});

// Type testing with tsd
import { expectType, expectError } from "tsd";

// These are compile-time checks
expectType<string>(getString());
expectError(getString(123)); // Should error
```

## Module Patterns

### Pattern: Clean Architecture

```typescript
// Dependency injection with types
interface Dependencies {
  userRepository: UserRepository;
  emailService: EmailService;
  logger: Logger;
}

function createUserService(deps: Dependencies) {
  return {
    async createUser(data: CreateUserData): Promise<User> {
      deps.logger.info("Creating user", { email: data.email });
      const user = await deps.userRepository.create(data);
      await deps.emailService.sendWelcome(user.email);
      return user;
    },
  };
}

// Factory pattern with generics
type Factory<T, Args extends unknown[] = []> = (...args: Args) => T;

const createLogger: Factory<Logger, [string]> = (namespace) => ({
  info: (msg, ctx) => console.log(`[${namespace}]`, msg, ctx),
  error: (msg, ctx) => console.error(`[${namespace}]`, msg, ctx),
});

// Repository pattern
interface Repository<T, Id = string> {
  findById(id: Id): Promise<T | null>;
  findAll(filter?: Partial<T>): Promise<T[]>;
  create(data: Omit<T, "id">): Promise<T>;
  update(id: Id, data: Partial<T>): Promise<T>;
  delete(id: Id): Promise<void>;
}

class UserRepository implements Repository<User> {
  // Implementation
}
```

## Async Patterns

### Pattern: Concurrent Operations

```typescript
// Parallel with error handling
async function fetchAllUsers(ids: string[]): Promise<Result<User[], Error>[]> {
  return Promise.all(ids.map((id) => fetchUser(id)));
}

// Concurrent with limit
async function processWithLimit<T, R>(
  items: T[],
  fn: (item: T) => Promise<R>,
  limit: number
): Promise<R[]> {
  const results: R[] = [];
  const executing: Promise<void>[] = [];

  for (const item of items) {
    const promise = fn(item).then((result) => {
      results.push(result);
    });

    executing.push(promise);

    if (executing.length >= limit) {
      await Promise.race(executing);
      executing.splice(
        executing.findIndex((p) => p === promise),
        1
      );
    }
  }

  await Promise.all(executing);
  return results;
}

// Retry with exponential backoff
async function retry<T>(
  fn: () => Promise<T>,
  options: { attempts: number; delay: number; backoff?: number }
): Promise<T> {
  const { attempts, delay, backoff = 2 } = options;

  for (let i = 0; i < attempts; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === attempts - 1) throw error;
      await new Promise((r) => setTimeout(r, delay * Math.pow(backoff, i)));
    }
  }

  throw new Error("Unreachable");
}
```

## Best Practices

### Type Safety Guidelines

| Do | Don't |
|----|-------|
| Enable `strict: true` | Use `any` |
| Use `unknown` for unknown types | Use `as` without validation |
| Define explicit return types | Rely on implicit `any` |
| Use const assertions | Widen literal types unnecessarily |
| Validate at boundaries | Trust external data |
| Use branded types for IDs | Mix different ID types |

### Module Organization

```
src/
├── domain/           # Business logic, pure types
│   ├── user/
│   │   ├── types.ts
│   │   ├── schema.ts
│   │   └── service.ts
│   └── order/
├── infrastructure/   # External integrations
│   ├── database/
│   ├── http/
│   └── cache/
├── application/      # Use cases, orchestration
│   └── handlers/
├── interface/        # API, CLI, UI
│   ├── api/
│   └── cli/
└── shared/          # Utilities, common types
    ├── types.ts
    └── utils.ts
```
