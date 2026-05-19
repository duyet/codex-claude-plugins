# Anthropic

> Point Anthropic Messages clients at AnyRouter — change the base URL and key, keep the anthropic-version header.


# Migrate from Anthropic

Repoint your Anthropic Messages client at AnyRouter.

| Setting        | Anthropic                       | AnyRouter                                       |
| -------------- | ------------------------------- | ----------------------------------------------- |
| Base URL       | `https://api.anthropic.com`     | `https://anyrouter.dev/api`                     |
| API key        | `ANTHROPIC_API_KEY`             | Your AnyRouter key, prefixed `sk-ar-`           |
| Version header | `anthropic-version: 2023-06-01` | Same. Required.                                 |
| Model          | `claude-sonnet-4-5`             | `anthropic/claude-sonnet-4.6` or any `anthropic/*` |

The SDK appends `/v1/messages`, so the base URL stops at `/api`.

## Anthropic SDK

```typescript
import Anthropic from "@anthropic-ai/sdk"

const client = new Anthropic({
  baseURL: "https://anyrouter.dev/api",
  apiKey: process.env.ANYROUTER_API_KEY,
})

const message = await client.messages.create({
  model: "anthropic/claude-sonnet-4.6",
  max_tokens: 1024,
  messages: [{ role: "user", content: "Review this incident summary." }],
})
```

## cURL

```bash
curl https://anyrouter.dev/api/v1/messages \
  -H "x-api-key: sk-ar-your-key" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "anthropic/claude-haiku-4.5",
    "max_tokens": 512,
    "messages": [{"role": "user", "content": "Say hello in one sentence."}]
  }'
```

The Messages endpoint accepts native Anthropic request bodies — same shape, same fields. For cross-provider routing instead, use [Chat Completions](/docs/api-reference/chat-completions) or [Responses](/docs/api-reference/responses).

## Related

- [Messages API](/docs/api-reference/messages)
- [Claude Code](/docs/guides/claude-code)
- [Models API](/docs/api-reference/models)
