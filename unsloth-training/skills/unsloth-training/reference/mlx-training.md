# MLX-Tune: Fine-tuning on Apple Silicon

**mlx-tune** (formerly unsloth-mlx) brings the Unsloth API to Apple Silicon Macs
using Apple's MLX framework. 100% API-compatible with Unsloth — write once, run
on Mac (MLX) or cloud (CUDA).

## Installation

```bash
pip install mlx-tune
# or
uv pip install mlx-tune
```

> `unsloth-mlx` is deprecated. Use `mlx-tune` and `from mlx_tune import ...`

## Requirements

- **Hardware**: Apple Silicon (M1/M2/M3/M4/M5)
- **OS**: macOS 13.0+ (15.0+ for larger models)
- **Memory**: 16GB+ unified RAM (32GB+ for 7B+ models)
- **Python**: 3.9+

## Quick Start (SFT)

```python
from mlx_tune import FastLanguageModel, SFTTrainer, SFTConfig
from datasets import load_dataset

# Load model (4-bit quantized for memory efficiency)
model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="mlx-community/Llama-3.2-1B-Instruct-4bit",
    max_seq_length=2048,
    load_in_4bit=True,
)

# Add LoRA adapters
model = FastLanguageModel.get_peft_model(
    model,
    r=16,
    target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
    lora_alpha=16,
)

# Train
dataset = load_dataset("yahma/alpaca-cleaned", split="train[:100]")
trainer = SFTTrainer(
    model=model,
    train_dataset=dataset,
    tokenizer=tokenizer,
    args=SFTConfig(
        output_dir="outputs",
        per_device_train_batch_size=2,
        learning_rate=2e-4,
        max_steps=50,
    ),
)
trainer.train()
```

## Supported Training Methods

| Method | Class | Use Case |
|--------|-------|----------|
| **SFT** | `SFTTrainer` | Instruction fine-tuning |
| **DPO** | `DPOTrainer` | Preference learning |
| **ORPO** | `ORPOTrainer` | Combined SFT + preference |
| **GRPO** | `GRPOTrainer` | Multi-generation reasoning (DeepSeek R1 style) |
| **KTO** | `KTOTrainer` | Kahneman-Tversky optimization |
| **SimPO** | `SimPOTrainer` | Simple preference optimization |
| **VLM** | `VLMSFTTrainer` | Vision-language (beta) |

## Chat Templates

```python
from mlx_tune import get_chat_template, train_on_responses_only

tokenizer = get_chat_template(tokenizer, chat_template="llama-3")

# Train only on assistant responses (not user prompts)
trainer = train_on_responses_only(
    trainer,
    instruction_part="<|start_header_id|>user<|end_header_id|>\n\n",
    response_part="<|start_header_id|>assistant<|end_header_id|>\n\n",
)
```

Supported: Llama 3, Gemma, Qwen, Phi, Mistral, and 10+ others.

## Export

```python
# LoRA adapters only (~100MB)
model.save_pretrained("lora_model")

# Fully merged model
model.save_pretrained_merged("merged", tokenizer)

# GGUF for Ollama/llama.cpp
model.save_pretrained_gguf("model", tokenizer)
```

### GGUF Limitation
Direct GGUF export from 4-bit quantized base models is not supported.
Workarounds:
1. Train quantized, export from non-quantized base
2. Dequantize during export, re-quantize with llama.cpp
3. Use `save_pretrained_merged()` for MLX-native inference

## Unsloth vs MLX-Tune

| Aspect | Unsloth | MLX-Tune |
|--------|---------|----------|
| Platform | NVIDIA GPUs (Linux/Windows) | Apple Silicon (macOS) |
| Backend | Triton kernels | MLX framework |
| Memory | VRAM (8-80GB) | Unified memory (16-512GB) |
| API | Original | 100% compatible |
| Use case | Production training | Local dev & prototyping |

## Code Portability

Write once, run anywhere:

```python
# On Mac:
from mlx_tune import FastLanguageModel

# On CUDA:
from unsloth import FastLanguageModel

# Everything else is identical
```

## Memory Guidelines

| Model Size | Min Unified RAM | Quantization |
|-----------|----------------|--------------|
| 1B | 16GB | 4-bit |
| 3B | 16GB | 4-bit |
| 7B | 32GB | 4-bit |
| 14B | 64GB | 4-bit |
| 32B | 96GB | 4-bit |
| 70B | 192GB+ | 4-bit |

Apple Silicon unified memory allows training much larger models than equivalent NVIDIA VRAM
since system RAM and GPU memory are shared.

## Links

- [GitHub: ARahim3/mlx-tune](https://github.com/ARahim3/mlx-tune)
- [PyPI: mlx-tune](https://pypi.org/project/mlx-tune/)
- [Deprecated: unsloth-mlx](https://pypi.org/project/unsloth-mlx/) → use mlx-tune
