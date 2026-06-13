---
name: core-ai
description: Run on-device AI models in iOS, iPadOS, macOS, and visionOS apps with Core AI. Use when bundling .aimodel files, loading an AIModel, running inference over NDArray tensors, or compiling models ahead of time with coreai-build.
---

# Core AI: On-Device AI Models

## Overview

Core AI runs AI models **on device** inside your app. Inference stays private, works
offline, and has no per-inference cost. You start from a `.aimodel` file (converted
from a model or already in the correct format) that contains one or more named
inference functions, bundle it, load it as an `AIModel`, and run those functions
over `NDArray` tensors (image inputs use a pixel-buffer value).

Available on **Apple Intelligence** devices: iPhone/iPad with A17 Pro or later, Mac
with M1 or later, Apple Vision Pro (M2+). Building requires the **Metal Toolchain**
in Xcode (not installed by default) — without it, builds that include `.aimodel`
files fail with a missing Metal compiler error.

> Core AI runs your own model files at the tensor level. For Apple's high-level
> on-device LLM API (chat sessions, tool calling, guided generation), use the
> Foundation Models framework — a separate framework, not covered here.

## Workflow

1. **Inspect the model** in Xcode's model viewer:
   - _General_ — size (parameter count and on-disk storage), numeric precision split
     into **compute** (used during inference) and **storage** (weights on disk),
     operation distribution, and editable metadata.
   - _Functions_ — each inference function's input/output names, types, and shapes.
     A `?` in a dimension means it is dynamic (supplied or determined at runtime).
2. **Bundle the model** — add the `.aimodel` file to the Xcode target (it appears in
   the _Compile Sources_ build phase). Install the Metal Toolchain first.
3. **Load the model** — `AIModel(contentsOf:)` is asynchronous because Core AI
   **specializes** the model for the current device and selects the compute units
   that deliver the best performance. For large models this can take significant
   time, so consider ahead-of-time compilation (below).
4. **Load a function** — `model.loadFunction(named:)` returns the function or `nil`
   when no function with that name exists (it throws on other load failures). Use
   `functionNames` when a model has multiple functions. The same inference function
   is safe to call from concurrent tasks.
5. **Prepare inputs** — match each input's shape and scalar type from
   `function.descriptor`, then write data through a mutable view.
6. **Run and read outputs** — `function.run(inputs:)` returns outputs keyed by name;
   pull each result with `outputs.remove(_:)` and read it through a view.

## Core API

```swift
import CoreAI

// 1. Specialize for this device and load the model.
let model = try await AIModel(contentsOf: urlOfModel)

// 2. Load the inference function. Returns nil if the name is absent.
guard let function = try model.loadFunction(named: "main") else {
    // Handle a missing function.
}

// 3. Verify the input's shape and scalar type from the descriptor.
let descriptor = function.descriptor
guard let valueDescriptor = descriptor.inputDescriptor(of: "input"),
      case .ndArray(let arrayDescriptor) = valueDescriptor,
      arrayDescriptor.shape == [3, 4],
      arrayDescriptor.scalarType == .float32 else {
    // Handle an unexpected type or shape.
}

// 4. Create the input tensor and write data through a mutable view.
var input = NDArray(shape: [3, 4], scalarType: .float32)
var mutableView = input.mutableView(as: Float.self)
guard let elements = mutableView.contiguousElements else {
    // Handle a non-contiguous memory layout.
}
writeInputData(into: elements)

// 5. Run inference and extract the named output.
var outputs = try await function.run(inputs: ["input": input])
guard let value = outputs.remove("prediction"),
      let prediction = value.ndArray else {
    // Handle a missing or unexpected output.
}
processOutput(prediction.view())
```

### Tensors and values

- `NDArray` — an n-dimensional tensor. Build it with `NDArray(shape:scalarType:)`.
  It is **read-only by default**: use `mutableView(as:)` → `contiguousElements` to
  write, and `view()` to read. Swift enforces read vs. write access at compile time.
- `scalarType` — the element type, e.g. `.float32`. Shape is an `[Int]` matching the
  model's expectation; a `?` dimension in the viewer is dynamic.
- **Images** — values marked as images at conversion time use a pixel-buffer value
  rather than `NDArray`.
- `ValueDescriptor` — `.ndArray(ArrayDescriptor)` vs. image cases. Inspect
  `descriptor.inputDescriptor(of:)` / `outputDescriptor(of:)` at runtime so the app
  can adapt if a function's signature changes between deployments without code edits.

## Ahead-of-Time (AOT) Compilation

On-device specialization can delay first load. Move the most expensive part — model
compilation — to the build machine with the **`coreai-build`** CLI. It converts
`MyModel.aimodel` into one `MyModel.<arch>.aimodelc` asset per device architecture.
At runtime the app picks the asset for the current architecture and loads it with the
**same** `AIModel` API, so loading code does not change.

```bash
# 1. Install the Metal Toolchain (also: Xcode > Settings > Components > Get).
xcodebuild -downloadComponent MetalToolchain

# 2. Compile one .aimodelc per architecture.
xcrun coreai-build compile MyModel.aimodel --platform iOS --output compiled/

# Override compute units, deployment version, target arch, and more:
xcrun coreai-build compile MyModel.aimodel --platform macOS \
    --preferred-compute gpuAndNeuralEngine --output compiled/
xcrun coreai-build compile --help
```

```swift
// Select the compiled asset for this device, then load normally.
let arch = AIModel.deviceArchitectureName
let assetName = "MyModel.\(arch).aimodelc"
let model = try await AIModel(contentsOf: bundledURL(for: assetName))
```

Notes:

- `coreai-build` emits one `.<arch>.aimodelc` per architecture; the filename prefix
  comes from the input model. `AIModel.deviceArchitectureName` is the identifier that
  matches `<arch>` at runtime.
- Compute units default to best performance. Pass `--preferred-compute` to override,
  and use matching load options.
- A compiled asset still requires **some** on-device specialization — AOT removes the
  bulk of compilation, not all of it. AOT only targets Apple Intelligence devices.

## Checklist

- [ ] Metal Toolchain installed (Xcode, or `xcodebuild -downloadComponent MetalToolchain`).
- [ ] `.aimodel` added to the target and visible in _Compile Sources_.
- [ ] `AIModel(contentsOf:)` awaited; slow first load handled (or AOT-compiled).
- [ ] `loadFunction(named:)` nil-checked; `functionNames` inspected for multi-function models.
- [ ] Input `shape` / `scalarType` verified against `function.descriptor`.
- [ ] Mutable views for writes, read-only views for reads.
- [ ] Outputs extracted by name with `outputs.remove(_:)`.
- [ ] For large models: per-architecture `.aimodelc` built via `coreai-build`, and the
      correct asset selected at runtime using `AIModel.deviceArchitectureName`.

## Resources

- Apple — _Integrating on-device AI models in your app with Core AI_
- Apple — _Compiling Core AI models ahead of time_
- Prefer Apple docs for up-to-date API details; web-search the current Core AI
  documentation alongside this skill.
