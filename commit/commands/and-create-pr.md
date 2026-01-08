---
allowed-tools: Bash(git *), Bash(gh *)
description: Create a git commit with semantic commit message format and create a pull request
---

# Commit and Create PR

## Context

- Current Git status: !`git status`
- Current Git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Default branch: !`git remote show origin | grep 'HEAD branch' | cut -d' ' -f5`
- Recent commits: !`git log --oneline -5`

## Your task

Create a semantic commit and open a pull request for the changes.

## Execution Flow

### Step 1: Analyze Changes

Look at the diff and determine:
- **Commit type**: feat, fix, docs, style, refactor, test, chore
- **Scope**: The area of code affected (e.g., auth, api, ui)
- **Description**: Brief summary of changes

### Step 2: Handle Branch

**Check current branch against default branch (main/master):**

If current branch IS main/master:
1. Create a new branch based on the commit type and scope:
   ```bash
   git checkout -b [type]/[short-description]
   ```
   Examples:
   - `feat/add-user-auth`
   - `fix/login-validation`
   - `refactor/api-endpoints`

If current branch is NOT main/master:
- Stay on current branch

### Step 3: Stage and Commit

```bash
git add .
git commit -m "type(scope): description

Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>"
```

### Step 4: Push Branch

```bash
git push -u origin [branch-name]
```

### Step 5: Create Pull Request

```bash
gh pr create --title "[commit message]" --body "$(cat <<'EOF'
## Summary
[1-2 sentence description of what this PR does]

## Changes
[Bullet list of key changes]

---
Generated with Claude Code
EOF
)"
```

## Branch Naming Convention

| Type | Branch Prefix | Example |
|------|---------------|---------|
| feat | `feat/` | `feat/add-dark-mode` |
| fix | `fix/` | `fix/null-pointer` |
| refactor | `refactor/` | `refactor/auth-module` |
| docs | `docs/` | `docs/api-readme` |
| chore | `chore/` | `chore/update-deps` |

## Important Rules

1. **Never commit directly to main/master** - always create a feature branch first
2. **Branch names**: Use kebab-case, keep short but descriptive
3. **Commit format**: `type(scope): description` (imperative mood)
4. **PR title**: Should match or closely follow the commit message

## Example Session

If on `main` with changes to add user authentication:

```bash
# Create feature branch
git checkout -b feat/user-authentication

# Stage and commit
git add .
git commit -m "feat(auth): add user authentication flow

Co-Authored-By: duyetbot <duyetbot@users.noreply.github.com>"

# Push new branch
git push -u origin feat/user-authentication

# Create PR
gh pr create --title "feat(auth): add user authentication flow" --body "..."
```

Output the PR URL when complete.
