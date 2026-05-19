# OpenClaw 🦞

> Run OpenClaw against AnyRouter for unified billing and one key across every model and messaging channel.


# OpenClaw

[OpenClaw](https://github.com/openclaw/openclaw) is a personal AI assistant that answers you on the messaging channels you already use (Telegram, Discord, Slack, WhatsApp, Signal, iMessage, Email, …). It runs locally and supports any OpenAI-compatible LLM provider — so pointing it at AnyRouter is a config-only change.

## Why route through AnyRouter

- **One key** for every model OpenClaw can use.
- **Audit logs** with cost, latency, and tokens per request.
- **Free model swaps** — change one line in `~/.openclaw/openclaw.json`, no key rotation.

## Step 1 — Install OpenClaw

Requires Node 22.19+ (or 24+).

```bash
npm install -g openclaw@latest
# or: pnpm add -g openclaw@latest
```

## Step 2 — Create an AnyRouter key

Open your [dashboard](/dashboard/keys) and create a key. It will be prefixed `sk-ar-`.

## Step 3 — Onboard

The setup wizard handles gateway, workspace, channels, and provider in one flow:

```bash
openclaw onboard --install-daemon
```

When the wizard asks for an LLM provider, pick **Custom (OpenAI-compatible)** and enter:

- **Base URL** — `https://anyrouter.dev/api/v1`
- **API key** — your `sk-ar-…` key
- **Model** — any AnyRouter model id, e.g. `anthropic/claude-haiku-4.5`

That's it. Start the gateway and OpenClaw will route every request through AnyRouter.

```bash
openclaw gateway --port 18789 --verbose
```

## Manual config

If you'd rather edit the file directly, OpenClaw stores config in `~/.openclaw/openclaw.json`:

```json
{
  "env": {
    "ANYROUTER_API_KEY": "sk-ar-your-anyrouter-key"
  },
  "models": {
    "providers": {
      "anyrouter": {
        "baseUrl": "https://anyrouter.dev/api/v1",
        "api": "openai-completions",
        "apiKeyEnv": "ANYROUTER_API_KEY"
      }
    }
  },
  "agent": {
    "model": "anyrouter/anthropic/claude-haiku-4.5"
  }
}
```

Reference models with the `anyrouter/<provider>/<model>` form so OpenClaw routes them through the custom provider you just registered.

## Recommended models

- `anthropic/claude-haiku-4.5` — cheapest and fastest, good default for chat channels
- `anthropic/claude-sonnet-4.6` — best quality for long threads and tool use
- `openai/gpt-5.4-mini` — strong balance, broad capability coverage

List every available model:

```bash
curl https://anyrouter.dev/api/v1/models -H "Authorization: Bearer sk-ar-your-key"
```

## Per-channel models

OpenClaw can use different models per channel — cheap and fast for high-volume Telegram, more capable for Discord threads:

```json
{
  "telegram": {
    "agent": { "model": "anyrouter/anthropic/claude-haiku-4.5" }
  },
  "discord": {
    "agent": { "model": "anyrouter/anthropic/claude-sonnet-4.6" }
  }
}
```

## Troubleshooting

**401/403** — verify `echo $ANYROUTER_API_KEY` returns your key and that the dashboard shows it active with credit remaining.

**Unknown model** — make sure the id is prefixed `anyrouter/` and that the rest matches an entry from `GET /api/v1/models`.

**429** — OpenClaw heartbeats and scheduled tasks can burst. Back off and retry — the same key works again next window. See [Rate Limits](/docs/features/rate-limits).

## Related

- [OpenClaw on GitHub](https://github.com/openclaw/openclaw)
- [Claude Code](/docs/guides/claude-code)
- [Hermes Agent](/docs/guides/hermes-agent)
- [Smart Routing](/docs/features/routing)
