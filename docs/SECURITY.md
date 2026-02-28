# Security Notes

OCM is a **local web UI** for managing OpenClaw. Security depends heavily on how you run OpenClaw and how you use Telegram.

## Recommended defaults

- **Run locally** and restrict host binding unless you intentionally expose it.
- Treat OpenClaw config as secrets: tokens, provider keys, account ids.
- Prefer separate workspaces for each agent/sub-agent.

## Telegram safety

Strongly recommended:

- **One Telegram group = one agent boundary** (context + purpose + workspace)
- Keep each agent group **private**: only you + the bot (and optionally your second account)
- Do **not** invite other people (cost + security risk)

Critical BotFather settings:
- Allow Groups = ON
- Group Privacy = OFF

## Sharing screenshots

If you share screenshots publicly:
- blur personal paths (e.g. `/Users/<name>/...`)
- blur Telegram group/peer IDs (e.g. `-100xxxxxxxxxx`)
- blur any tokens/keys if visible

This repo contains **redacted + annotated** screenshots under `docs/annotated-screenshots/`.
