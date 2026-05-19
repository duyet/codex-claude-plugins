# Smart Routing

> How AnyRouter picks an upstream provider for each request. Priority order, automatic failover, model aliases, and explicit override controls.


# Smart Routing

Every request to AnyRouter flows through a routing layer that picks the best upstream provider for the requested model. Routing is deterministic by default, respects health and cooldown state, and can be fine-tuned per request when you need reproducibility or cost and latency controls.

## Model selection methods

You can select a model in three ways:

1. **Direct model** — `anthropic/claude-sonnet-4.6`
2. **Preset reference** — `@preset/code-reviewer`
3. **Preset with override** — `openai/gpt-5.4-mini@preset/code-reviewer`

See [Presets](/docs/features/presets) for full documentation on the preset syntax.

## How a model maps to an upstream

AnyRouter maintains a list of **upstream candidates** for every model id. Each candidate can include routing metadata such as priority, price, latency, and throughput. On each request, AnyRouter builds the candidate set, applies your request-level provider preferences, skips cooled-down backends, and dispatches to the highest-priority remaining candidate.

If the chosen upstream fails with a retryable error, AnyRouter walks the remaining ordered candidates as fallbacks unless you disabled fallbacks for that request.

## Request-level provider preferences

You can steer routing directly in the request body with the OpenRouter-style `provider` object:

```json
{
  "model": "openai/gpt-5.4-mini",
  "provider": {
    "only": ["OpenAI", "Groq"],
    "order": ["Groq", "OpenAI"],
    "sort": "latency",
    "allow_fallbacks": true,
    "max_price": {
      "prompt": "1.00",
      "completion": "2.00"
    },
    "preferred_max_latency": 300,
    "preferred_min_throughput": 40
  }
}
```

Supported controls:

- `only` limits the candidate set to the named providers.
- `ignore` removes named providers from the candidate set.
- `order` pins a preferred backend order before the default route order.
- `sort` reorders candidates by `price`, `latency`, or `throughput`.
- `max_price.prompt` and `max_price.completion` filter out backends above your budget.
- `preferred_max_latency` drops candidates that exceed your latency target.
- `preferred_min_throughput` drops candidates that fall below your throughput target.
- `allow_fallbacks: false` disables retrying the next backend after the first candidate fails.

Provider names are normalized, so values like `OpenAI`, `openai`, `Z.AI`, and `Moonshot AI` map to the correct backend ids automatically.

## Failover

A candidate is marked **unhealthy** for a short window when it:

- Returns a 5xx status.
- Times out (`timeout_ms` exceeded).
- Exhausts its rate-limit budget.

Unhealthy candidates are skipped until the cooldown expires. Requests that hit a fallback are still recorded with the final backend id so you can see when failover happened.

## Forcing a specific upstream header

Set the `X-AnyRouter-Provider` header on any request to pin it to a single candidate:

```bash
curl https://anyrouter.dev/api/v1/chat/completions \
  -H "Authorization: Bearer sk-ar-your-key" \
  -H "X-AnyRouter-Provider: openrouter" \
  -H "Content-Type: application/json" \
  -d '{"model": "openai/gpt-5.4-mini", "messages": [{"role": "user", "content": "hi"}]}'
```

Useful for:

- **Reproducibility** — pin to a specific provider so your eval results don't silently drift when the router fails over.
- **BYOK tests** — verify a specific BYOK credential is working end-to-end.
- **Outage debugging** — route around a failing provider without waiting for the health cooldown.

If the forced provider is unhealthy, the request fails immediately. Header pinning is stricter than request-body preferences and bypasses normal fallback selection.

## Model aliases

Some models have multiple slugs that resolve to the same upstream, for compatibility with other gateways. For example, `anthropic/claude-sonnet-4.6` and `claude-sonnet-4.6` both route to the same backend. Canonical slugs are `provider/model`; bare slugs are resolved by lookup.

## Tracing and request ids

Inference endpoints also accept an optional request-body `trace` object:

```json
{
  "trace": {
    "trace_id": "4f8c2b9670b44b49a2e71e7fd5c0b1d3",
    "trace_name": "checkout-flow",
    "span_name": "summarize-cart"
  }
}
```

When present, AnyRouter keeps that trace id attached to internal routing steps and forwards trace correlation metadata to AI Gateway-backed upstream calls. Every response also includes an `X-Request-ID` header so support can locate the exact request lifecycle.

## Rate-limit headers

Every response includes rate-limit metadata for **both** the AnyRouter key and the upstream candidate that served the request:

```text
X-RateLimit-Limit: 600
X-RateLimit-Remaining: 599
X-RateLimit-Reset: 1760000060
X-Upstream-RateLimit-Remaining: 998
```

Use these to back off gracefully — the router will start failing over if the selected candidate's upstream limit is close to exhaustion, but clients that respect the header get smoother behavior.
