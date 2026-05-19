# Quickstart

> Get up and running with AnyRouter in under five minutes. Point any OpenAI-compatible client at the AnyRouter base URL and you're done.


# Quickstart

AnyRouter is a universal AI model router — a single OpenAI-compatible API gateway that routes requests to 150+ AI models across 28+ providers. This guide gets you making your first request in under five minutes.

## 1. Create an API key

Sign in to [your dashboard](/dashboard/keys) and create a new API key. AnyRouter keys are prefixed with `ar-` so you can tell them apart from upstream provider keys.

:::tip
Keys are scoped per-organization. Create a separate key for every environment (dev, staging, prod) so you can rotate them independently.
:::

## 2. Point your client at AnyRouter

AnyRouter implements the OpenAI Chat Completions API. Every official and community SDK works with **zero code changes** — just override the base URL and API key.

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://anyrouter.dev/api/v1",
    api_key="sk-ar-your-key",
)

response = client.chat.completions.create(
    model="openai/gpt-5.4-mini",
    messages=[{"role": "user", "content": "Hello!"}],
)
print(response.choices[0].message.content)
```

```typescript
import OpenAI from "openai"

const client = new OpenAI({
  baseURL: "https://anyrouter.dev/api/v1",
  apiKey: "sk-ar-your-key",
})

const response = await client.chat.completions.create({
  model: "openai/gpt-5.4-mini",
  messages: [{ role: "user", content: "Hello!" }],
})
console.log(response.choices[0].message.content)
```

```bash
curl https://anyrouter.dev/api/v1/chat/completions \
  -H "Authorization: Bearer sk-ar-your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-5.4-mini",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

## 3. Choose a model

Model IDs follow the `provider/model` convention, just like OpenRouter. Browse the full list on the [models page](/models) or fetch it via the API:

```bash
curl https://anyrouter.dev/api/v1/models \
  -H "Authorization: Bearer sk-ar-your-key"
```

Some popular choices:

| Model ID | Provider | Notes |
|---|---|---|
| `openai/gpt-5.4-mini` | OpenAI | Flagship general-purpose |
| `anthropic/claude-sonnet-4.6` | Anthropic | 1M context, strong coding |
| `anthropic/claude-haiku-4.5` | Anthropic | Fast and cheap |
| `google/gemini-2.5-pro` | Google | Multimodal, 2M context |
| `meta-llama/llama-3.3-70b` | Meta | Open-weight flagship |

## 4. What's next?

- [Authentication](/docs/getting-started/authentication) — key scopes, rotation, and BYOK
- [Chat Completions API](/docs/api-reference/chat-completions) — full request/response reference
- [Migrate from OpenAI](/docs/guides/migrate-from-openai) — swap base URL, key, and model id
- [Migrate from Anthropic](/docs/guides/migrate-from-anthropic) — use Messages with Anthropic clients
- [Streaming](/docs/guides/streaming) — server-sent events for live output
- [Use Claude Code with AnyRouter](/docs/guides/claude-code) — point Claude Code at AnyRouter with two env vars
