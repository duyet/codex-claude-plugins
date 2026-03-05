# Dataset Preparation Guide

## Dataset Formats

| Format | Use Case | Structure |
|--------|----------|-----------|
| **Raw Corpus** | Continued pretraining | Plain text |
| **Instruct (Alpaca)** | Single-turn tasks | instruction/input/output |
| **Conversation (ShareGPT)** | Multi-turn chat | conversations array |
| **ChatML** | OpenAI-style chat | messages array |

### Alpaca Format
```json
{
  "instruction": "Task description",
  "input": "User query (optional)",
  "output": "Expected response"
}
```

### ShareGPT Format
```json
{
  "conversations": [
    {"from": "human", "value": "Can you help me?"},
    {"from": "gpt", "value": "Of course!"}
  ]
}
```

### ChatML Format (recommended for Qwen/most models)
```json
{
  "messages": [
    {"role": "system", "content": "You are helpful."},
    {"role": "user", "content": "What is 1+1?"},
    {"role": "assistant", "content": "It's 2!"}
  ]
}
```

## Minimum Dataset Size

- **100 rows** — minimum for reasonable results
- **1,000+ rows** — recommended for good quality
- Quality > quantity — clean, consistent data matters more

## Applying Chat Templates

```python
from unsloth.chat_templates import get_chat_template, CHAT_TEMPLATES

# Check available templates
print(list(CHAT_TEMPLATES.keys()))

# Apply template to tokenizer
tokenizer = get_chat_template(tokenizer, chat_template="qwen-25")

# Format function for training
def formatting_prompts_func(examples):
    convos = examples["conversations"]
    texts = [
        tokenizer.apply_chat_template(
            convo, tokenize=False, add_generation_prompt=False
        )
        for convo in convos
    ]
    return {"text": texts}

# Apply to dataset
dataset = dataset.map(formatting_prompts_func, batched=True)
```

## Converting ShareGPT to ChatML

```python
from unsloth.chat_templates import standardize_sharegpt

dataset = load_dataset("mlabonne/FineTome-100k", split="train")
dataset = standardize_sharegpt(dataset)
dataset = dataset.map(formatting_prompts_func, batched=True)
```

## Standardize Train Dataset (shortcut)

```python
from unsloth.chat_templates import standardize_train_dataset

# Auto-detects format and applies chat template
dataset = standardize_train_dataset(dataset, tokenizer)
```

## Multi-Column Datasets

For tabular data with multiple columns, use `to_sharegpt`:

```python
from unsloth.chat_templates import to_sharegpt

# Curly braces {} for columns, [[]] for optional fields
dataset = to_sharegpt(
    dataset,
    merged_prompt="The passenger embarked from {Embarked}. [[Their age is {Age}.]]",
    output_column_name="Survived",
)
```

- `{column}` — required column reference
- `[[text {column}]]` — optional (skipped if value missing)

## Extending to Multi-Turn

Single-turn datasets can be extended to multi-turn:

```python
dataset = to_sharegpt(
    dataset,
    conversation_extension=3,  # Merge 3 random rows into one conversation
)
```

## Synthetic Data Generation

### Using LLM APIs

Prompt strategies:
- **Extend existing**: "Using this dataset example, follow the structure and generate similar conversations."
- **From scratch**: "Create 10 examples of [domain] classified as [categories]."
- **Reformat**: "Structure my dataset in QA ChatML format. Then generate 5 synthetic examples."

### Using Unsloth + Meta Synthetic Data Kit

- Auto-parses PDFs, websites, YouTube videos
- Uses Llama 3.2 (3B) to generate QA pairs
- Automatic cleaning and filtering

### Quality Tips

1. Review generated data manually (sample 10%)
2. Remove duplicates and near-duplicates
3. Ensure consistent formatting across all examples
4. Balance classes if doing classification
5. Include edge cases and adversarial examples

## Vision Datasets

```python
messages = [
    {"role": "user", "content": [
        {"type": "text", "text": "What's in this image?"},
        {"type": "image", "image": image_object},
    ]},
    {"role": "assistant", "content": [
        {"type": "text", "text": "A cat sitting on a desk."},
    ]},
]
```

## Reasoning Datasets

For models with reasoning (DeepSeek-R1):
- Include chain-of-thought in answers

For models without reasoning:
- Use standard SFT datasets
- Apply GRPO with reward functions for reasoning development
