---
name: unsloth-training
description: Use when fine-tuning an LLM with Unsloth, covering GRPO or SFT training, reward functions, datasets, FP8, vision models, MLX on Apple Silicon, GGUF export, and mobile deployment.
---

# Unsloth training

Pick the method, then read the matching reference. Model names below are examples. Check Unsloth's current model list before choosing one.

## GRPO or SFT

| Situation | Method | Data needed |
|-----------|--------|-------------|
| You can verify correctness or score outputs | GRPO | Prompts plus a reward function or ground-truth answers |
| Improving reasoning quality | GRPO | Prompts plus verifiable answers |
| Teaching an output format, new instructions, or domain knowledge | SFT | Input/output or conversation examples |
| Image inputs | Vision SFT or GRPO | See `reference/vision-training.md` |

## Where to look

| Need | Read |
|------|------|
| GRPO script to start from | `reference/grpo/basic_grpo.py` |
| Reward patterns (correctness, format, quality, constraints) | `reference/reward-design.md`, `reference/grpo/reward_functions.py` |
| GRPO and SFT hyperparameters | `reference/hyperparameters.md`, `reference/grpo/hyperparameters.py` |
| Dataset formats, chat templates, synthetic data | `reference/datasets-guide.md` |
| Install, CUDA versions, Colab | `reference/installation.md` |
| Environment flags | `reference/environment-flags.md` |
| FP8 training | `reference/fp8-training.md` |
| Long context, packing, checkpoints | `reference/advanced-training.md` |
| Vision-language models | `reference/vision-training.md` |
| Apple Silicon | `reference/mlx-training.md` |
| Export to GGUF, Ollama, vLLM, LM Studio | `reference/export-formats.md` |
| Docker, vLLM serving, LoRA hot-swap, SGLang | `reference/deployment.md` |
| Phones (QAT, ExecuTorch) | `reference/mobile-deployment.md` |
| Failures and odd behavior | `reference/troubleshooting.md` |

## Defaults to start from

| Setting | GRPO | SFT |
|---------|------|-----|
| Learning rate | 5e-6 (about 10x lower than SFT) | 2e-4 |
| Length of run | 300+ steps before judging | 2 to 4 epochs |
| `num_generations` | 4 (range 2 to 8) | n/a |
| `beta` (KL penalty) | 0.04 (range 0.01 to 0.1) | n/a |
| Gradient checkpointing | `"unsloth"` | `"unsloth"` |
| Packing | n/a | `packing=True` for mixed-length data |

## Choosing a model size

| Goal | Start with |
|------|-----------|
| Prototype or learn the workflow | Around 1B to 3B, 4-bit |
| Production quality | 7B or larger, if VRAM allows |
| Phone deployment | Sub-1B, quantization-aware training |
| Less VRAM on supported GPUs | FP8 (`load_in_fp8=True`), see `reference/fp8-training.md` |

## Reward design rules

- Make correctness the highest-weighted reward. Add smaller rewards for format and length, and negative rewards for unwanted behavior.
- Rewards take `completions` and extra dataset columns as kwargs and return one float per completion.
- Test each reward function on hand-written good and bad completions before training.

## GRPO symptoms

| Symptom | Fix |
|---------|-----|
| Reward flat | Wait 300+ steps, then raise the learning rate 2x |
| Reward spiky | Halve the learning rate, raise `beta` |
| Garbage output | Raise `beta` 2 to 4x, check the prompt format |
| Out of memory | Lower `max_completion_length`, set `num_generations=2` |
| No reasoning appears | Train 500+ steps, use a model of 1.5B or more |

## Before training

- The model loads without OOM.
- The dataset has the fields the trainer expects (`prompt` and `answer` for GRPO, conversations or text for SFT).
- The chat template is applied correctly.
- For GRPO, at least one reward function is defined and tested.

A run succeeded when the reward (GRPO) or loss (SFT) trends the right way, outputs match the expected format, and the exported model gives sensible test outputs.
