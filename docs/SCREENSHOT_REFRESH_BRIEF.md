# OCM Screenshot Refresh Brief

Goal: refresh only the highest-value README screenshots first, not every screenshot.

## Redaction rules
Always hide or blur:
- Telegram / Discord IDs
- bindings / peer IDs / thread IDs
- local filesystem paths containing Tao's name
- account labels if they expose personal identifiers
- anything that looks like a secret/token

## Priority 1 screenshots

### 1) Dashboard hero
Purpose:
- show OCM as a real control panel
- support the README first-run / health story

Wanted state:
- Dashboard page open
- gateway looks healthy if possible
- cards readable
- top bar clean
- no obvious warning/noise unless it helps credibility

Frame guidance:
- browser window wide enough to show full dashboard naturally
- keep top navigation visible
- avoid cropping too tightly

### 2) Agents page
Purpose:
- show the core product value: visible agent topology / structure

Wanted state:
- main agent + several sub-agents visible
- structure easy to understand at a glance
- avoid visual clutter where possible
- keep model selectors/buttons visible, but not the focus

Frame guidance:
- enough width to show the tree clearly
- IDs and personal paths redacted

### 3) CLI / Terminal page
Purpose:
- show that OCM is not only a viewer; it can operate OpenClaw too

Wanted state:
- built-in terminal open
- a real command visible (recommended: `openclaw status` or `openclaw doctor`)
- real output visible
- do not use tutorial arrows / annotation bubbles

Frame guidance:
- include command input and some output
- avoid empty terminal state
- redact paths / personal names

## Priority 2 screenshots
- Actions menu
- Backup / rollback
- Channels
- Models
- Auth
- Cron
- Stats

## Notes
- Existing `actions.jpg` is already strong and can likely stay for now.
- Existing `dashboard.jpg` and `agents.jpg` are usable, but can be improved later.
- Existing `cli.jpg` should ideally be replaced with a real output screenshot.
