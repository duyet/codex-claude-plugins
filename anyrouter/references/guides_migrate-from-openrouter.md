# OpenRouter

> Move OpenRouter Chat Completions requests to AnyRouter, including provider preferences for ordering, price caps, and fallbacks.


# Migrate from OpenRouter

AnyRouter accepts the same `provider/model` ids and the same request-level `provider` preferences on OpenAI-compatible endpoints.

| Setting              | OpenRouter                     | AnyRouter                                  |
| -------------------- | ------------------------------ | ------------------------------------------ |
| Base URL             | `https://openrouter.ai/api/v1` | `https://anyrouter.dev/api/v1`             |
| API key              | OpenRouter key                 | Your AnyRouter key, prefixed `sk-ar-`      |
| Model                | `provider/model`               | `provider/model` from the AnyRouter catalog |
| Provider preferences | `provider` object              | `provider` object — same fields            |

## Swap the client

```typescript
import OpenAI from "openai"

const client = new OpenAI({
  baseURL: "https://anyrouter.dev/api/v1",
  apiKey: process.env.ANYROUTER_API_KEY,
})

const completion = await client.chat.completions.create({
  model: "anthropic/claude-sonnet-4.6",
  messages: [{ role: "user", content: "Summarize this support thread." }],
})
```

## Provider preferences

Use `only` to allowlist, `ignore` to exclude, `order` to pin a preference order, and `sort` to choose the strategy.

```bash
curl https://anyrouter.dev/api/v1/chat/completions \
  -H "Authorization: Bearer sk-ar-your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-5.4-mini",
    "messages": [{"role": "user", "content": "Draft a changelog entry."}],
    "provider": {
      "only": ["OpenAI", "Groq"],
      "order": ["Groq", "OpenAI"],
      "sort": "latency",
      "allow_fallbacks": true
    }
  }'
```

## Price caps

Filter out upstreams above your budget. Prices are dollars per 1M tokens.

```json
{
  "provider": {
    "sort": "price",
    "max_price": { "prompt": "1.00", "completion": "4.00" },
    "allow_fallbacks": true
  }
}
```

If every route is filtered out, the request fails — AnyRouter never silently ignores a price ceiling.

## Disable fallbacks

Fallbacks are on by default. Turn them off when reproducibility matters more than availability (eval runs against a fixed upstream):

```json
{ "provider": { "allow_fallbacks": false } }
```

## Related

- [Smart Routing](/docs/features/routing)
- [Models API](/docs/api-reference/models)
- [Chat Completions API](/docs/api-reference/chat-completions)
