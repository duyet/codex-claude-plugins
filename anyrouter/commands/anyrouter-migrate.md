---
description: Migrate this project's LLM integration to AnyRouter by swapping base URL, key, and model ids, then smoke test it.
---

# /anyrouter:migrate

Read the `anyrouter` skill (`skills/anyrouter/SKILL.md`) for the contract and recipes. Edit minimally.

1. **Detect.** Search for OpenAI, Anthropic, and OpenRouter imports, base URLs (`api.openai.com`, `api.anthropic.com`, `openrouter.ai`), key and base-URL env vars, and model ids. Report file, line, current value, and the planned change before editing.
2. **Confirm.** Ask the user which env var to read (default `ANYROUTER_API_KEY`), whether `anthropic/*` calls keep `/messages` or move to `/chat/completions`, how the model is chosen (pinned, from `ANYROUTER_MODEL`, or per call), and whether to add attribution headers. If told to decide, use `ANYROUTER_API_KEY`, `/chat/completions`, model from `ANYROUTER_MODEL`, and headers on.
3. **Edit.** Change the base URL, read the key from env, and convert model ids to `provider/model`. Look up current ids with the MCP `list_models` tool or `https://anyrouter.dev/models`. If you cannot pick one confidently, keep the existing id and leave a TODO. Reuse the existing client module. Keep request shapes, streaming, and error handling identical.
4. **Docs.** Add `ANYROUTER_API_KEY=` to `.env.example` and replace old key names in the README.
5. **Smoke test.** Add or update a test that sends one short prompt through `/chat/completions`, or use a one-shot `curl` with `Authorization: Bearer $ANYROUTER_API_KEY`. Run it. If it fails, diagnose and fix before calling the migration done.
6. **Report.** List files changed, ids left as TODO, whether streaming, tool use, and error paths were re-checked, and the smoke test result. Say plainly what was skipped.
