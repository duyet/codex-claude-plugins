# Gemini

- Put the role, rules, and output format in the system instruction. Put the task and data in the user turn.
- For long inputs, put the context first and the question at the end, after a phrase like "Based on the information above".
- Use the API's JSON schema or response MIME type for structured output instead of describing JSON in prose.
- Keep the prompt direct and short. Verbose, persuasive prompts degrade results.
- Multimodal: name each file or image and say what to extract from it. Mix modalities in one request instead of chaining calls.
- Reasoning is controlled by the thinking setting (budget or level), not by "think step by step" text.
- Use built-in grounding or search tools for current facts, and ask for sources.
- Few-shot examples help most on formatting. Keep their format identical to the desired output.
- Check the provider's model list for current ids, context limits, and parameter names.
