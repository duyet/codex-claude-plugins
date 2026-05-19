# OpenAI

> Move an OpenAI Chat Completions or Responses client to AnyRouter by changing the base URL, API key, and model id.


# Migrate from OpenAI

Change three values and your existing OpenAI SDK works against AnyRouter.

| Setting   | OpenAI                            | AnyRouter                                                                |
| --------- | --------------------------------- | ------------------------------------------------------------------------ |
| Base URL  | `https://api.openai.com/v1`       | `https://anyrouter.dev/api/v1`                                           |
| API key   | `OPENAI_API_KEY`                  | Your AnyRouter key, prefixed `sk-ar-`                                    |
| Model     | `gpt-4o-mini`                     | `openai/gpt-5.4-mini` or any model from [Models](/docs/api-reference/models) |

## Chat Completions

```typescript
import OpenAI from "openai"

const client = new OpenAI({
  baseURL: "https://anyrouter.dev/api/v1",
  apiKey: process.env.ANYROUTER_API_KEY,
})

const completion = await client.chat.completions.create({
  model: "openai/gpt-5.4-mini",
  messages: [{ role: "user", content: "Summarize this pull request." }],
})
```

```bash
curl https://anyrouter.dev/api/v1/chat/completions \
  -H "Authorization: Bearer sk-ar-your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-5.4-mini",
    "messages": [{"role": "user", "content": "Write a release note."}]
  }'
```

## Responses

The same client works for the Responses API:

```typescript
const response = await client.responses.create({
  model: "openai/gpt-5.4-mini",
  input: "Extract the action items from this transcript.",
})
```

## Pick a different model

AnyRouter model ids include the owner — `openai/gpt-5.4-mini`, `anthropic/claude-sonnet-4.6`, etc. List what's available:

```bash
curl https://anyrouter.dev/api/v1/models -H "Authorization: Bearer sk-ar-your-key"
```

## Routing preferences (optional)

Add a `provider` block to any request to cap price, prefer latency, or pin upstream order:

```json
{
  "provider": {
    "sort": "latency",
    "max_price": { "prompt": "2.00", "completion": "8.00" },
    "allow_fallbacks": true
  }
}
```

## Related

- [Chat Completions API](/docs/api-reference/chat-completions)
- [Responses API](/docs/api-reference/responses)
- [Smart Routing](/docs/features/routing)
