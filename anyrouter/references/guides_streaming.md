# Streaming

> Receive completions incrementally via server-sent events. Reduce perceived latency and render tokens as they arrive.


# Streaming

Every chat completions and Messages API request supports streaming. Set `stream: true` in the request body and the response becomes a stream of [server-sent events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events) (SSE).

## Why stream?

- **Lower perceived latency** — render the first token as soon as the model emits it, instead of waiting for the full response.
- **Long outputs feel responsive** — users see progress on multi-second generations.
- **Early cancellation** — abort a request mid-flight if the user changes their mind.

## cURL

```bash
curl -N https://anyrouter.dev/api/v1/chat/completions \
  -H "Authorization: Bearer sk-ar-your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-5.4-mini",
    "stream": true,
    "messages": [{"role": "user", "content": "Count to 10"}]
  }'
```

The `-N` flag disables cURL's output buffering so chunks appear as they arrive.

## Event shape

Each line is an SSE `data:` event carrying a JSON payload:

```text
data: {"id":"chatcmpl-abc","choices":[{"delta":{"content":"Hel"}}]}
data: {"id":"chatcmpl-abc","choices":[{"delta":{"content":"lo"}}]}
data: {"id":"chatcmpl-abc","choices":[{"delta":{"content":"!"},"finish_reason":"stop"}]}
data: [DONE]
```

- `delta.content` — the token(s) added in this event.
- `delta.role` — set only on the first event.
- `finish_reason` — set on the final event.
- `[DONE]` — sentinel. No more events after this.

## TypeScript

The official OpenAI SDK handles the SSE parsing for you:

```typescript
const stream = await client.chat.completions.create({
  model: "openai/gpt-5.4-mini",
  messages: [{ role: "user", content: "Count to 10" }],
  stream: true,
})

for await (const chunk of stream) {
  const token = chunk.choices[0]?.delta?.content ?? ""
  process.stdout.write(token)
}
```

## Python

```python
stream = client.chat.completions.create(
    model="openai/gpt-5.4-mini",
    messages=[{"role": "user", "content": "Count to 10"}],
    stream=True,
)

for chunk in stream:
    print(chunk.choices[0].delta.content or "", end="", flush=True)
```

## Cancellation

Close the HTTP connection to cancel a stream. AnyRouter propagates the abort to the upstream provider so you only pay for tokens actually emitted up to the cancel point.

:::tip
Wire cancellation into your UI: if the user navigates away or hits a stop button, call `controller.abort()` on your `AbortController`. AnyRouter bills only for tokens streamed before the abort.
:::
