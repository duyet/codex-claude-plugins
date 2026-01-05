# Ralph Wiggum Plugin

Self-referential development loop for Claude Code.

## Commands

- `/ralph-loop` - Start iterative loop with a prompt
- `/status` - Show current loop status
- `/cancel-ralph` - Cancel active loop
- `/help` - Usage documentation

## Hook

Stop hook in `hooks/hooks.json` intercepts exit and feeds prompt back for next iteration.

## State Files

State stored in `.claude/`:
- `ralph-loop.local.md` - Loop state (iteration, prompt, settings)
- `ralph-circuit.local.json` - Circuit breaker state

## Testing

Test stop hook manually:
```bash
cd ralph-wiggum
echo '{"session_id": "test", "transcript_path": "/tmp/test.json"}' | ./hooks/stop-hook.sh
```

## Common Issues

1. **Hook exits early**: Check state file exists at `.claude/ralph-loop.local.md`
2. **Circuit breaker trips**: Check `.claude/ralph-circuit.local.json` for state
3. **Loop doesn't stop**: Ensure `<promise>` tags match exactly
