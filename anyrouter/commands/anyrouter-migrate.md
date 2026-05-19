---
description: Migrate the current project's LLM integration to AnyRouter. Detect existing OpenAI / Anthropic / OpenRouter usage, swap base URL + key + model ids, preserve behavior, and add a smoke test.
---

# /anyrouter:migrate

You are migrating this project to **AnyRouter** — a universal OpenAI-compatible LLM gateway at `https://anyrouter.dev/api/v1`. Read the `anyrouter` skill before doing anything; it has the contract, model-id rules, and migration recipes.

## Step 1 — Detect the current integration

Search the repo for any of these signals and report what you find before changing anything:

- Imports: `from openai import`, `import OpenAI`, `import Anthropic`, `from anthropic`, `import openrouter`.
- Base URLs: `api.openai.com`, `api.anthropic.com`, `openrouter.ai/api/v1`.
- Env vars: `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `OPENROUTER_API_KEY`, `ANTHROPIC_BASE_URL`, `OPENAI_BASE_URL`.
- Model ids: bare `gpt-*`, bare `claude-*`, `provider/model` slugs.
- SDK instances: `new OpenAI({...})`, `OpenAI(base_url=...)`, `Anthropic({...})`.

Output a short table: file, line, current value, what it becomes.

## Step 2 — Confirm the plan with the user

Before editing, ask the user:

1. Which key env var should the migrated code read — `ANYROUTER_API_KEY` (default) or an existing project name?
2. Should `anthropic/*` calls keep the `/messages` endpoint (Anthropic-native) or move to `/chat/completions` (unified)?
3. Pin a single model, read from env, or keep per-call overrides?
4. Should `X-AnyRouter-Title / -Source / -Version` headers be added for attribution?

Do not invent answers. If the user says "you decide", default to: `ANYROUTER_API_KEY`, `/chat/completions` for everything, model from `ANYROUTER_MODEL ?? "openai/gpt-5.4-mini"`, attribution headers on.

## Step 3 — Edit minimally

Apply the exact rules from the skill:

- Base URL → `https://anyrouter.dev/api/v1` (or `https://anyrouter.dev/api` for Anthropic-native).
- Key → `process.env.ANYROUTER_API_KEY` (or chosen env var). Never inline a literal.
- Model ids → `provider/model`. Map common bare ids:
  - `gpt-4o-mini` → `openai/gpt-5.4-mini`
  - `gpt-4o` → `openai/gpt-5.4`
  - `claude-3-5-sonnet-*` → `anthropic/claude-sonnet-4.6`
  - `claude-3-5-haiku-*` → `anthropic/claude-haiku-4.5`
  - When uncertain, leave the existing id and add a TODO so the user can pick a current model from https://anyrouter.dev/models.
- Reuse the existing LLM client module if one exists. Do **not** add a new one in parallel.
- Keep request/response shapes, streaming behavior, and error handling identical.

Touch only what you must. Don't refactor unrelated code.

## Step 4 — Update `.env.example` and docs

- Add `ANYROUTER_API_KEY=` to `.env.example`.
- If a README mentions `OPENAI_API_KEY` / `ANTHROPIC_API_KEY` / `OPENROUTER_API_KEY`, replace those mentions with `ANYROUTER_API_KEY` and link to https://anyrouter.dev/docs/getting-started/quickstart.

## Step 5 — Smoke test

Add (or update) a smoke test that exercises one short prompt end-to-end. Prefer the project's existing test framework; otherwise drop a one-shot script:

```bash
curl https://anyrouter.dev/api/v1/chat/completions \
  -H "Authorization: Bearer $ANYROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"openai/gpt-5.4-mini","messages":[{"role":"user","content":"Reply with: anyrouter-ok"}],"max_tokens":20}'
```

Run it. If it fails, do not declare the migration done — diagnose and fix.

## Step 6 — Summary

Report back:

- Files changed (count + paths).
- Bare model ids that were left as TODO for the user.
- Whether streaming, tool-use, and error paths were re-verified.
- The smoke test result.

If anything was skipped, **say so explicitly**. Don't hide uncertainty.
