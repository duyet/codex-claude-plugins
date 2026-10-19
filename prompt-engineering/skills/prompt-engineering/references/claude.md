# Claude

- Wrap distinct inputs in descriptive XML tags (`<document>`, `<instructions>`, `<examples>`) and refer to them by tag name. Put long documents first and the question last.
- Be explicit about the output you want and why. Claude follows instructions literally, so say "write the full implementation" rather than "can you suggest changes".
- Give 3 to 5 examples inside `<example>` tags when format matters. Make them varied so the model does not copy surface features.
- For hard reasoning, turn on extended or adaptive thinking through the API and give a high-level goal. Do not script the steps. Ask for reasoning in `<thinking>` and the result in `<answer>` only when thinking is off.
- State when independent tool calls should run in parallel.
- Prefill or a leading JSON brace steers format where the API supports it. Otherwise use structured outputs.
- Tell it what to do, not what to avoid. Replace "don't use markdown" with "write flowing prose paragraphs".
- Check the provider's model list for current ids and parameters before hardcoding either.
