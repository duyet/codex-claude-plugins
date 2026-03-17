#!/usr/bin/env bash
# Validate all plugin.json manifests in the repository.
# Exits 1 if any plugin fails validation.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAILED=0
CHECKED=0

validate_plugin() {
  local manifest="$1"
  local plugin_dir
  plugin_dir="$(dirname "$(dirname "$manifest")")"
  local plugin_name
  plugin_name="$(basename "$plugin_dir")"

  # 1. Valid JSON
  if ! python3 -c "import json, sys; json.load(open('$manifest'))" 2>/dev/null; then
    echo "❌ $plugin_name: invalid JSON"
    return 1
  fi

  local errors=()

  # 2. Run all checks via Python
  python3 - "$manifest" "$plugin_dir" <<'PYEOF'
import json, sys, os, re

manifest_path = sys.argv[1]
plugin_dir = sys.argv[2]
errors = []

with open(manifest_path) as f:
    data = json.load(f)

# Required string fields
for field in ("name", "version", "description"):
    if field not in data:
        errors.append(f"missing required field: '{field}'")
    elif not isinstance(data[field], str) or not data[field].strip():
        errors.append(f"'{field}' must be a non-empty string")

# Semver: version must match X.Y.Z
if "version" in data and isinstance(data["version"], str):
    if not re.fullmatch(r"\d+\.\d+\.\d+", data["version"]):
        errors.append(f"'version' must be semver (X.Y.Z), got: {data['version']!r}")

# Author must be object with a 'name' key
author = data.get("author")
if author is None:
    errors.append("missing required field: 'author'")
elif isinstance(author, str):
    errors.append(f"'author' must be an object with a 'name' key, got string: {author!r}")
elif not isinstance(author, dict):
    errors.append(f"'author' must be an object, got: {type(author).__name__}")
elif "name" not in author or not isinstance(author["name"], str) or not author["name"].strip():
    errors.append("'author.name' must be a non-empty string")

# Skills array validation (optional field)
skills = data.get("skills")
if skills is not None:
    if not isinstance(skills, list):
        errors.append("'skills' must be an array")
    else:
        for i, skill in enumerate(skills):
            if not isinstance(skill, dict):
                errors.append(f"skills[{i}]: must be an object")
                continue
            if "name" not in skill or not isinstance(skill["name"], str) or not skill["name"].strip():
                errors.append(f"skills[{i}]: missing 'name'")
            if "description" not in skill or not isinstance(skill["description"], str) or not skill["description"].strip():
                errors.append(f"skills[{i}]: missing 'description'")
            if "path" in skill:
                skill_path = os.path.join(plugin_dir, skill["path"])
                if not os.path.isfile(skill_path):
                    errors.append(f"skills[{i}]: path '{skill['path']}' does not exist")

if errors:
    for e in errors:
        print(f"  - {e}", file=sys.stderr)
    sys.exit(1)
PYEOF
}

echo "Validating plugin manifests..."
echo ""

while IFS= read -r -d '' manifest; do
  plugin_dir="$(dirname "$(dirname "$manifest")")"
  plugin_name="$(basename "$plugin_dir")"
  CHECKED=$((CHECKED + 1))

  if validate_plugin "$manifest" 2>/tmp/plugin-validate-err; then
    echo "✅ $plugin_name"
  else
    echo "❌ $plugin_name"
    while IFS= read -r line; do
      echo "     $line"
    done < /tmp/plugin-validate-err
    FAILED=$((FAILED + 1))
  fi
done < <(find "$REPO_ROOT" -path "*/.claude-plugin/plugin.json" -not -path "*/node_modules/*" -print0 | sort -z)

echo ""
echo "Checked $CHECKED plugin(s). $FAILED failed."

if [[ $FAILED -gt 0 ]]; then
  exit 1
fi
