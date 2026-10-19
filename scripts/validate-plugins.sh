#!/usr/bin/env bash
# Fail when generated manifests drift from marketplace.json or a plugin is broken.
set -euo pipefail
exec python3 "$(dirname "${BASH_SOURCE[0]}")/plugins.py" check
