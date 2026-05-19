# Hermes Agent

> Run Nous Research's Hermes Agent against AnyRouter as a custom OpenAI-compatible provider for unified billing and one key across every model.


# Hermes Agent

[Hermes Agent](https://hermes-agent.nousresearch.com) by Nous Research is an autonomous agent with persistent memory, scheduled tasks, and 20+ messaging integrations (Telegram, Discord, Slack, WhatsApp, Signal, Email, CLI, …). It speaks OpenAI-compatible wire protocol, so pointing it at AnyRouter is a config-only change.

## Why route through AnyRouter

- **One key.** Reuse the same `sk-ar-` key for every model Hermes can run.
- **Audit logs.** Every Hermes call lands in your dashboard with cost, latency, and tokens.
- **Free model swaps.** Change `model:` in `~/.hermes/config.yaml` to any AnyRouter id without rotating keys.

## Step 1 — Install Hermes (if you haven't)

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
hermes setup
```

## Step 2 — Create an AnyRouter key

Open your [dashboard](/dashboard/keys) and create a key. It will be prefixed `sk-ar-`.

## Step 3 — Point Hermes at AnyRouter

Hermes stores model + provider config in `~/.hermes/config.yaml` and secrets in `~/.hermes/.env`.

Edit `~/.hermes/config.yaml`:

```yaml
model:
  provider: custom
  base_url: "https://anyrouter.dev/api/v1"
  model: "anthropic/claude-sonnet-4.6"
  api_mode: "chat_completions"
```

Add the key to `~/.hermes/.env`:

```bash
OPENAI_API_KEY=sk-ar-your-anyrouter-key
```

Hermes follows OpenAI-compatible env var conventions for custom providers, so `OPENAI_API_KEY` is the right slot regardless of which AnyRouter-routed model you pick.

You can also set these from the CLI without editing files:

```bash
hermes config set model anthropic/claude-sonnet-4.6
hermes config set OPENAI_API_KEY sk-ar-your-anyrouter-key
hermes config check
```

`hermes config check` verifies the configuration is complete; `hermes config edit` opens `config.yaml` in your editor.

## Step 4 — Run

```bash
hermes chat
# or pick a different model on the fly
hermes chat --model openai/gpt-5.4-mini
```

Every Hermes request now routes through AnyRouter and is billed against your credits.

## Recommended models for agent loops

- `anthropic/claude-sonnet-4.6` — balanced quality and latency, strong tool use
- `anthropic/claude-haiku-4.5` — cheapest, fastest, good default for memory + skill loops
- `openai/gpt-5.4` — best for long reasoning chains

List every available model:

```bash
curl https://anyrouter.dev/api/v1/models -H "Authorization: Bearer sk-ar-your-key"
```

## Rate limits

Hermes runs tight loops with subagents and skills, which can burst beyond a single key's per-minute budget. If you see `429 Too Many Requests`, back off and retry — the same key works again next window. Do **not** treat `429` as a permanent failure. See [Rate Limits](/docs/features/rate-limits).

## Related

- [Hermes Agent docs](https://hermes-agent.nousresearch.com/docs)
- [Claude Code](/docs/guides/claude-code)
- [OpenClaw](/docs/guides/openclaw)
- [Chat Completions API](/docs/api-reference/chat-completions)
- [Smart Routing](/docs/features/routing)
