# raw/ — capture inbox + ground-truth sources (Layer 1)

Raw material that the **dream** pass (`../DREAM.md`) consumes into clean,
linked notes under `../memory/`. Two kinds of content live here:

## `inbox/` — daily quick-capture (writable, ephemeral)

Agents append rough observations here as they work — no frontmatter, no
ceremony. One file per day: `inbox/YYYY-MM-DD.md`, timestamped bullets. This is
a scratch journal, not the final memory.

The dream pass **consumes** these: it promotes durable, general facts into
`memory/` notes, then **deletes the processed inbox file** (it's been distilled).
So `inbox/` stays small and self-cleaning — capture freely, dream tidies up.

## source docs — immutable ground truth (read-only)

Drop PDFs, articles, transcripts, `llms.txt` snapshots directly in `raw/` (not in
`inbox/`). Agents read these to synthesize notes but **never edit them**. Dream
records each in `.agent/state.json` (`processed`) so it's ingested once, and
**keeps** the file (it's permanent ground truth, unlike the inbox).

---

If this repo is public, keep only public material here.
