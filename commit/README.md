# Commit plugin

Semantic commits, optionally pushed or opened as a PR.

## Install

```text
/plugin install commit@duyet-claude-plugins
```

## What ships

- `/commit:commit` - commit changes with a `type(scope): description` message
- `/commit:and-push` - commit and push
- `/commit:and-create-pr` - commit, push, and open a PR using `.pr-templates/` (feat, fix, default)
- `commit-workflow` skill - the shared rules for all three
