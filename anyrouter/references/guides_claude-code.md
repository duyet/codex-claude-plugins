# Claude Code

> Route Claude Code through AnyRouter for unified billing, audit logs, and a single API key that unlocks every Anthropic model. Drop-in via two environment variables.


# Claude Code

Route Claude Code through AnyRouter to get unified billing, request audit logs, and a single API key for every Anthropic model — all by changing two environment variables.

## Why

- **Drop-in.** Zero code changes. Set two env vars and Claude Code works.
- **One key.** A single AnyRouter API key unlocks every Anthropic model and more.
- **Audit logs.** Every request is logged with cost, latency, and token usage.

## Step 1 — Create an AnyRouter API key

Head to your [dashboard](/dashboard/keys) and create a new API key. It will be prefixed with `sk-ar-`.

## Step 2 — Point Claude Code at AnyRouter

Claude Code reads `ANTHROPIC_BASE_URL` and `ANTHROPIC_API_KEY` from the environment. Set them to your AnyRouter base URL and API key:

```bash
export ANTHROPIC_BASE_URL="https://anyrouter.dev/api"
export ANTHROPIC_API_KEY="sk-ar-your-anyrouter-key"
```

Drop these two lines into `~/.bashrc` or `~/.zshrc` so they persist across shells.

### Optional — wrapper script

If you keep an Anthropic key for other work and only want AnyRouter for some sessions, drop the env vars into a wrapper instead of your shell rc. Save as `~/bin/claude-ar` (or anywhere on `$PATH`) and `chmod +x`:

```bash
#!/usr/bin/env bash
# Wrapper: route Claude Code through AnyRouter

export ANTHROPIC_AUTH_TOKEN="${ANYROUTER_API_KEY:-sk-ar-your-anyrouter-key}"
export ANTHROPIC_BASE_URL="https://anyrouter.dev/api"

# Optional — pin the model tier names to specific AnyRouter ids
export ANTHROPIC_DEFAULT_HAIKU_MODEL="anthropic/claude-haiku-4.5"
export ANTHROPIC_DEFAULT_SONNET_MODEL="anthropic/claude-sonnet-4.6"
export ANTHROPIC_DEFAULT_OPUS_MODEL="anthropic/claude-opus-4.6"

# Long-running agent flows: bump the SDK timeout
export API_TIMEOUT_MS=3000000

exec claude "$@"
```

Now `claude-ar` uses AnyRouter while bare `claude` keeps using your Anthropic key. Pass any flags through — they forward to `claude`. The same pattern works for any Anthropic-compatible upstream by swapping `ANTHROPIC_BASE_URL` and the model ids.

## Step 3 — Run Claude Code

That's it. Every Claude Code request now routes through AnyRouter. Requests are billed against your AnyRouter credits and recorded in your audit logs.

If you set the env vars in your shell rc, run `claude` as usual. If you used the wrapper script above, call `claude-ar` instead — every flag forwards through to `claude`:

```bash
# Start an interactive session
claude-ar

# Run a one-shot prompt
claude-ar "Explain the architecture of this project"

# Pick any AnyRouter model on the fly
claude-ar --model "anthropic/claude-sonnet-4.6" "Refactor this function"
claude-ar --model "anthropic/claude-haiku-4.5" "Summarize this file"
claude-ar --model "z-ai/glm-4.7" "Review this PR"
```

Bare `claude` still uses your Anthropic key; `claude-ar` always goes through AnyRouter.

## Supported models

Browse every model Claude Code can call by filtering the catalog to Messages-compatible models: [/models?endpoint=messages](/models?endpoint=messages). For non-Anthropic models, use the [Chat Completions API](/docs/api-reference/chat-completions).
