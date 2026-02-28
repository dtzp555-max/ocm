# Contributing (OCM)

This repo is optimized for fast iteration and safe maintenance.

## Workflow (PM + Codex)

Default rule:

- Codex implements changes on a **new branch** and opens a **PR**.
- Xiao Qiang (PM) reviews + runs local smoke tests.
- Tao approves.
- Only after explicit approval, we merge.

Fast-path (small changes):

- For small doc/copy/layout fixes, Tao allows **auto-merge after PM verification** (tests/smoke pass).
- PM must still send Tao a short completion note with the PR link and summary.


## Versioning

- Single source of truth:
  - `package.json#version`
  - `openclaw-manager.js` → `APP_VERSION`
- When bumping a version, update **both** in the same commit.
- Prefer **semver-ish**: `MAJOR.MINOR.PATCH` (e.g. `0.8.2`).

## Language policy (Docs + UI)

- **DEVLOG.md must be English-only.**
- UI:
  - English mode should not show Chinese strings (except user-provided content).
  - Chinese mode can be fully Chinese.
- When adding new UI strings, ensure both locales are updated.

## README policy

- Keep the README homepage **short**.
- Screenshots should be grouped (e.g. in a collapsible gallery) to avoid long scroll.
- The “Features” section should be **complete** and reflect actual UI capabilities.

## Screenshots (redaction)

- Store public screenshots under: `docs/redacted-screenshots/`
- Redact sensitive info:
  - local username/path fragments
  - Telegram peer IDs
  - any tokens/keys
- Prefer **English UI** screenshots.
- Prefer clean crops (avoid arrows/annotations unless truly necessary).

## Text style

- Be concrete and user-focused.
- Prefer consistent naming:
  - “Remote backup setup” (not “NAS backup setup”)
  - “Backups / Rollback” for restore/snapshot functionality

## PR checklist

- [ ] Description includes: what/why/how
- [ ] If UI changed: include screenshots
- [ ] Version updated when needed
- [ ] English UI audited (no stray Chinese)
- [ ] `DEVLOG.md` updated (English-only)
