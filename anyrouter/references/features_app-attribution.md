# App Attribution

> Attribute your API usage to your app with HTTP-Referer and X-AnyRouter headers and appear in public rankings and analytics.


App attribution links each API call to the app that made it, so your app can appear in AnyRouter's public rankings, model leaderboards, and per-app analytics. Attribution is driven by the `HTTP-Referer` header, with optional `X-AnyRouter-*` headers for display metadata and marketplace categories.

## Benefits of App Attribution

When you attribute your app properly:

- **Public App Rankings** — your app appears on the AnyRouter rankings page with daily, weekly, and monthly views
- **Model Leaderboards** — your app shows up on individual model pages in the "Apps" tab
- **Per-App Analytics** — you get model usage breakdowns, token consumption, and adoption metrics scoped to your app
- **Marketplace Visibility** — categorized apps surface in topic pages for discovery

## Attribution Headers

### Required

#### HTTP-Referer (required)

The `HTTP-Referer` header identifies your app's URL and is the **primary identifier** for rankings. Without it, no app page is created and your usage will not appear in any leaderboard.

Your app's normalized Referer URL becomes its unique identifier:

- The host is lowercased and the path is dropped — `https://myapp.com/playground` and `https://myapp.com/docs` attribute to the same app `https://myapp.com`.
- The scheme is preserved — `https://myapp.com` and `http://myapp.com` are different apps.
- The port is preserved when non-default — `https://myapp.com:8443` is a distinct app.

#### Localhost / loopback URLs

Apps running on `localhost`, `127.0.0.1`, `::1`, or any `*.localhost` host **must also send `X-AnyRouter-Title`** to be tracked — otherwise different developers running on the same local port would collapse into one shared app. With a title, the local app is registered under `local://<title-slug>`.

### Optional

#### X-AnyRouter-Title

Sets or modifies your app's display name in rankings and analytics. Without it, your Referer host is used as the display name.

#### X-AnyRouter-Source

A free-form identifier for your app's platform or distribution channel — e.g. `web-app`, `desktop`, `vscode-extension`. Used for filtering and grouping inside the dashboard. Not part of the dedup key.

#### X-AnyRouter-Version

Your app's version string. Useful for comparing usage across releases. Free-form; semantic versioning (`1.2.3`) is recommended.

#### X-AnyRouter-Categories

Assigns your app to one or more marketplace categories. Pass a comma-separated list of **up to 2 categories per request**. Categories must be lowercase, hyphen-separated, and each entry is limited to 30 characters. Unrecognized values are silently ignored.

Categories are **merged** with whatever your app has accumulated previously across requests, capped at 10 total. You don't need to send the full list each time — sending one or two new categories on a single request is enough to add them.

##### Category catalog

**Coding** — software-development tools:

- `cli-agent` — terminal-based coding assistants
- `ide-extension` — editor / IDE integrations
- `cloud-agent` — cloud-hosted coding agents
- `programming-app` — programming apps
- `native-app-builder` — mobile and desktop app builders

**Creative** — creative tools:

- `creative-writing` — creative writing tools
- `video-gen` — video generation apps
- `image-gen` — image generation apps

**Productivity** — writing and productivity tools:

- `writing-assistant` — AI-powered writing tools
- `general-chat` — general chat apps
- `personal-agent` — personal AI agents

**Entertainment**:

- `roleplay` — roleplay apps and character-based chat
- `game` — gaming and interactive entertainment apps

#### Need a category that isn't listed?

Only recognized categories are accepted; unrecognized values are silently dropped. If your app doesn't fit, email **bot@anyrouter.dev** and we'll evaluate adding it.

## Implementation Examples

```typescript
// TypeScript / JavaScript
fetch('https://anyrouter.dev/api/v1/chat/completions', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer sk-ar-your-key',
    'Content-Type': 'application/json',
    // Required for attribution
    'HTTP-Referer': 'https://myapp.com',
    // Optional display metadata
    'X-AnyRouter-Title': 'My AI Assistant',
    'X-AnyRouter-Source': 'web-app',
    'X-AnyRouter-Version': '1.0.0',
    'X-AnyRouter-Categories': 'general-chat,personal-agent',
  },
  body: JSON.stringify({
    model: 'google/gemma-4-26b-a4b-it:free',
    messages: [{ role: 'user', content: 'Hello, world!' }],
  }),
});
```

```python
# Python
import requests

response = requests.post(
    url='https://anyrouter.dev/api/v1/chat/completions',
    headers={
        'Authorization': 'Bearer sk-ar-your-key',
        'Content-Type': 'application/json',
        # Required for attribution
        'HTTP-Referer': 'https://myapp.com',
        # Optional display metadata
        'X-AnyRouter-Title': 'My AI Assistant',
        'X-AnyRouter-Source': 'web-app',
        'X-AnyRouter-Version': '1.0.0',
        'X-AnyRouter-Categories': 'general-chat,personal-agent',
    },
    json={
        'model': 'google/gemma-4-26b-a4b-it:free',
        'messages': [{'role': 'user', 'content': 'Hello, world!'}],
    },
)
```

```bash
# cURL
curl https://anyrouter.dev/api/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-ar-your-key" \
  -H "HTTP-Referer: https://myapp.com" \
  -H "X-AnyRouter-Title: My AI Assistant" \
  -H "X-AnyRouter-Source: web-app" \
  -H "X-AnyRouter-Version: 1.0.0" \
  -H "X-AnyRouter-Categories: general-chat,personal-agent" \
  -d '{
    "model": "google/gemma-4-26b-a4b-it:free",
    "messages": [
      { "role": "user", "content": "Hello, world!" }
    ]
  }'
```

## Where Your App Appears

### Rankings

Attributed apps appear on the main rankings page with daily, weekly, and monthly views, sorted by total token consumption.

### Model Pages

Each model has an "Apps" tab listing the top apps using that specific model.

## Best Practices

- **Always send `HTTP-Referer`** — without it, the request is not attributed and your app is invisible to rankings.
- **Pin the Referer to your canonical origin** (e.g. `https://yourapp.com`), not a deep page URL — paths are dropped anyway, but a stable origin makes attribution predictable.
- **Send a `X-AnyRouter-Title`** if you want a friendly display name; otherwise the host is shown.
- **Send `X-AnyRouter-Categories`** to surface in marketplace topic pages.
- **For local development**, include `X-AnyRouter-Title` so your loopback app doesn't collide with other developers'.
- **Versions** should follow semver if possible; they're useful for comparing rollouts.

## Merging or Splitting Apps

If your app was logged under two different Referer URLs (e.g. you migrated from `myapp.com` to `myapp.io`) and you want them consolidated into one entry, email **bot@anyrouter.dev** with both URLs and we'll merge them into a single canonical app record. The same address handles splitting an entry if you need the inverse.

## Privacy Considerations

- Only apps that send `HTTP-Referer` are tracked in rankings.
- Attribution headers don't expose anything sensitive about your request payloads — just identity.
- Your app's Referer, title, and chosen categories are publicly visible in rankings.

## Related Documentation

- [Quickstart Guide](/docs/getting-started/quickstart) — basic setup with attribution headers
- [API Reference](/docs/api-reference/overview) — complete header documentation
