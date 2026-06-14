#!/usr/bin/env bash
# Install plugins to Antigravity CLI.
# Usage: ./scripts/install-antigravity.sh [plugin-name | all]

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="$HOME/.gemini/config/plugins"

# Find plugins with Antigravity manifests
find_antigravity_plugins() {
  find "$REPO_ROOT" -maxdepth 3 -path "*/.antigravity-plugin/plugin.json" -not -path "*/node_modules/*" | while read -r manifest; do
    basename "$(dirname "$(dirname "$manifest")")"
  done
}

PLUGINS=($(find_antigravity_plugins))

if [ ${#PLUGINS[@]} -eq 0 ]; then
  echo "No plugins with .antigravity-plugin/plugin.json found in the repository."
  exit 0
fi

# Check argument
if [ $# -eq 0 ]; then
  echo "Available Antigravity plugins:"
  for p in "${PLUGINS[@]}"; do
    echo "  - $p"
  done
  echo ""
  echo "Run: $0 <plugin-name>  (or '$0 all' to install all)"
  exit 0
fi

install_plugin() {
  local name="$1"
  local dir="$REPO_ROOT/$name"
  local manifest="$dir/.antigravity-plugin/plugin.json"

  if [ ! -f "$manifest" ]; then
    echo "❌ Plugin '$name' does not have an Antigravity manifest (.antigravity-plugin/plugin.json)."
    return 1
  fi

  local dest="$TARGET_DIR/$name"
  echo "Installing '$name' to '$dest'..."
  mkdir -p "$dest"

  # Symlink manifest
  ln -sfn "$manifest" "$dest/plugin.json"
  echo "  - Linked plugin.json"

  # Read manifest using Python to parse JSON and output relative paths
  local fields
  fields=$(python3 - "$manifest" <<'PYEOF'
import json, sys
data = json.load(open(sys.argv[1]))
for key in ["skills", "commands", "hooks", "mcpServers", "apps", "agents"]:
    if key in data and isinstance(data[key], str) and data[key].startswith("./"):
        print(f"{key}:{data[key]}")
PYEOF
)

  for f in $fields; do
    local key="${f%%:*}"
    local rel_path="${f#*:}"
    # Normalize relative path
    local src_dir
    src_dir=$(cd "$dir" && cd "$rel_path" && pwd)
    ln -sfn "$src_dir" "$dest/$key"
    echo "  - Linked $key -> $rel_path"
  done

  echo "✅ Successfully installed '$name' to Antigravity!"
  echo "Restart your Antigravity session/CLI to load the plugin."
}

if [ "$1" = "all" ]; then
  for p in "${PLUGINS[@]}"; do
    install_plugin "$p"
  done
else
  install_plugin "$1"
fi
