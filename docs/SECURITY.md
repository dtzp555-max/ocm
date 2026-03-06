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


## Discord safety

Recommended defaults (especially for shared/community servers):

- Prefer **private channels / private threads** as agent boundaries
- Use a strict **allowlist** of channels/threads the bot may respond in
- Avoid giving memory-enabled or high-privilege agents broad public exposure
- Prefer least-privilege Discord permissions for the bot

## Feishu / Lark safety

Feishu is more enterprise-oriented and usually needs stricter permission design:

- Request the smallest permission scope possible
- Treat chat/group visibility as a security boundary
- Prefer separate chats/spaces for different agents to reduce context bleed

## WhatsApp note

WhatsApp is not a recommended target for sub-agent topology workflows. Constraints in bot/group automation make reliable multi-agent isolation and routing harder.
