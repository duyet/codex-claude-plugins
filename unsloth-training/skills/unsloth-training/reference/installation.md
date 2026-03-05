# Unsloth Installation

## Quick Install

```bash
# Standard (auto-detects CUDA)
pip install unsloth

# Using uv (faster)
pip install --upgrade pip && pip install uv
uv pip install unsloth

# With vLLM support
uv pip install unsloth vllm
```

## Virtual Environment Setup

```bash
python -m venv unsloth_env
source unsloth_env/bin/activate
pip install --upgrade pip && pip install uv
uv pip install unsloth
```

## Latest Dev Version

```bash
pip install unsloth
pip uninstall unsloth unsloth_zoo -y
pip install --no-deps git+https://github.com/unslothai/unsloth_zoo.git
pip install --no-deps git+https://github.com/unslothai/unsloth.git
```

## Force Reinstall (troubleshooting)

```bash
pip install --upgrade --force-reinstall --no-cache-dir --no-deps unsloth
pip install --upgrade --force-reinstall --no-cache-dir --no-deps unsloth_zoo
```

## Advanced: Specific Torch + CUDA

Supported: torch 2.1.1–2.9.2, CUDA 11.8/12.1/12.4/12.6/12.8/13.0.
Optional `-ampere` suffix for A100/H100/RTX3090+.

```bash
# Example: torch 2.4, CUDA 12.1
pip install "unsloth[cu121-torch240] @ git+https://github.com/unslothai/unsloth.git"

# Auto-detect optimal command
wget -qO- https://raw.githubusercontent.com/unslothai/unsloth/main/unsloth/_auto_install.py | python -
```

## Supported
- Python 3.10–3.13
- NVIDIA GPUs with CUDA
- Colab/Jupyter (prefix with `!`)

## Colab

```python
!pip install --upgrade --force-reinstall --no-cache-dir unsloth unsloth_zoo
```
