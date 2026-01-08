# Test Detection & Fix Strategies

Reusable knowledge for detecting project types and fixing common test issues.

## Project Type Detection

### Python Projects

**Detection Files:**
- `pyproject.toml` (modern)
- `setup.py` (legacy)
- `requirements.txt`
- `Pipfile`

**Test Frameworks:**
| Framework | Config | Run Command |
|-----------|--------|-------------|
| pytest | `pytest.ini`, `pyproject.toml [tool.pytest]` | `pytest` or `python -m pytest` |
| unittest | built-in | `python -m unittest discover` |
| nose2 | `setup.cfg` | `nose2` |

**Linting/Type Checking:**
| Tool | Config | Run Command |
|------|--------|-------------|
| ruff | `pyproject.toml [tool.ruff]` | `ruff check .` |
| flake8 | `.flake8`, `setup.cfg` | `flake8` |
| mypy | `mypy.ini`, `pyproject.toml [tool.mypy]` | `mypy .` |
| black | `pyproject.toml [tool.black]` | `black --check .` |

**Common Fix Patterns:**
```python
# Assertion error: Check expected vs actual values
# ImportError: Check virtual environment, dependencies
# TypeError: Check function signatures, type hints
# AttributeError: Check object initialization
```

### Node/TypeScript Projects

**Detection Files:**
- `package.json`
- `tsconfig.json` (TypeScript)

**Test Frameworks:**
| Framework | Config | Run Command |
|-----------|--------|-------------|
| Jest | `jest.config.js` | `npm test` or `npx jest` |
| Vitest | `vite.config.ts` | `npm test` or `npx vitest` |
| Mocha | `.mocharc.js` | `npm test` or `npx mocha` |
| Playwright | `playwright.config.ts` | `npx playwright test` |

**Linting/Type Checking:**
| Tool | Config | Run Command |
|------|--------|-------------|
| ESLint | `.eslintrc.*`, `eslint.config.js` | `npm run lint` or `npx eslint .` |
| TypeScript | `tsconfig.json` | `npm run type-check` or `npx tsc --noEmit` |
| Prettier | `.prettierrc` | `npm run format` or `npx prettier --check .` |

**Common Fix Patterns:**
```typescript
// Type error: Add proper type annotations
// undefined is not a function: Check imports, async/await
// Test timeout: Increase timeout, check async handling
// Mock not working: Verify mock setup in beforeEach
```

### Rust Projects

**Detection Files:**
- `Cargo.toml`

**Commands:**
| Purpose | Command |
|---------|---------|
| Tests | `cargo test` |
| Linting | `cargo clippy` |
| Format | `cargo fmt --check` |
| Build | `cargo build` |

**Common Fix Patterns:**
```rust
// Borrow checker: Review ownership, use references
// Type mismatch: Check trait implementations
// Unused variable: Prefix with underscore or remove
```

### Go Projects

**Detection Files:**
- `go.mod`

**Commands:**
| Purpose | Command |
|---------|---------|
| Tests | `go test ./...` |
| Linting | `golint ./...` or `golangci-lint run` |
| Format | `go fmt ./...` |
| Vet | `go vet ./...` |

## Fix Strategy Matrix

| Issue Type | Complexity | Strategy |
|------------|------------|----------|
| Single test failure | Low | Direct fix in main agent |
| Multiple test failures (same file) | Low | Direct fix in main agent |
| Multiple test failures (different files) | Medium | Consider parallel agents |
| Linting errors | Low | Auto-fix when possible |
| Type errors | Medium | Analyze root cause first |
| Build errors | High | Fix dependencies first |
| Integration test failures | High | Check external deps, use mocks |

## Parallel Agent Assignment

When spawning agents for complex fixes:

```
Domain Detection:
- Python tests → Senior Agent (Python expertise)
- TypeScript types → Senior Agent (TS expertise)
- React components → Senior Agent (Frontend expertise)
- API/Backend → Senior Agent (Backend expertise)
- Infrastructure → Senior Agent (DevOps expertise)
```

## Mock Strategy

Default to mocking for:
- Database connections
- External API calls
- File system operations (when appropriate)
- Network requests
- Time-dependent operations

Do NOT mock:
- Core business logic
- Unit under test
- Simple utility functions
