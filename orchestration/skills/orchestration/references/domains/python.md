# Python Orchestration

Patterns for Python development, testing, packaging, and best practices.

## Project Setup

### Pattern: Parallel Initialization

```
Fan-Out (project scaffolding):
├── Agent 1: Project structure
│   ├── src layout or flat layout
│   ├── Package organization
│   └── Module structure
│
├── Agent 2: Development tooling
│   ├── pyproject.toml configuration
│   ├── Linting (ruff, black, isort)
│   └── Type checking (mypy, pyright)
│
├── Agent 3: Testing setup
│   ├── pytest configuration
│   ├── Coverage settings
│   └── Test fixtures
│
└── Agent 4: CI/CD pipeline
    ├── GitHub Actions / GitLab CI
    ├── Pre-commit hooks
    └── Release automation

Reduce:
→ Complete project template
→ Development environment ready
→ CI pipeline configured
```

### Modern Project Structure

```
project-name/
├── src/
│   └── package_name/
│       ├── __init__.py
│       ├── core/
│       ├── utils/
│       └── py.typed          # PEP 561 marker
├── tests/
│   ├── conftest.py
│   ├── unit/
│   └── integration/
├── pyproject.toml            # PEP 517/518
├── README.md
└── .pre-commit-config.yaml
```

### pyproject.toml Template

```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "package-name"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = []

[project.optional-dependencies]
dev = ["pytest", "ruff", "mypy", "pre-commit"]

[tool.ruff]
line-length = 88
select = ["E", "F", "I", "N", "W", "UP", "B", "C4", "SIM"]

[tool.mypy]
strict = true
python_version = "3.11"

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "-v --cov=src"
```

## Code Quality

### Pattern: Multi-Tool Analysis

```
Fan-Out (parallel checks):
├── Agent 1: Linting (ruff)
│   ├── Style violations
│   ├── Import ordering
│   └── Code complexity
│
├── Agent 2: Type checking (mypy)
│   ├── Type errors
│   ├── Missing annotations
│   └── Protocol compliance
│
├── Agent 3: Security scan (bandit)
│   ├── Hardcoded secrets
│   ├── SQL injection
│   └── Unsafe deserialization
│
└── Agent 4: Dependency audit
    ├── Outdated packages
    ├── Security vulnerabilities
    └── License compliance

Reduce:
→ Consolidated report
→ Priority fixes
→ Auto-fix suggestions
```

### Type Annotation Patterns

```python
# Modern Python typing (3.10+)
from collections.abc import Callable, Iterable, Mapping
from typing import TypeVar, ParamSpec, Self

T = TypeVar("T")
P = ParamSpec("P")

# Function with complex signature
def retry(
    func: Callable[P, T],
    *,
    attempts: int = 3,
    delay: float = 1.0,
) -> Callable[P, T]: ...

# Protocol for duck typing
from typing import Protocol

class Repository(Protocol):
    def get(self, id: str) -> dict[str, Any]: ...
    def save(self, entity: dict[str, Any]) -> None: ...

# Generic class
class Result[T]:
    def __init__(self, value: T) -> None:
        self.value = value

    def map[U](self, fn: Callable[[T], U]) -> "Result[U]":
        return Result(fn(self.value))
```

## Testing Strategy

### Pattern: Layered Testing

```
Fan-Out (test types):
├── Agent 1: Unit tests
│   ├── Pure functions
│   ├── Class methods
│   └── Edge cases
│
├── Agent 2: Integration tests
│   ├── Database operations
│   ├── External APIs
│   └── File I/O
│
├── Agent 3: Property-based tests
│   ├── Hypothesis strategies
│   ├── Invariant checking
│   └── Fuzzing
│
└── Agent 4: Performance tests
    ├── Benchmark critical paths
    ├── Memory profiling
    └── Async performance

Reduce:
→ Coverage report
→ Performance baseline
→ Regression detection
```

### pytest Patterns

```python
# Fixtures with scope
import pytest
from collections.abc import Iterator

@pytest.fixture(scope="session")
def database() -> Iterator[Database]:
    db = Database.connect()
    yield db
    db.disconnect()

@pytest.fixture
def user(database: Database) -> User:
    return database.create_user(name="test")

# Parametrized tests
@pytest.mark.parametrize(
    "input,expected",
    [
        ("hello", "HELLO"),
        ("world", "WORLD"),
        ("", ""),
    ],
)
def test_uppercase(input: str, expected: str) -> None:
    assert uppercase(input) == expected

# Async tests
@pytest.mark.asyncio
async def test_async_fetch() -> None:
    result = await fetch_data()
    assert result.status == 200

# Property-based testing
from hypothesis import given, strategies as st

@given(st.lists(st.integers()))
def test_sort_idempotent(xs: list[int]) -> None:
    assert sorted(sorted(xs)) == sorted(xs)
```

## Async Python

### Pattern: Concurrent Execution

```
Fan-Out (async patterns):
├── Agent 1: Task groups
│   ├── asyncio.TaskGroup
│   ├── Error handling
│   └── Cancellation
│
├── Agent 2: Connection pools
│   ├── aiohttp sessions
│   ├── Database pools
│   └── Resource limits
│
├── Agent 3: Synchronization
│   ├── asyncio.Lock
│   ├── Semaphores
│   └── Events
│
└── Agent 4: Streaming
    ├── Async generators
    ├── AsyncIterator protocol
    └── Backpressure handling
```

### Async Patterns

```python
import asyncio
from contextlib import asynccontextmanager
from collections.abc import AsyncIterator

# Task group (Python 3.11+)
async def fetch_all(urls: list[str]) -> list[Response]:
    async with asyncio.TaskGroup() as tg:
        tasks = [tg.create_task(fetch(url)) for url in urls]
    return [task.result() for task in tasks]

# Async context manager
@asynccontextmanager
async def get_connection() -> AsyncIterator[Connection]:
    conn = await pool.acquire()
    try:
        yield conn
    finally:
        await pool.release(conn)

# Async generator with cleanup
async def stream_data() -> AsyncIterator[bytes]:
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            async for chunk in response.content.iter_chunked(1024):
                yield chunk

# Semaphore for rate limiting
semaphore = asyncio.Semaphore(10)

async def rate_limited_fetch(url: str) -> Response:
    async with semaphore:
        return await fetch(url)
```

## Package Development

### Pattern: Release Pipeline

```
Phase 1: Preparation (parallel)
├── Agent 1: Version bump
├── Agent 2: Changelog generation
├── Agent 3: Documentation update
└── Agent 4: Dependency check

Phase 2: Validation (sequential)
├── Full test suite
├── Type checking
├── Build verification
└── Install test

Phase 3: Release
├── Tag creation
├── PyPI upload
├── Documentation deploy
└── Announcement
```

### Publishing Workflow

```bash
# Build
python -m build

# Check
twine check dist/*

# Upload to TestPyPI
twine upload --repository testpypi dist/*

# Test install
pip install --index-url https://test.pypi.org/simple/ package-name

# Upload to PyPI
twine upload dist/*
```

## Performance Optimization

### Pattern: Profile-Driven

```
Phase 1: Profiling (parallel)
├── Agent 1: CPU profiling (cProfile, py-spy)
├── Agent 2: Memory profiling (memray, tracemalloc)
├── Agent 3: I/O profiling (strace, async timing)
└── Agent 4: Line profiling (line_profiler)

Phase 2: Analysis
→ Identify hot spots
→ Categorize bottleneck types
→ Prioritize by impact

Phase 3: Optimization (parallel by type)
├── Algorithm improvements
├── Data structure changes
├── Caching implementation
└── Parallelization
```

### Common Optimizations

| Bottleneck | Solution |
|------------|----------|
| Loop overhead | List comprehension, generators |
| String concatenation | `"".join()`, f-strings |
| Repeated lookups | Local variable caching |
| Large data copies | Slices, itertools, generators |
| I/O bound | asyncio, threading |
| CPU bound | multiprocessing, Cython, numba |

## Error Handling

### Pattern: Comprehensive Strategy

```python
from typing import TypeVar, NoReturn
from dataclasses import dataclass

T = TypeVar("T")

# Result type pattern
@dataclass
class Ok[T]:
    value: T

@dataclass
class Err:
    error: Exception

type Result[T] = Ok[T] | Err

def safe_divide(a: float, b: float) -> Result[float]:
    if b == 0:
        return Err(ValueError("Division by zero"))
    return Ok(a / b)

# Exception hierarchy
class AppError(Exception):
    """Base application error."""

class ValidationError(AppError):
    """Input validation failed."""

class NotFoundError(AppError):
    """Resource not found."""

# Context manager for cleanup
from contextlib import contextmanager
from collections.abc import Iterator

@contextmanager
def managed_resource() -> Iterator[Resource]:
    resource = acquire_resource()
    try:
        yield resource
    except Exception:
        resource.rollback()
        raise
    else:
        resource.commit()
    finally:
        resource.close()
```

## Best Practices

### Code Style

| Do | Don't |
|----|-------|
| Use type hints everywhere | Leave types implicit |
| Prefer composition over inheritance | Deep inheritance hierarchies |
| Use dataclasses/attrs for data | Manual __init__ with many args |
| Use pathlib for paths | String manipulation for paths |
| Use enum for constants | Magic strings/numbers |
| Use contextlib for resources | Manual try/finally |

### Dependency Management

```toml
# Pin direct dependencies loosely
dependencies = [
    "httpx>=0.25.0,<1.0",
    "pydantic>=2.0,<3.0",
]

# Pin dev dependencies tightly in lock file
# Use uv, pip-tools, or poetry for lock files
```

### Documentation

```python
def process_data(
    data: list[dict[str, Any]],
    *,
    validate: bool = True,
    transform: Callable[[dict], dict] | None = None,
) -> list[dict[str, Any]]:
    """Process a list of data records.

    Args:
        data: Input records to process.
        validate: Whether to validate records before processing.
        transform: Optional transformation function to apply.

    Returns:
        Processed records with transformations applied.

    Raises:
        ValidationError: If validate=True and records are invalid.
        ProcessingError: If transformation fails.

    Example:
        >>> process_data([{"id": 1}], transform=lambda x: {**x, "processed": True})
        [{"id": 1, "processed": True}]
    """
```
