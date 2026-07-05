#!/usr/bin/env bash
# Scaffold a new shared-brain kb folder at <target> (default: ~/kb).
# Idempotent: never overwrites a file that already exists in <target>, so it's
# safe to re-run against a kb that's already partially set up. Does NOT run
# git init, does NOT touch any file outside <target> (wiring is a separate,
# explicit step — see scripts/wire.sh in the scaffolded folder).
set -euo pipefail

TEMPLATES="$(cd -P "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)"
TARGET="${1:-$HOME/kb}" # pass an absolute path; this script does not expand ~

created=() skipped=()

put() { # put <src-relative-to-templates> <dest-relative-to-target>
	local src="$TEMPLATES/$1" dest="$TARGET/$2"
	mkdir -p "$(dirname "$dest")"
	if [[ -e "$dest" ]]; then
		skipped+=("$2")
		return
	fi
	cp "$src" "$dest"
	created+=("$2")
}

mkdir -p "$TARGET"

put "AGENTS.md" "AGENTS.md"
put "CLAUDE.md" "CLAUDE.md"
put "DREAM.md" "DREAM.md"
put "README.md" "README.md"
put "gitignore" ".gitignore"
put "memory/_TEMPLATE.md" "memory/_TEMPLATE.md"
put "raw/README.md" "raw/README.md"
put "scripts/lint.sh" "scripts/lint.sh"
put "scripts/sync.sh" "scripts/sync.sh"
put "scripts/wire.sh" "scripts/wire.sh"
put "scripts/render_okf_viewer.py" "scripts/render_okf_viewer.py"
put "bin/kb" "bin/kb"
chmod +x "$TARGET"/scripts/*.sh "$TARGET/bin/kb" 2>/dev/null || true

# Starter memory groups + inbox — empty dirs need a placeholder to survive git.
for d in memory/user memory/feedback memory/reference memory/projects memory/topics raw/inbox; do
	mkdir -p "$TARGET/$d"
	[[ -e "$TARGET/$d/.gitkeep" ]] || {
		: >"$TARGET/$d/.gitkeep"
		created+=("$d/.gitkeep")
	}
done

if [[ ! -e "$TARGET/.agent/state.json" ]]; then
	mkdir -p "$TARGET/.agent"
	printf '{}\n' >"$TARGET/.agent/state.json"
	created+=(".agent/state.json")
fi

if [[ ! -e "$TARGET/MEMORY.md" ]]; then
	cat >"$TARGET/MEMORY.md" <<'EOF'
# Memory Index

Master table of contents. One line per note — read this first, then open only
the notes relevant to your task. See `AGENTS.md` for the protocol.

(No notes yet — this index is rebuilt by hand or by a `DREAM.md` pass as notes
are added under `memory/`.)
EOF
	created+=("MEMORY.md")
fi

# Initial OKF index.md + viz.html so the bundle is immediately browsable.
python3 "$TARGET/scripts/render_okf_viewer.py" "$TARGET/memory" \
	--title "$(basename "$TARGET")" --out "$TARGET/viz.html" >/dev/null

echo "kb scaffolded at $TARGET"
echo "  created: ${#created[@]} file(s)"
[[ ${#skipped[@]} -gt 0 ]] && echo "  skipped (already existed): ${skipped[*]}"
echo
echo "next steps:"
echo "  export PATH=\"$TARGET/bin:\$PATH\"   # add to your shell rc"
echo "  cd $TARGET && git init                # optional: version control"
echo "  $TARGET/scripts/wire.sh on             # optional: wire the reflex into agents' global config (ask the user first — it edits files outside this folder)"
