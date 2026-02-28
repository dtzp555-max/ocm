# OpenClaw Manager (OCM)

A zero-dependency, single-file web dashboard for [OpenClaw](https://github.com/anthropics/openclaw). Manage agents, monitor token usage, and run commands — all from your browser, no `npm install` required.

[中文说明](#中文说明) · [中文使用说明（含截图）](docs/USAGE_GUIDE.zh-CN.md) · [English Guide (with screenshots)](docs/USAGE_GUIDE.en.md)

---

## Quick Start

```bash
# Clone
git clone https://github.com/dtzp555-max/ocm.git
cd ocm

# Run (no npm install needed)
bash start.sh        # macOS / Linux
start.bat            # Windows

# Update
git pull --ff-only
```

Open [http://localhost:3333](http://localhost:3333) in your browser. For remote access, use `bash start.sh --host 0.0.0.0`.
## Docs

- English guide: docs/USAGE_GUIDE.en.md
- 中文使用说明: docs/USAGE_GUIDE.zh-CN.md
- FAQ: docs/FAQ.md
- Security notes: docs/SECURITY.md
- Changelog: docs/CHANGELOG.md


## Features

**Screenshots** — Redacted UI walkthrough (no personal paths, no Telegram IDs):

![](docs/redacted-screenshots/dashboard.jpg)

![](docs/redacted-screenshots/agents.jpg)

![](docs/redacted-screenshots/channels.jpg)

![](docs/redacted-screenshots/models.jpg)

![](docs/redacted-screenshots/auth.jpg)

![](docs/redacted-screenshots/stats.jpg)

![](docs/redacted-screenshots/cron.jpg)


**Agent Management** — Add main agents and sub-agents through a guided setup flow. View all agents in a tree structure with model selection, workspace browsing, and inline configuration.

**Usage Statistics** — Real token usage data parsed directly from OpenClaw session files. Breakdown by model, agent, and day with a visual chart.

**Model & Auth** — Configure models from your registered provider list. Follow built-in guides for provider authentication setup.

**Built-in CLI** — Run any OpenClaw CLI command with real-time streaming output. Includes tab completion and saved favorites.

![](docs/redacted-screenshots/cli.jpg)

**Ops Panel** — Restart gateway, view logs, run health checks, manage backups (local + NAS via SFTP/rsync), and handle cron tasks.

**Bilingual UI** — English and Chinese interface with one-click language switching.

## What's New (v0.7.x)

- **Dashboard redesign**: circular CPU/RAM/DISK gauges + system/gateway/agent overview, with optional auto-refresh.
- **Sub-agent creation flow**: step-by-step Telegram guide (BotFather → group → get group ID → fill form), with explicit safety warnings.
- **Telegram allowlist helper**: optional “Your Telegram User ID” field can auto-append to `channels.telegram.allowFrom`.
- **Model dropdown = real CLI output**: selectors are sourced from `openclaw models list` (with a warning if parsing fails).
- **Cache-busting**: response headers + version checks help prevent stale frontend after updates.
- **Setup page EN localization**: first-run directory selection page is fully bilingual.


## Telegram Workflow & Safety

OCM is designed primarily for **Telegram-based OpenClaw workflows**:

- Bind Telegram groups to one or more main agents, then create sub-agents under each tree
- Keep each agent's context isolated via independent `workspace`, `SOUL.md`, and `MEMORY.md`
- OCM mainly helps you **safely update `openclaw.json`** via UI instead of manual editing
- Recommended for users who already have basic OpenClaw CLI experience (`onboard`, auth, gateway logs)

Critical Telegram settings:

- In BotFather, keep **Allow Groups = ON**
- In BotFather, set **Group Privacy = OFF**
- For each agent group, keep it private: **only you + that agent/sub-agents**
- Do **not** invite other people to these groups (cost and security risk)

## Requirements

- Node.js 18+ ([download](https://nodejs.org/))
- A working [OpenClaw](https://github.com/anthropics/openclaw) installation

## Configuration

On first launch, OCM auto-detects `~/.openclaw` and creates a local `manager-config.json`. If your OpenClaw config is elsewhere, use **Actions → Switch OpenClaw Dir** or specify it directly:

```bash
bash start.sh --dir /path/to/.openclaw --port 8080
```

Detection priority:

| Priority | Method |
|----------|--------|
| 1 | `--dir` CLI argument |
| 2 | `OPENCLAW_DIR` environment variable |
| 3 | `manager-config.json` in the same folder |
| 4 | `~/.openclaw` (default) |

You can also create `manager-config.json` manually:

```json
{ "dir": "~/.openclaw" }
```

`manager-config.json` is gitignored and won't be committed.

## Remote Access

By default OCM binds to `0.0.0.0` (all interfaces). Access it from another device on your LAN using the IP shown at startup. To restrict to localhost only:

```bash
bash start.sh --host 127.0.0.1
```

## Shell Alias (Optional)

```bash
# Add to ~/.zshrc or ~/.bashrc
alias ocm="bash ~/path/to/ocm/start.sh"
```

## Project Structure

```
ocm/
├── openclaw-manager.js    ← Entire app (server + frontend, single file)
├── start.sh               ← macOS/Linux launcher (auto-detect, port conflict handling)
├── start.bat              ← Windows launcher
├── OpenClaw Manager.app/  ← macOS Finder double-click launcher
├── manager-config.json    ← Local config (gitignored)
├── DEVLOG.md              ← Development log
└── README.md
```

## Tech Stack

- **Runtime**: Node.js built-in modules only (`http`, `fs`, `path`, `os`, `child_process`)
- **Frontend**: Vanilla HTML/CSS/JS embedded in a template literal — no build step, no framework
- **Architecture**: Single-file, zero-dependency, runs anywhere Node.js runs

## License

MIT

---

## 中文说明

OpenClaw Manager 是一个零依赖的本地 Web 管理界面，用于可视化管理 [OpenClaw](https://github.com/anthropics/openclaw) AI 智能体。所有代码在一个 `.js` 文件中，只需 Node.js 18+，不需要 `npm install`。

### 快速开始

```bash
git clone https://github.com/dtzp555-max/ocm.git
cd ocm
bash start.sh        # macOS / Linux
start.bat            # Windows
```

访问 [http://localhost:3333](http://localhost:3333)。远程访问请使用 `bash start.sh --host 0.0.0.0`。

### 功能

- **Agent 管理** — 添加主 Agent 和子 Agent，树状结构查看，内联切换模型，浏览工作区文件
- **使用统计** — 从 OpenClaw 会话文件解析真实 Token 用量，按模型/Agent/日期维度展示
- **模型与认证** — 管理注册模型列表，内置 Provider 认证引导
- **内置终端** — 实时流式输出，预设命令，收藏夹，Tab 补全
- **运维面板** — 重启网关、查看日志、健康检查、本地/NAS 备份、Cron 任务管理
- **双语界面** — 中英文一键切换

### Telegram 场景与安全提示

OCM 主要面向 **Telegram 场景**：

- 通过群组绑定主 Agent，并在每条树下管理多个 Sub-Agent
- 让每个 Agent 拥有独立 `workspace`、`SOUL.md`、`MEMORY.md`
- 通过可视化方式更新 `openclaw.json`，减少手动改配置风险
- 建议使用者已具备基础 OpenClaw CLI 操作经验（如 `onboard`、认证、查看网关日志）

关键安全设置（务必确认）：

- BotFather 里 **Allow Groups = ON**
- BotFather 里 **Group Privacy = OFF**
- 每个 Agent 群组只保留“你自己 + 对应 Agent/Sub-Agent”
- 不要邀请其他人进组（会带来安全和 API 费用风险）

### 配置

启动脚本自动检测 `~/.openclaw` 目录。如需指定其他路径：

```bash
bash start.sh --dir /path/to/.openclaw --port 8080
```

也可手动创建 `manager-config.json`：

```json
{ "dir": "~/.openclaw" }
```
