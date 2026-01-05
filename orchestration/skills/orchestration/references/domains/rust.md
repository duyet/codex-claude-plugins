# Rust Orchestration

Patterns for Rust development, ownership handling, and systems programming.

## Project Setup

### Pattern: Workspace Initialization

```
Fan-Out (project scaffolding):
├── Agent 1: Cargo workspace structure
│   ├── Workspace layout
│   ├── Member crates
│   └── Shared dependencies
│
├── Agent 2: Toolchain configuration
│   ├── rust-toolchain.toml
│   ├── Clippy configuration
│   └── rustfmt.toml
│
├── Agent 3: Testing infrastructure
│   ├── Unit test modules
│   ├── Integration tests
│   └── Benchmarks (criterion)
│
└── Agent 4: CI/CD setup
    ├── GitHub Actions
    ├── Cross-compilation
    └── Release automation

Reduce:
→ Complete workspace
→ Consistent tooling
→ Ready for development
```

### Workspace Structure

```
project/
├── Cargo.toml              # Workspace root
├── rust-toolchain.toml
├── .cargo/
│   └── config.toml
├── crates/
│   ├── core/               # Core library
│   │   ├── Cargo.toml
│   │   └── src/
│   ├── cli/                # CLI binary
│   │   ├── Cargo.toml
│   │   └── src/
│   └── shared/             # Shared types
│       ├── Cargo.toml
│       └── src/
├── tests/                  # Integration tests
└── benches/                # Benchmarks
```

### Cargo.toml Template

```toml
[workspace]
resolver = "2"
members = ["crates/*"]

[workspace.package]
edition = "2021"
rust-version = "1.75"
license = "MIT"
repository = "https://github.com/user/project"

[workspace.dependencies]
tokio = { version = "1.0", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
thiserror = "1.0"
anyhow = "1.0"
tracing = "0.1"

[workspace.lints.rust]
unsafe_code = "forbid"

[workspace.lints.clippy]
all = "warn"
pedantic = "warn"
nursery = "warn"
```

## Error Handling

### Pattern: Type-Safe Errors

```
Fan-Out (error strategy):
├── Agent 1: Custom error types (thiserror)
│   ├── Domain errors
│   ├── Error variants
│   └── Error context
│
├── Agent 2: Error propagation (anyhow)
│   ├── Context addition
│   ├── Error chaining
│   └── Backtraces
│
├── Agent 3: Result patterns
│   ├── Type aliases
│   ├── Conversion traits
│   └── Error mapping
│
└── Agent 4: Recovery strategies
    ├── Retry logic
    ├── Fallback behavior
    └── Graceful degradation
```

### Error Type Patterns

```rust
use thiserror::Error;

// Domain-specific errors
#[derive(Debug, Error)]
pub enum AppError {
    #[error("User not found: {id}")]
    UserNotFound { id: String },

    #[error("Validation failed: {0}")]
    Validation(String),

    #[error("Database error")]
    Database(#[from] sqlx::Error),

    #[error("IO error: {context}")]
    Io {
        context: String,
        #[source]
        source: std::io::Error,
    },
}

// Result type alias
pub type Result<T> = std::result::Result<T, AppError>;

// With anyhow for application code
use anyhow::{Context, Result};

fn load_config(path: &Path) -> Result<Config> {
    let content = std::fs::read_to_string(path)
        .with_context(|| format!("Failed to read config from {}", path.display()))?;

    toml::from_str(&content)
        .context("Failed to parse config as TOML")
}
```

## Ownership Patterns

### Pattern: Lifetime Management

```
Analysis checklist:
├── Identify ownership transfer points
├── Map borrowing relationships
├── Detect lifetime elision opportunities
├── Find unnecessary clones
└── Optimize with Cow<T>
```

### Common Patterns

```rust
use std::borrow::Cow;

// Builder pattern with ownership
pub struct RequestBuilder {
    url: String,
    headers: Vec<(String, String)>,
}

impl RequestBuilder {
    pub fn new(url: impl Into<String>) -> Self {
        Self {
            url: url.into(),
            headers: Vec::new(),
        }
    }

    pub fn header(mut self, key: impl Into<String>, value: impl Into<String>) -> Self {
        self.headers.push((key.into(), value.into()));
        self
    }

    pub fn build(self) -> Request {
        Request { url: self.url, headers: self.headers }
    }
}

// Cow for flexible ownership
fn process_text(input: &str) -> Cow<'_, str> {
    if input.contains("replace_me") {
        Cow::Owned(input.replace("replace_me", "replaced"))
    } else {
        Cow::Borrowed(input)
    }
}

// Interior mutability
use std::cell::RefCell;
use std::rc::Rc;

struct Cache<T> {
    data: RefCell<Option<T>>,
}

impl<T: Clone> Cache<T> {
    fn get_or_init(&self, init: impl FnOnce() -> T) -> T {
        let mut data = self.data.borrow_mut();
        data.get_or_insert_with(init).clone()
    }
}
```

## Async Rust

### Pattern: Tokio Ecosystem

```
Fan-Out (async components):
├── Agent 1: Runtime configuration
│   ├── Multi-threaded vs current-thread
│   ├── Worker threads
│   └── Blocking pool
│
├── Agent 2: Task management
│   ├── spawn vs spawn_blocking
│   ├── JoinSet usage
│   └── Cancellation
│
├── Agent 3: Synchronization
│   ├── tokio::sync primitives
│   ├── Channels (mpsc, broadcast, watch)
│   └── Mutexes and RwLocks
│
└── Agent 4: I/O patterns
    ├── AsyncRead/AsyncWrite
    ├── Buffering strategies
    └── Timeouts and deadlines
```

### Async Patterns

```rust
use tokio::sync::{mpsc, oneshot};
use tokio::task::JoinSet;

// Concurrent task execution
async fn fetch_all(urls: Vec<String>) -> Vec<Result<Response, Error>> {
    let mut set = JoinSet::new();

    for url in urls {
        set.spawn(async move { fetch(&url).await });
    }

    let mut results = Vec::new();
    while let Some(result) = set.join_next().await {
        results.push(result.unwrap());
    }
    results
}

// Actor pattern with channels
struct Actor {
    receiver: mpsc::Receiver<Message>,
    state: State,
}

impl Actor {
    async fn run(mut self) {
        while let Some(msg) = self.receiver.recv().await {
            self.handle_message(msg).await;
        }
    }

    async fn handle_message(&mut self, msg: Message) {
        match msg {
            Message::Get { respond_to } => {
                let _ = respond_to.send(self.state.clone());
            }
            Message::Set { value } => {
                self.state = value;
            }
        }
    }
}

// Graceful shutdown
async fn run_server(shutdown: oneshot::Receiver<()>) {
    tokio::select! {
        _ = serve() => {}
        _ = shutdown => {
            tracing::info!("Shutdown signal received");
        }
    }
}
```

## Testing Strategy

### Pattern: Comprehensive Testing

```
Fan-Out (test types):
├── Agent 1: Unit tests
│   ├── Module tests (#[cfg(test)])
│   ├── Doc tests
│   └── Property tests (proptest)
│
├── Agent 2: Integration tests
│   ├── Binary tests
│   ├── Database tests
│   └── API tests
│
├── Agent 3: Async tests
│   ├── tokio::test
│   ├── Mock time
│   └── Test utilities
│
└── Agent 4: Benchmarks
    ├── Criterion benchmarks
    ├── Memory benchmarks
    └── Flamegraphs
```

### Test Patterns

```rust
#[cfg(test)]
mod tests {
    use super::*;

    // Basic test
    #[test]
    fn test_addition() {
        assert_eq!(add(2, 2), 4);
    }

    // Async test
    #[tokio::test]
    async fn test_async_fetch() {
        let result = fetch("http://example.com").await;
        assert!(result.is_ok());
    }

    // Property-based test
    use proptest::prelude::*;

    proptest! {
        #[test]
        fn test_sort_is_idempotent(mut vec: Vec<i32>) {
            vec.sort();
            let sorted = vec.clone();
            vec.sort();
            prop_assert_eq!(vec, sorted);
        }
    }

    // Test with fixtures
    #[fixture]
    fn database() -> TestDatabase {
        TestDatabase::new()
    }

    #[rstest]
    fn test_with_db(database: TestDatabase) {
        // Use database fixture
    }
}
```

## Performance Optimization

### Pattern: Profile-Driven

```
Phase 1: Profiling (parallel)
├── Agent 1: CPU profiling (perf, flamegraph)
├── Agent 2: Memory profiling (heaptrack, valgrind)
├── Agent 3: Allocation tracking (dhat)
└── Agent 4: Benchmark analysis (criterion)

Phase 2: Optimization
├── Algorithm improvements
├── Data structure selection
├── SIMD opportunities
├── Parallelization (rayon)
└── Memory layout optimization
```

### Optimization Techniques

```rust
// Avoid allocations with iterators
fn sum_evens(nums: &[i32]) -> i32 {
    nums.iter()
        .filter(|&&n| n % 2 == 0)
        .sum()
}

// Parallel iteration with rayon
use rayon::prelude::*;

fn parallel_process(items: &[Item]) -> Vec<Result> {
    items.par_iter()
        .map(|item| process(item))
        .collect()
}

// SmallVec for small collections
use smallvec::SmallVec;

fn collect_small(iter: impl Iterator<Item = u8>) -> SmallVec<[u8; 8]> {
    iter.collect()
}

// Avoid bounds checks with get_unchecked (careful!)
fn fast_sum(slice: &[i32]) -> i32 {
    let mut sum = 0;
    for i in 0..slice.len() {
        // SAFETY: i is always in bounds
        sum += unsafe { *slice.get_unchecked(i) };
    }
    sum
}
```

## FFI and Unsafe

### Pattern: Safe Abstractions

```
Fan-Out (FFI concerns):
├── Agent 1: C bindings
│   ├── bindgen usage
│   ├── Type mappings
│   └── Memory safety
│
├── Agent 2: Safe wrappers
│   ├── RAII patterns
│   ├── Error conversion
│   └── Panic safety
│
├── Agent 3: Testing
│   ├── Miri for UB detection
│   ├── Sanitizers
│   └── Fuzzing
│
└── Agent 4: Documentation
    ├── Safety invariants
    ├── SAFETY comments
    └── Usage examples
```

### Safe Wrapper Pattern

```rust
// Raw C bindings
mod ffi {
    extern "C" {
        pub fn create_resource() -> *mut Resource;
        pub fn destroy_resource(ptr: *mut Resource);
        pub fn use_resource(ptr: *mut Resource) -> i32;
    }
}

// Safe wrapper
pub struct SafeResource {
    ptr: *mut ffi::Resource,
}

impl SafeResource {
    pub fn new() -> Option<Self> {
        // SAFETY: create_resource returns valid pointer or null
        let ptr = unsafe { ffi::create_resource() };
        if ptr.is_null() {
            None
        } else {
            Some(Self { ptr })
        }
    }

    pub fn use_it(&self) -> i32 {
        // SAFETY: ptr is valid for lifetime of self
        unsafe { ffi::use_resource(self.ptr) }
    }
}

impl Drop for SafeResource {
    fn drop(&mut self) {
        // SAFETY: ptr was created by create_resource
        unsafe { ffi::destroy_resource(self.ptr) };
    }
}

// SAFETY: Resource is thread-safe per C library docs
unsafe impl Send for SafeResource {}
unsafe impl Sync for SafeResource {}
```

## Best Practices

### Code Style

| Do | Don't |
|----|-------|
| Use `clippy::pedantic` | Ignore clippy warnings |
| Prefer `&str` over `String` for params | Clone strings unnecessarily |
| Use `?` for error propagation | Explicit match on every Result |
| Derive traits when possible | Manual impl for common traits |
| Use `#[must_use]` on important returns | Ignore unused Results |
| Document `# Safety` for unsafe | Undocumented unsafe blocks |

### Cargo Best Practices

```toml
# Use workspace dependencies
[dependencies]
serde.workspace = true

# Feature flags for optional deps
[features]
default = []
full = ["feature-a", "feature-b"]
feature-a = ["dep:optional-dep"]

# Optimize release builds
[profile.release]
lto = true
codegen-units = 1
strip = true

# Fast compile for dev
[profile.dev]
opt-level = 0
debug = true
```
