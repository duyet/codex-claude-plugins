# GitHub Workflows

This directory contains GitHub Actions workflows for automating maintenance tasks.

## Sync Rules from ClickHouse/agent-skills

**File:** `sync-rules.yml`

### Purpose
Automatically syncs the 28 ClickHouse best practice rule files from the official [ClickHouse/agent-skills](https://github.com/ClickHouse/agent-skills) repository.

### Triggers
- **Manual:** Can be triggered manually from the Actions tab
- **Scheduled:** Runs weekly on Sunday at midnight UTC

### What It Does
1. Clones the latest ClickHouse/agent-skills repository
2. Copies rule files to `skills/clickhouse/rules/`
3. Automatically increments the version number
4. Creates a pull request with changes

### Permissions Required
- `contents: write` — To commit changes
- `pull-requests: write` — To create PRs

### Manual Trigger
To trigger manually:
1. Go to Actions tab in GitHub
2. Select "Sync Rules from ClickHouse/agent-skills"
3. Click "Run workflow"

### Review Process
When a sync PR is created:
1. Review the rule file changes
2. Ensure compatibility with our extended `references/` directory
3. Test the skill locally if needed
4. Merge if everything looks correct

### Custom Content Preservation
Our custom `references/` directory (15+ files) is never modified by the sync workflow. Only the `rules/` directory is updated.
