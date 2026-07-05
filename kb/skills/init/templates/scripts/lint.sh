#!/usr/bin/env bash
# Lint memory notes against the standard (AGENTS.md §2).
# Checks: required frontmatter fields, name == filename, no nested metadata:,
# and that every [[wikilink]] resolves to a real note. Exits non-zero on failure.
# Files prefixed with "_" (e.g. _TEMPLATE.md) are skipped.
set -euo pipefail

REPO="${KB_DIR:-$HOME/kb}"
cd "$REPO"
# `timestamp` (ISO 8601) is required by our lint — stricter than the OKF spec
# (which only mandates `type`), matching Google's reference validator, which
# rejects a concept missing type/title/description/timestamp.
REQUIRED=(name description type tags created updated timestamp)
fail=0

# Recursive discovery: notes live under memory/<group>/[…]/<slug>.md.
# Skip the OKF reserved filenames (index.md, log.md) and the _TEMPLATE.
notes=()
while IFS= read -r f; do
	b="$(basename "$f")"
	[[ "$b" == _* ]] && continue
	[[ "$b" == "index.md" || "$b" == "log.md" ]] && continue
	notes+=("$f")
done < <(find memory -type f -name '*.md' | sort)

if [[ ${#notes[@]} -eq 0 ]]; then
	echo "✓ 0 notes yet — nothing to lint"
	exit 0
fi

# Build the set of valid note slugs (for link resolution).
slugs=" "
for f in "${notes[@]}"; do slugs+="$(basename "$f" .md) "; done

for f in "${notes[@]}"; do
	stem="$(basename "$f" .md)"
	fm="$(awk 'NR==1&&$0=="---"{f=1;next} f&&$0=="---"{exit} f{print}' "$f")"

	for key in "${REQUIRED[@]}"; do
		grep -qE "^${key}:" <<<"$fm" || {
			echo "✗ $f: missing '$key:'"
			fail=1
		}
	done

	name="$(grep -E '^name:' <<<"$fm" | head -1 | sed 's/^name:[[:space:]]*//;s/[[:space:]]*$//')"
	[[ "$name" == "$stem" ]] || {
		echo "✗ $f: name ('$name') != filename ('$stem')"
		fail=1
	}

	grep -qE '^metadata:' <<<"$fm" && {
		echo "✗ $f: nested 'metadata:' block — use top-level fields"
		fail=1
	}

	type="$(grep -E '^type:' <<<"$fm" | head -1 | sed 's/^type:[[:space:]]*//;s/[[:space:]]*$//')"
	case "$type" in user | feedback | project | reference | tech) ;; *)
		echo "✗ $f: invalid type '$type'"
		fail=1
		;;
	esac
done

# Broken-link check across all notes.
while read -r target; do
	[[ -z "$target" ]] && continue
	[[ "$slugs" == *" $target "* ]] || echo "✗ broken link: [[$target]] has no note (stub — create it or fix)"
done < <(grep -rho '\[\[[^]]*\]\]' "${notes[@]}" 2>/dev/null | sed 's/\[\[//;s/\]\]//' | sort -u)

# Security leak check — only meaningful if this repo is public (AGENTS.md §3).
while IFS= read -r line; do
	[[ -z "$line" ]] && continue
	echo "✗ possible secret/host leak: $line"
	fail=1
done < <(grep -rhE \
	'(sk-[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{36}|AKIA[0-9A-Z]{16}|-----BEGIN (RSA |EC )?PRIVATE KEY-----|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|ssh://|@.*\.internal\.|\.onion|password\s*[:=]|secret\s*[:=]|token\s*[:=])' \
	"${notes[@]}" 2>/dev/null | grep -v '^---' | grep -v '^sources:')

if [[ $fail -eq 0 ]]; then echo "✓ ${#notes[@]} notes pass the standard"; else
	echo "lint failed"
	exit 1
fi
