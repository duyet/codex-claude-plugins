---
allowed-tools: Bash(git *), Bash(gh *)
description: Create a git commit with semantic commit message format and create a pull request
---

# Commit and Create PR

Create a semantic commit and open a pull request for the changes.

## Options

- `--template <name>`: Use a PR template (default, bugfix, feature)
- `--draft`: Create PR as draft
- `--title <title>`: Custom PR title (overrides commit message)
- `--body <body>`: Custom PR body (overrides template)

## Context

- Current Git status: `git status`
- Current Git diff (staged and unstaged changes): `git diff HEAD --`
- Current branch: `git branch --show-current`
- Default branch: `git remote show origin | grep 'HEAD branch' | cut -d' ' -f5'
- Recent commits: `git log --oneline -5`

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

Co-Authored-By: duyetbot <bot@duyet.net>"
```

### Step 4: Push Branch

```bash
git push -u origin [branch-name]
```

### Step 5: Create Pull Request

**Select template based on commit type:**

| Commit Type | Template | Use When |
|-------------|----------|----------|
| fix | bugfix.md | Bug fixes |
| feat | feature.md | New features |
| Other | default.md | General changes |

**Load template and populate:**

```bash
# Template constants
TEMPLATE_DIR=".pr-templates"
TPL_DEFAULT="default"
TPL_BUGFIX="bugfix"
TPL_FEATURE="feature"

# Determine template from commit type
COMMIT_TYPE="${COMMIT_MSG%%:*}"  # Extract first word before colon
case "$COMMIT_TYPE" in
  fix) TEMPLATE="${TEMPLATE_DIR}/${TPL_BUGFIX}.md" ;;
  feat) TEMPLATE="${TEMPLATE_DIR}/${TPL_FEATURE}.md" ;;
  *) TEMPLATE="${TEMPLATE_DIR}/${TPL_DEFAULT}.md" ;;
esac

# Load template directly (handle missing file gracefully)
if PR_BODY=$(cat "$TEMPLATE" 2>/dev/null); then
  # Replace placeholders with actual values
  PR_BODY="${PR_BODY//\{\{ brief description of what this PR does \}\}/Brief description based on commit}"
else
  # Fallback to simple body with proper newlines
  PR_BODY=$'## Summary\n'"${COMMIT_MSG#*:}"$'\n\n## Changes\n- Key changes here'
fi

# Create PR (draft if --draft flag)
if [ "$DRAFT" = "true" ]; then
  gh pr create --title "$COMMIT_MSG" --body "$PR_BODY" --draft
else
  gh pr create --title "$COMMIT_MSG" --body "$PR_BODY"
fi
```

**With explicit template selection:**
```bash
# Use specific template
gh pr create --title "Fix: authentication bug" --body "$(cat .pr-templates/bugfix.md)"

# Create as draft
gh pr create --title "WIP: new feature" --body "..." --draft
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

Co-Authored-By: duyetbot <bot@duyet.net>"

# Push new branch
git push -u origin feat/user-authentication

# Create PR
gh pr create --title "feat(auth): add user authentication flow" --body "..."
```

Output the PR URL when complete.
