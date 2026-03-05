# Unsloth Environment Flags

Set before importing unsloth:

```python
import os
os.environ["FLAG_NAME"] = "1"

from unsloth import FastLanguageModel  # Must come after
```

## Flags

| Flag | Purpose | Default |
|------|---------|---------|
| `UNSLOTH_RETURN_LOGITS` | Force return logits — needed for evaluation | Off |
| `UNSLOTH_COMPILE_DISABLE` | Disable auto compiler — debug incorrect results | Off |
| `UNSLOTH_DISABLE_FAST_GENERATION` | Disable fast generation for generic models | Off |
| `UNSLOTH_ENABLE_LOGGING` | Show which functions are compiled | Off |
| `UNSLOTH_FORCE_FLOAT32` | Use float32 on float16 machines (useful for Gemma 3) | Off |
| `UNSLOTH_STUDIO_DISABLED` | Disable extra features | Off |
| `UNSLOTH_COMPILE_DEBUG` | Verbose torch.compile logs | Off |
| `UNSLOTH_COMPILE_MAXIMUM` | Maximum torch.compile optimizations (not recommended) | `"0"` |
| `UNSLOTH_COMPILE_IGNORE_ERRORS` | Turn off to enable fullgraph parsing | `"1"` |
| `UNSLOTH_FULLGRAPH` | Enable torch.compile fullgraph mode | `"0"` |
| `UNSLOTH_DISABLE_AUTO_UPDATES` | Prevent auto-updates to unsloth-zoo | Off |
| `UNSLOTH_VLLM_STANDBY` | Shared memory for GRPO vLLM inference | Off |

## Common Usage

```python
# For GRPO with vLLM
os.environ["UNSLOTH_VLLM_STANDBY"] = "1"

# For evaluation / logit extraction
os.environ["UNSLOTH_RETURN_LOGITS"] = "1"

# Debug training issues
os.environ["UNSLOTH_COMPILE_DISABLE"] = "1"
os.environ["UNSLOTH_ENABLE_LOGGING"] = "1"

# Gemma 3 on float16 hardware
os.environ["UNSLOTH_FORCE_FLOAT32"] = "1"
```
