# Unsloth Training Plugin

Fine-tune LLMs with [Unsloth](https://unsloth.ai/) using GRPO (reinforcement learning) or SFT (supervised fine-tuning).

## Install

```bash
/plugin install unsloth-training@duyet-claude-plugins
```

Or via [skills.sh](https://skills.sh):
```bash
npx skills add duyet/codex-claude-plugins/unsloth-training
```

## Features

- **GRPO** — RL with reward functions (no labeled outputs needed)
- **SFT** — Supervised fine-tuning with input/output pairs
- **Vision** — VLM fine-tuning (Qwen3-VL, Gemma3, Llama 3.2 Vision)
- **FP8 Training** — 60% less VRAM, 1.4x faster (RTX 40+, H100)
- **Packing** — 2-5x speedup for mixed-length data
- **MLX** — Apple Silicon training via mlx-tune
- **Export** — GGUF, Ollama, vLLM, LM Studio, SGLang
- **Dataset Prep** — ChatML/ShareGPT/Alpaca formats, synthetic data generation
- **Mobile** — QAT + ExecuTorch for iOS/Android deployment

## Skills

| Skill | Description |
|-------|-------------|
| `unsloth-training` | Core training guide with GRPO, SFT, reward design, model selection, export |

## Reference Docs

| Reference | Description |
|-----------|-------------|
| `installation.md` | pip/uv install, CUDA versions, venv, Colab |
| `datasets-guide.md` | Dataset formats, chat templates, synthetic data |
| `environment-flags.md` | Unsloth env flags (RETURN_LOGITS, COMPILE_DISABLE, etc.) |
| `mlx-training.md` | Apple Silicon training with mlx-tune |
| `fp8-training.md` | FP8 setup, VRAM savings |
| `reward-design.md` | Reward function patterns for GRPO |
| `domain-examples.md` | Voice AI, Sales Agent, Support examples |
| `hyperparameters.md` | GRPOConfig/SFTConfig reference |
| `export-formats.md` | GGUF, Ollama, vLLM, Dynamic 2.0 |
| `advanced-training.md` | 500K context, packing, checkpoints |
| `vision-training.md` | VLM fine-tuning |
| `mobile-deployment.md` | QAT, ExecuTorch, iOS/Android |
| `deployment.md` | Docker, vLLM, LoRA hot-swap, SGLang |
| `troubleshooting.md` | Common fixes |

## Usage Examples

```
# Natural language triggers
"fine-tune Qwen3.5 for classification"
"train with GRPO and reward functions"
"prepare dataset in ChatML format"
"install unsloth on Colab"
"train on Apple Silicon with MLX"
"export model to GGUF for Ollama"
```

## Quick Start

### SFT
```python
from unsloth import FastLanguageModel
from trl import SFTTrainer, SFTConfig

model, tokenizer = FastLanguageModel.from_pretrained(
    model_name="unsloth/Qwen3.5-4B",
    max_seq_length=512,
    load_in_4bit=False,
    load_in_16bit=True,
)
model = FastLanguageModel.get_peft_model(model, r=16)

trainer = SFTTrainer(
    model=model,
    train_dataset=dataset,
    processing_class=tokenizer,
    args=SFTConfig(
        per_device_train_batch_size=2,
        num_train_epochs=3,
        learning_rate=2e-4,
        packing=True,
    ),
)
trainer.train()
model.save_pretrained_gguf("model", tokenizer, quantization_method="q4_k_m")
```

### GRPO
```python
from trl import GRPOConfig, GRPOTrainer

def correctness_reward(completions, answer, **kwargs):
    return [2.0 if extract_answer(c) == a else 0.0
            for c, a in zip(completions, answer)]

trainer = GRPOTrainer(
    model=model,
    args=GRPOConfig(num_generations=4, beta=0.04, learning_rate=5e-6),
    train_dataset=dataset,
    reward_funcs=[correctness_reward],
)
trainer.train()
```

## License

Apache-2.0
