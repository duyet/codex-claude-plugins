# Dashboard Tour

> A guided walkthrough of every dashboard page, in the order a new team typically uses them.


# Dashboard Tour

This tour walks through every page in the AnyRouter dashboard at `https://anyrouter.dev/dashboard` in the order a team usually needs them. It is split into three paths:

- **Day-1 path** — go from sign-up to a working API call and a verified log entry.
- **Week-1 path** — understand spend, lock in defaults, and tighten privacy.
- **Scaling path** — add teammates, bring your own keys, browse models, and govern usage with per-key limits.

Each step explains *when* a team typically arrives at it, lists *what you'll do*, and links to the dedicated docs page for deeper reading. Some sibling pages are being added in parallel PRs — the links are correct and will resolve once those PRs ship.

If you only have ten minutes, do the Day-1 path. Everything else can wait until you have real traffic to look at.

## Quick map

| Stage | Pages, in order |
| --- | --- |
| Day 1 | Settings → Keys → Quickstart → Logs |
| Week 1 | Usage Explorer → Credits → Presets → Privacy |
| Scaling | Organizations → BYOK → Models catalog → Per-key limits |

Jump to a section:

- [Day-1 path](#day-1-path)
- [Week-1 path](#week-1-path)
- [Scaling path](#scaling-path)
- [What next](#what-next)

---

## Day-1 path

The goal of Day 1 is simple: make one real API call from your laptop, see it land in the logs, and confirm credits were deducted. Four pages get you there.

### 1. Settings — confirm the account is yours

This is the first place to land after signing in. The Settings page is where you check that the account email, display name, and default workspace match what you expect, and where you enable two-factor authentication before you generate any keys.

Teams skip this step at their peril — a missed 2FA setup on Day 1 becomes a much harder migration once dozens of keys exist.

**What you'll do**

- Confirm the email shown matches the address you signed up with.
- Enable two-factor authentication.
- Set your timezone so logs and usage charts render in local time.
- Pick a default workspace if you belong to more than one.

Read more: [Account settings](/docs/features/account-settings).

### 2. Keys — mint your first API key

Once the account is set up, head to the Keys page and create your first API key. Every AnyRouter key starts with the `sk-ar-` prefix and is shown in full only once — copy it into a password manager or your local `.env` file before closing the dialog.

For a first key, leave the default scopes alone. You can come back later to add per-key rate limits, expiry dates, and IP allowlists once you understand your traffic.

**What you'll do**

- Click **New key**, name it something like `laptop-dev`.
- Copy the `sk-ar-...` value into your local `.env` (it is shown once).
- Leave rate limits and expiry blank for now.
- Note the key's last-four suffix shown in the table — that is how you'll identify it in logs.

Read more: [API keys](/docs/features/api-keys).

### 3. Quickstart — run the curl command

With a key in hand, the Quickstart page in the docs gives you a copy-pasteable `curl` command that hits `https://anyrouter.dev/v1/chat/completions`. Run it from your terminal with `Authorization: Bearer sk-ar-...` and you should see a streamed JSON response within a second or two.

If anything fails, the error envelope returned includes `requestId` and `cfRay` — keep those handy, they make support tickets resolvable in minutes instead of hours.

**What you'll do**

- Export your key: `export ANYROUTER_API_KEY=sk-ar-...`.
- Paste the `curl` snippet from the Quickstart and hit enter.
- Confirm you get a 200 response with a `choices[0].message.content` field.
- If you see a non-200, copy the `requestId` from the response body.

Read more: [Quickstart](/docs/getting-started/quickstart).

### 4. Logs — verify the call landed

The final Day-1 stop is the Logs page (sometimes called Request Logs). Within a few seconds of your `curl`, a row should appear with the model name, token counts, cost, and the last four characters of your key.

Click the row to expand it. You'll see the full request and response (subject to your privacy settings — see the Week-1 path), latency breakdown, and which upstream served the call. This is where you'll spend most of your debugging time over the next few weeks.

**What you'll do**

- Filter by your key's last-four suffix to find your test call.
- Click the row to expand request and response payloads.
- Note the `cost_credits` and `tokens_in` / `tokens_out` fields.
- Bookmark this page — you will come back to it.

Read more: [Request logs](/docs/features/request-logs).

At this point, Day 1 is done. You have a working integration. Everything below is about operating it well.

---

## Week-1 path

Once real traffic is flowing, the questions change. *How much am I spending? On which models? Are my defaults sensible? What data is being retained?* The Week-1 path answers those.

### 5. Usage Explorer — see where the money goes

The Usage Explorer is the dashboard's analytics surface. Stack-by-day charts break down spend, tokens, and request counts by model, by key, by app attribution tag, and by status. Filter to the last 7 days the first time you open it — that is enough to spot the model that quietly costs ten times the others.

Teams typically discover three things here in the first week: one model is doing most of the work, one key is doing most of the traffic, and one app or environment is responsible for most of the cost. Use that to inform the rest of the Week-1 path.

**What you'll do**

- Set the date range to the last 7 days.
- Group by model to see which models dominate spend.
- Group by key to see which integrations are loudest.
- Export a CSV if you want to share numbers with your team.

Read more: [Usage Explorer](/docs/features/usage-explorer).

### 6. Credits — top up and set alerts

The Credits page shows your current balance, recent top-ups, and a burn-rate estimate. If your Week-1 spend chart shows you'll run out of credits before payday, this is where to top up. It is also where you enable low-balance email alerts so you don't get surprised on a Sunday.

For teams expecting steady traffic, set the auto-refill threshold once and forget about it. For teams running a one-off experiment, prefer manual top-ups and a tight expiry on the key instead.

**What you'll do**

- Check your current balance and the seven-day burn rate.
- Enable low-balance email alerts at a threshold that gives you 3+ days of runway.
- Decide between auto-refill and manual top-ups.
- Note your invoice email if you need PDF receipts.

Read more: [Credits and billing](/docs/features/credits).

### 7. Presets — codify your defaults

A Preset is a saved bundle of model, system prompt, sampling parameters, and tool definitions. Once you know which model and which system prompt your team keeps reaching for, save it as a Preset and call it by name (`preset:my-team/summarizer`) instead of repeating the same body fields in every request.

Presets pay for themselves the first time you need to switch models across an entire codebase — change the preset, every caller follows.

**What you'll do**

- Identify the model + system prompt combo your team uses most.
- Save it as a Preset with a memorable slug.
- Switch one app over to the preset and confirm responses still look right.
- Bookmark the Preset page; you'll add more as patterns emerge.

Read more: [Presets](/docs/features/presets).

### 8. Privacy — decide what gets stored

The Privacy Controls page is where you decide how much of each request and response is retained for logs, analytics, and debugging. Defaults are conservative, but if you process regulated data (PHI, payment info, EU personal data) tighten them on Day 1 of Week 1, not later.

The two settings most teams change are *log payloads* (full vs. metadata-only) and *retention window* (default vs. 7 days). For zero-retention modes, expect debugging to get harder — that trade is the point.

**What you'll do**

- Read the current policy summary on the page.
- Decide whether to keep full payloads, metadata only, or nothing.
- Set a retention window that matches your compliance posture.
- If you toggle to metadata-only, run a test call and confirm Logs reflects the change.

Read more: [Privacy controls](/docs/features/privacy-controls).

---

## Scaling path

By the time you reach this path, you have traffic, you have a budget, and you have at least one teammate asking for access. The Scaling path is about going from a single-user account to a governed team.

### 9. Organizations — bring teammates in

An Organization is a shared workspace with its own credit balance, keys, presets, and logs. Create one, invite teammates by email, and assign roles (`owner`, `admin`, `member`, `billing`). Personal accounts and Organizations coexist; you can be in several at once and switch between them from the dashboard header.

The most common Week-2 mistake is sharing a personal API key over Slack. Don't. Create an Organization, invite the teammate, let them mint their own key under the org.

**What you'll do**

- Create an Organization and name it after your team or product.
- Invite teammates and pick roles deliberately (only `billing` sees invoices).
- Move shared Presets into the Organization workspace.
- Have each teammate mint their own `sk-ar-...` key inside the Organization.

Read more: [Organizations](/docs/features/organizations).

### 10. BYOK — bring your own provider keys

Bring-Your-Own-Key (BYOK) lets you attach your own credentials for upstream providers (OpenAI, Anthropic, xAI, Z-AI, and others) to your AnyRouter account. Traffic still flows through `https://anyrouter.dev`, but billing for those calls hits your upstream account directly — useful for committed-spend deals, enterprise contracts, or compliance setups that require a direct relationship with the provider.

BYOK is not for everyone. If you don't already have a contract with the upstream, the default routing is cheaper and simpler. Read the page before you wire anything up.

**What you'll do**

- Decide which providers you have direct contracts with.
- Add upstream keys on the BYOK page (encrypted at rest with per-row salt).
- Route a single model through BYOK as a test and watch the invoice on the provider side.
- Document which models go through BYOK vs. shared infrastructure.

Read more: [BYOK](/docs/features/byok).

### 11. Models catalog — see what's available

The Models catalog is the canonical list of every model AnyRouter exposes, with pricing per million tokens, context window, supported features (tools, vision, JSON mode), and a status badge for upstream health. Open it whenever someone asks *"can we use model X?"* — it is faster than searching the docs.

You can also reach each model's individual page (for example `https://anyrouter.dev/model/openai/gpt-5.4`) and the raw markdown at `/model/openai/gpt-5.4.md` if you want a machine-readable spec for an agent.

**What you'll do**

- Filter by capability (vision, tools, JSON mode) to find candidates.
- Compare prices per million input vs. output tokens.
- Check the status badge before promoting a model into production.
- Bookmark the catalog for ad-hoc model lookups.

Read more: [Models catalog](/docs/features/models-catalog).

### 12. Per-key rate limits — govern the busy keys

Once Usage Explorer has shown you which keys are loudest, the last scaling step is to put per-key rate limits on them. The Keys page is also where you set per-key rate limits (requests-per-minute, tokens-per-minute, or daily spend ceilings). This is how you stop a runaway batch job from burning the whole org's credits in an afternoon.

A good default for production keys: cap daily spend at 2x your expected daily usage, set a generous RPM, and leave TPM unlimited unless you've seen a problem. Tighten only when you have data.

**What you'll do**

- Open the Keys page and click the key you want to limit.
- Set a daily spend cap based on observed usage from Usage Explorer.
- Set a requests-per-minute ceiling that protects against runaway loops.
- Add an expiry date if the key is for a short-lived project.

Read more: [API keys](/docs/features/api-keys) (rate limits section).

---

## What next

You've toured every dashboard page. The natural next step is the API reference — once you know *what* the dashboard shows, you'll want to know *what* the API surface exposes so your code can do the same things.

- [API overview](/docs/api-reference/overview) — every endpoint, with example requests and responses.
- [Chat completions](/docs/api-reference/chat-completions) — the workhorse endpoint.
- [Responses API](/docs/api-reference/responses) — stateful, tool-friendly successor.
- [Errors](/docs/guides/errors) — error envelope shape, `requestId`, and `cfRay` for support.

If you're integrating from an existing provider, the migration guides cut the work down by hours:

- [Migrate from OpenAI](/docs/guides/migrate-from-openai)
- [Migrate from Anthropic](/docs/guides/migrate-from-anthropic)
- [Migrate to the Responses API](/docs/guides/migrate-to-responses)

Welcome aboard.
