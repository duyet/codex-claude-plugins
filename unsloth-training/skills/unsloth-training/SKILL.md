---
name: unsloth-training
description: Use when fine-tuning an LLM with Unsloth, covering GRPO or SFT, reward functions, datasets, FP8, vision, MLX, GGUF export, and deployment.
---

# Unsloth training

Docs and current notebooks: <https://docs.unsloth.ai>. Check its model list before picking a model.

- GRPO when you can verify or score outputs. SFT to teach format, instructions, or domain knowledge.
- GRPO learning rate is about 10x lower than SFT (start 5e-6 vs 2e-4). Judge GRPO only after 300+ steps.
- Make correctness the top-weighted reward, with smaller rewards for format and length. Test each reward function on hand-written good and bad completions before training.
- Flat reward: wait, then raise the learning rate. Spiky or garbage output: lower the learning rate, raise `beta`. OOM: lower `max_completion_length` or `num_generations`.
- A run succeeded when the reward or loss trends correctly and the exported model gives sensible test outputs.
