# AI Agent Integration

> A short brief for any coding agent (Claude Code, Cursor, Codex, …) that needs to wire AnyRouter into an existing project.


# AI Agent Integration

Paste this into a coding agent (Claude Code, Cursor, Codex, Aider, Hermes, …) when you want it to wire AnyRouter into an existing project. AnyRouter is OpenAI-compatible, so the change is almost always: new base URL, new key, new model id.

## The contract

| Setting | Value |
| --- | --- |
| Base URL | `https://anyrouter.dev/api/v1` |
| API key env var | `ANYROUTER_API_KEY` (prefix `sk-ar-`) |
| Default chat model | `openai/gpt-5.4-mini` |
| Cheapest / fastest | `openai/gpt-5.4-nano`, `anthropic/claude-haiku-4.5` |
| High-quality | `anthropic/claude-sonnet-4.6`, `openai/gpt-5.4` |
| Main endpoint | `POST /chat/completions` (OpenAI-compatible) |
| Anthropic-native | `POST /messages` for `anthropic/*` models |
| Modern agent surface | `POST /responses` (typed output items + tools) |

Store the key in the project's normal secret manager. Do not commit it.

## Prompt to paste

```text
Integrate AnyRouter as the LLM provider for this project.

API:    OpenAI-compatible
Base:   https://anyrouter.dev/api/v1
Key:    process.env.ANYROUTER_API_KEY  (prefix sk-ar-)
Model:  process.env.ANYROUTER_MODEL    (fallback openai/gpt-5.4-mini)

Rules:
1. Reuse the project's existing LLM client if one exists.
   If not, add one small module that exports a configured OpenAI client.
2. Never hardcode the key.
3. Keep request/response shapes compatible with the current feature.
4. Preserve existing UI and behavior — only swap the LLM source.
5. If the project uses Anthropic Messages directly:
     - keep `anthropic/*` calls on /messages, OR
     - migrate them to /chat/completions for cross-provider routing.
6. Add a smoke test: one short prompt that prints the response.
```

## TypeScript

```bash
npm install openai
```

```typescript
import OpenAI from "openai"

export const anyrouter = new OpenAI({
  baseURL: "https://anyrouter.dev/api/v1",
  apiKey: process.env.ANYROUTER_API_KEY,
})

export const MODEL = process.env.ANYROUTER_MODEL ?? "openai/gpt-5.4-mini"

export async function generate(prompt: string) {
  const r = await anyrouter.chat.completions.create({
    model: MODEL,
    messages: [{ role: "user", content: prompt }],
  })
  return r.choices[0]?.message.content ?? ""
}
```

Streaming uses the same client — set `stream: true` and iterate.

## Python

```bash
pip install openai
```

```python
import os
from openai import OpenAI

client = OpenAI(
    base_url="https://anyrouter.dev/api/v1",
    api_key=os.environ["ANYROUTER_API_KEY"],
)

r = client.chat.completions.create(
    model=os.getenv("ANYROUTER_MODEL", "openai/gpt-5.4-mini"),
    messages=[{"role": "user", "content": "Reply with: anyrouter-ok"}],
)
print(r.choices[0].message.content)
```

## Smoke test

```bash
curl https://anyrouter.dev/api/v1/chat/completions \
  -H "Authorization: Bearer $ANYROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-5.4-mini",
    "messages": [{"role":"user","content":"Reply with: anyrouter-ok"}],
    "max_tokens": 20
  }'
```

The integration is done when:

- Calls hit `https://anyrouter.dev/api/v1`
- The key comes from `ANYROUTER_API_KEY` (no inline literal)
- Model ids use the `provider/model` form
- Streaming still streams if it streamed before
- Errors flow through the project's existing error path

## App attribution (optional)

Identify your app in the dashboard:

```typescript
new OpenAI({
  baseURL: "https://anyrouter.dev/api/v1",
  apiKey: process.env.ANYROUTER_API_KEY,
  defaultHeaders: {
    "X-AnyRouter-Title": "My App",
    "X-AnyRouter-Source": "web-app",
    "X-AnyRouter-Version": process.env.APP_VERSION ?? "dev",
  },
})
```

## Routing preferences (optional)

Add a `provider` block when the project needs price caps, latency sort, or fixed upstream order:

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

- [Quickstart](/docs/getting-started/quickstart)
- [Migrate from OpenAI](/docs/guides/migrate-from-openai)
- [Chat Completions API](/docs/api-reference/chat-completions)
- [Responses API](/docs/api-reference/responses)
- [App Attribution](/docs/features/app-attribution)
