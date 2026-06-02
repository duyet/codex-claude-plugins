# Reference: installing & configuring the `sag` CLI

`sag` is the ElevenLabs text-to-speech CLI this plugin shells out to. It is a
separate tool — install and authenticate it before sag-notify can speak.

- Project: https://github.com/steipete/sag
- Homebrew tap: `steipete/tap`

## Install

```bash
# macOS / Linux (Homebrew)
brew install steipete/tap/sag

# verify
sag --version          # e.g. sag 0.3.0
which sag              # e.g. /opt/homebrew/bin/sag
```

`sag` plays audio via `afplay` on macOS, or `oto` elsewhere (override with
`--player` / `SAG_PLAYER`).

## Authenticate

`sag` needs an ElevenLabs API key (create one at https://elevenlabs.io → Profile → API Keys).
It is read, in order of precedence:

1. `--api-key <key>` flag
2. `ELEVENLABS_API_KEY` environment variable  ← recommended
3. `--api-key-file <path>` flag, or `ELEVENLABS_API_KEY_FILE` env

Put the key in your shell environment so every process (including hook shells) inherits it:

```bash
# zsh: ~/.zshenv is sourced for NON-interactive shells too (unlike ~/.zshrc) —
# important because hooks run in non-interactive shells.
echo "export ELEVENLABS_API_KEY='your-key'" >> ~/.zshenv

# bash
echo "export ELEVENLABS_API_KEY='your-key'" >> ~/.bash_profile
```

Never paste the key into a shared file or commit it. To verify auth works:

```bash
sag voices            # lists voices your key can use
sag "hello"           # should play audio
```

## Environment variables `sag` understands

| Variable | Purpose |
|----------|---------|
| `ELEVENLABS_API_KEY` | API key |
| `ELEVENLABS_API_KEY_FILE` | Path to a file containing the key |
| `ELEVENLABS_VOICE_ID` | Default voice |
| `SAG_PLAYER` | Audio backend: `auto`, `afplay`, `oto` |
| `SAG_TIMEOUT` | Max generation time (0 disables) |

## Models

| Model id | Notes |
|----------|-------|
| `eleven_v3` | Default; expressive; inline audio tags; wants 250+ chars |
| `eleven_multilingual_v2` | Stable; SSML `<break>` support |
| `eleven_flash_v2_5` | Fast/cheap; multilingual; this plugin's default |
| `eleven_turbo_v2_5` | Low latency; balanced |

Run `sag prompting` for model-specific prompting tips.

## Voices and the free-tier 402

`sag voices` lists voices by category: `premade`, `professional`, `cloned`.

- **`premade`** voices work on the **free** ElevenLabs tier.
- **`professional`/library** voices return **`402 Payment Required`** on free plans.
  Use a premade voice or upgrade.

Pick any premade voice id from `sag voices` and set it as the plugin's `voice_id`.

## How this plugin uses `sag`

Claude (via the sag-voice skill) calls:

```bash
sag speak --model-id <model_id> --voice-id <voice_id> "<text>"
```

with `model_id` / `voice_id` taken from the plugin config (`config.default.json`,
overridable in `~/.config/sag-notify/config.json`). The API key is resolved
from the environment, or from an optional `key_file` you set in your config. See the
main `SKILL.md` and `/sag-notify:setup` for the plugin side.
