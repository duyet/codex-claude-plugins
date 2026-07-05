#!/usr/bin/env bash
# Sync this kb with its git remote, if it has one.
# Pulls remote changes (rebase, autostash), commits any local edits, pushes.
# Safe to run repeatedly (cron, git hook, or by hand). Never loses local work.
# No-op (with a message) if this repo has no remote configured.
set -euo pipefail

REPO="${KB_DIR:-$HOME/kb}"
cd "$REPO"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "not a git repo — run 'git init' first, or skip sync"; exit 0
fi
if [ -z "$(git remote)" ]; then
  echo "no git remote configured — run 'git remote add origin <url>' to enable sync"; exit 0
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD)"

# Pull first so we rebase local work on top of any remote changes. Deliberately
# not `|| true`: a failed rebase (e.g. a conflict) must stop the script here —
# continuing to commit/push would stage raw conflict markers.
git pull --rebase --autostash origin "$BRANCH"

# Commit local changes, if any.
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -q -m "memory: auto-sync $(date '+%Y-%m-%d %H:%M')"
fi

# Push (sets upstream on first run).
git push -u origin "$BRANCH"
