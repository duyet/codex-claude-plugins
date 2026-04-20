---
allowed-tools: [Read, Bash, Glob, Grep, TodoWrite, Edit, Write, Task]
description: "Fix issues/tests and create a new pull request"
---

# /fix:and-create-pr - Fix and Create PR

## Purpose

Fix any failing tests or issues on the current branch, commit the fixes, and create a new pull request.

## Usage

```
/fix:and-create-pr
```

```
/fix:and-create-pr

<optional: PR title or description>
<optional: target base branch>
```

## Context Gathering

```bash
# Current branch
git branch --show-current

# Default branch (usually main or master)
git remote show origin | grep 'HEAD branch' | cut -d' ' -f5

# Uncommitted changes
git status --short

# Commits ahead of base
git log origin/$(git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)..HEAD --oneline 2>/dev/null || echo "Branch not pushed yet"
```

## Execution Flow

### Phase 1: Pre-flight Checks
1. Verify current branch is not main/master
2. Check for uncommitted changes
3. Identify base branch for PR
4. Ensure branch is pushed to remote

### Phase 2: Issue Detection & Fix
1. Run project tests and checks:
   - Python: `pytest`, `ruff`, `mypy`
   - Node: `npm test`, `npm run lint`, `npm run type-check`
   - Rust: `cargo test`, `cargo clippy`
   - Go: `go test ./...`, `golint`

2. For each failure:
   - Analyze error message
   - Implement fix
   - Verify fix locally

3. **Parallel execution for complex issues:**
   ```
   Main Agent (Coordinator)
   ├── Senior Agent 1: Test fixes
   ├── Senior Agent 2: Lint/type fixes
   └── Main Agent: Commit & PR creation
   ```

### Phase 3: Commit Fixes
If fixes were applied:
```bash
git add .
git commit -m "fix: resolve test failures and linting issues

Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>"
```

### Phase 4: Push & Create PR
1. Push branch to remote:
   ```bash
   git push -u origin [BRANCH_NAME]
   ```

2. Create PR with generated summary:
   ```bash
   gh pr create --title "[TITLE]" --body "$(cat <<'EOF'
   ## Summary
   [Auto-generated bullet points based on commits]

   ## Changes
   [List of files modified with brief descriptions]

   ## Test Plan
   - [ ] All tests passing locally
   - [ ] CI checks expected to pass
   - [ ] Ready for review

   ---
   Generated with Claude Code
   EOF
   )"
   ```

## PR Title Generation

Based on commits and changes:
- `feat(scope):` for new features
- `fix(scope):` for bug fixes
- `refactor(scope):` for code improvements
- `docs(scope):` for documentation

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Pre-flight Checks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Branch: feature/add-auth
✅ Base: main
✅ Commits ahead: 3
⚠️  Uncommitted changes: 2 files

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Running Tests & Checks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
❌ pytest: 2 failures
✅ ruff: passed
✅ mypy: passed

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Fixing Issues
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Fixed test_auth_login assertion
✅ Fixed test_auth_logout mock

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Creating Pull Request
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Changes committed
✅ Pushed to origin/feature/add-auth
✅ PR created: #456

PR #456: feat(auth): add user authentication
URL: https://github.com/user/repo/pull/456
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Options

- **Base branch**: Defaults to main/master, can be overridden
- **Draft PR**: Add `--draft` in arguments for draft PR
- **Reviewers**: Add `--reviewer @user` to request review

## Safety Checks

- ❌ Will NOT create PR from main/master branch
- ❌ Will NOT create PR if tests still failing after fixes
- ❌ Will NOT force push
- ✅ Will commit fixes before PR creation
- ✅ Will push branch if not already pushed

## Notes

- Requires GitHub CLI (`gh`) authenticated
- PR body includes auto-generated summary from commits
- Will prompt for confirmation before creating PR
- Respects repository PR templates if present
