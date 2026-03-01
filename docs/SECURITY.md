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

## Discord safety

Recommended defaults (especially for open-source / shared servers):

- Prefer **private channels / private threads** as agent boundaries.
- Use a strict **allowlist** of channels/threads the bot is allowed to respond in.
- Apply **least-privilege** Discord permissions when installing the bot (only what you need).
- Avoid running memory-enabled agents in public channels.

## Feishu / Lark (飞书) safety

Feishu is enterprise-oriented and typically requires more permission setup:

- Request the smallest permission scope possible for your app/bot.
- Treat group visibility as a security boundary (who can see the bot’s outputs).
- Prefer separate chats/spaces for different agents to reduce context bleed.

## WhatsApp note

WhatsApp is not a recommended target for sub-agent topology workflows. Constraints in bot/group automation make reliable multi-agent isolation + routing difficult.

## Sharing screenshots

If you share screenshots publicly:
- blur personal paths (e.g. `/Users/<name>/...`)
- blur Telegram group/peer IDs (e.g. `-100xxxxxxxxxx`)
- blur any tokens/keys if visible

This repo contains **redacted + annotated** screenshots under `docs/annotated-screenshots/`.
