# /statusline:status

Display real-time metrics about your current Claude Code session.

## Action Required

When this command is invoked, you MUST:

### 1. Detect Provider

Check the current model from the environment or session info:
- Models starting with `glm-` → z.ai provider
- All other models → Anthropic provider

### 2. Fetch Rate Limits

Run:
```bash
bash /Users/duet/project/claude-plugins/statusline/scripts/fetch-rate-limits.sh
```

Or detect from the statusline output directly.

### 3. Display Status Line

Output format depends on provider:

**Anthropic** (Claude, Opus, Sonnet, Haiku):
```
📊 [health] | 5h: [5h%] | 7d: [7d%] | Model: [model] | [duration] | Tools: [tool×count] | Agents: [name(time)] | Tasks: [status counts]
```

**z.ai GLM** (glm-5.1, glm-4, etc.):
```
📊 [health] | z.ai Tokens: [pct]% | Tools: [pct]% ([N] left) [Search:N Web:N ZRead:N] | Model: GLM [version] | [duration] | Tasks: [status counts]
```

**Health indicators:**
- 🟢 Context 0-60%
- 🟡 Context 60-85%
- 🔴 Context 85%+

**Task status:**
- 🔄 in_progress count
- ⏳ pending count
- ✓ completed count

### 4. Hide Empty Values

Do NOT show:
- Tools section if no tools used
- Agents section if no agents running
- Tasks section if no todos exist
- Per-tool breakdown if all zero
- Any section with zero or null values

## Example Output

**Anthropic:**
```
📊 🟡 67% | 5h: 42% | 7d: 28% | Model: Opus 4.5 | 15m 42s | Tools: Read×8 Glob×4 Bash×3 | Tasks: 🔄 1 ⏳ 3 ✓ 7
```

**z.ai GLM:**
```
📊 🟢 21% | z.ai Tokens: 15% | Tools: 11% (883 left) [Web:35 ZRead:82] | Model: GLM 5.1 | 8m 15s
```

Minimal output:
```
📊 🟢 12% | 5h: 5% | 7d: 2%
```

## Related Commands

- `/statusline:config` — Configure display format
- `/statusline:disable` — Disable monitoring
