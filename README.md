# OpenClaw Manager (OCM)

> A zero-dependency, single-file local dashboard for [OpenClaw](https://github.com/anthropics/openclaw) — manage sub-agents, run commands in a built-in CLI, and stop hand-editing JSON.

[中文说明](#中文说明)

---

## What is this?

OCM is a lightweight local dashboard for OpenClaw that helps you:

- **Manage sub-agents fast** (create with a wizard, switch models inline)
- **Run OpenClaw commands inside the app** via a built-in CLI terminal
- **Stop hunting for CLI flags / docs** with curated command presets + favorites

Everything ships as **a single `.js` file** with zero npm dependencies — just Node.js 18+.

## Screenshots

### Landing Page
Choose between Sub-agent mode and Multi-agent mode. Switch language (EN / 中文) anytime.

![Landing Page](screenshots/landing.png)

### Agent Management
View all agents (main + sub-agents) at a glance. Each card shows model, group binding, and workspace path. Switch models inline, browse files, or delete with auto-backup.

![Agents](screenshots/agents.png)

### New Subagent Wizard
4-step guided wizard to create a sub-agent: basic info → model → personality & memory → confirm. Fully bilingual.

![New Subagent](screenshots/subagents.png)

### Model Selector
Rich model dropdown grouped by provider — GitHub Copilot, Anthropic, OpenAI, Google, DeepSeek, Kimi, Groq, Mistral, Together, plus your custom models.

![Models](screenshots/models.png)

### Actions Menu
Quick access to gateway operations, backups, health checks, and directory management. Use **"Switch OpenClaw Dir"** to point OCM to your OpenClaw config on first setup.

![Actions](screenshots/actions.png)

### Cron Job Management
View, add, enable/disable, and manually trigger openclaw-related cron tasks. Integrates with NAS backup schedules.

![Cron](screenshots/cron.png)

### Built-in CLI Terminal
Run any openclaw command with real-time streaming output. The terminal panel sits at the bottom of the page and expands on demand.

![CLI Overview](screenshots/cli1.png)

Preset command menu with built-in commands and your personal favorites — one click to run.

![CLI Presets](screenshots/cli3.png)

Command output streams in real-time. Star frequently used commands for quick access, or use the Manage button to organize favorites.

![CLI Detail](screenshots/cli2.png)

## Features

- **Agent Management** — Create sub-agents (with wizard), switch models inline, browse & edit workspace files, delete with auto-backup
- **Model Selection** — Change global primary model, edit fallback chain
- **Auth Guide** — Step-by-step instructions for configuring each provider (Anthropic, OpenAI, DeepSeek, Google, GitHub Copilot, etc.)
- **Token Usage Stats** — Parse `gateway.log` for token usage, view cost breakdown by model and day
- **Cron Job Management** — View, add, enable/disable, and trigger openclaw-related cron tasks
- **Workspace File Browser** — Browse all agent workspace files, read-only by default, editable on demand
- **Backup & Rollback** — Auto-backup before every write, one-click restore from any snapshot
- **NAS Backup** — SFTP/rsync backup to NAS with legacy SSH cipher compatibility
- **Built-in CLI Terminal** — Run openclaw commands with real-time streaming output, presets, tab completion
- **Health Badge** — Auto-run `openclaw doctor` and show warnings in the header
- **Bilingual UI** — English / 中文, switchable at runtime
- **Cross-platform** — macOS / Linux / Windows

## Requirements

- Node.js >= 18 ([download](https://nodejs.org/))
- A working [OpenClaw](https://github.com/anthropics/openclaw) installation

## Quick Start

```bash
git clone https://github.com/dtzp555-max/ocm.git
cd ocm
# No npm install needed

# macOS / Linux
bash start.sh

# Windows
start.bat
```

Then open http://localhost:3333 in your browser.

### First Run

On first launch, the start script auto-detects `~/.openclaw` and creates a `manager-config.json` for you. If your OpenClaw config is elsewhere, use **Actions → Switch OpenClaw Dir** in the UI to point to the correct path.

### macOS Double-click

Double-click `OpenClaw Manager.app` in Finder. On first launch, you may need to allow it in System Settings → Privacy & Security.

### Custom Port

```bash
bash start.sh --port 8080
```

## Configuration

The app locates your OpenClaw config directory in this order:

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

`~` expands to your home directory on all platforms. `manager-config.json` is in `.gitignore` and won't be committed.

## Optional: Shell Alias

```bash
# Add to ~/.zshrc or ~/.bashrc
alias ocm="bash ~/path/to/ocm/start.sh"
```

## Project Structure

```
ocm/
├── openclaw-manager.js          ← The entire app (server + frontend, single file)
├── start.sh                     ← macOS/Linux start script (auto-detect Node, port, config)
├── start.bat                    ← Windows start script
├── OpenClaw Manager.app/        ← macOS Finder double-click launcher
├── screenshots/                 ← README screenshots
├── manager-config.json          ← Local config (gitignored)
├── package.json
├── DEVLOG.md                    ← Development log
└── README.md
```

## Tech Stack

- **Runtime**: Node.js built-in modules only (`http`, `fs`, `path`, `os`, `child_process`)
- **Frontend**: Vanilla HTML/CSS/JS embedded in a template literal — no build step, no framework
- **Architecture**: Single-file, zero-dependency, runs anywhere Node.js runs

## Support / Donate

If OCM saves you time, consider starring the repo or sponsoring development.

- GitHub Sponsors: *(add link when ready)*

## License

MIT

---

## 中文说明

### 简介

OpenClaw Manager 是一个零依赖的本地 Web 管理界面，用于可视化管理 [OpenClaw](https://github.com/anthropics/openclaw) AI 智能体。所有代码合并在一个 `.js` 文件中，只需要 Node.js 18+，不需要 `npm install`。

### 界面预览

#### 模式选择
![Landing](screenshots/landing.png)

#### Agent 管理 & 新建向导
![Agents](screenshots/agents.png)
![New Subagent](screenshots/subagents.png)

#### 模型选择 & 操作菜单
首次安装后，通过 **Actions → Switch OpenClaw Dir** 指向你的 OpenClaw 配置目录即可开始使用。

![Models](screenshots/models.png)
![Actions](screenshots/actions.png)

#### Cron 定时任务
![Cron](screenshots/cron.png)

#### 内置 CLI 终端
底部终端面板，支持实时流式输出、预设命令、收藏夹、Tab 补全。

![CLI](screenshots/cli1.png)
![CLI Presets](screenshots/cli3.png)
![CLI Detail](screenshots/cli2.png)

### 功能一览

- **Agent 管理** — 新建子智能体（含向导）、内联切换模型、查看/编辑工作区文件、删除（自动备份）
- **模型选择** — 修改全局主模型、编辑 Fallback 链
- **认证引导** — 各 Provider 分步操作指引 + 一键复制 CLI 命令
- **Token 用量统计** — 解析网关日志，按模型/天汇总 Token 和费用
- **Cron 任务管理** — 查看、添加、启用/禁用、手动触发 openclaw 相关定时任务
- **Workspace 文件浏览器** — 查看所有工作区文件，默认只读，可切换编辑
- **备份 & 回滚** — 每次写入前自动备份，一键回滚
- **NAS 备份** — SFTP/rsync 远程备份，兼容老设备 SSH 加密
- **内置 CLI 终端** — 实时流式输出、预设命令、Tab 补全
- **健康检查** — 自动运行 `openclaw doctor`，Header 显示状态徽章
- **中英双语** — 运行时随时切换
- **跨平台** — macOS / Linux / Windows

### 快速开始

```bash
git clone https://github.com/dtzp555-max/ocm.git
cd ocm

# macOS / Linux
bash start.sh

# Windows
start.bat
```

访问 http://localhost:3333

### 首次运行

启动脚本会自动检测 `~/.openclaw` 目录并创建 `manager-config.json`。如果你的 OpenClaw 配置在其他位置，进入界面后点击 **Actions → Switch OpenClaw Dir** 切换即可。

### 指定 OpenClaw 目录

程序按以下优先级查找配置：

1. `--dir` 命令行参数
2. `OPENCLAW_DIR` 环境变量
3. 同目录下的 `manager-config.json`
4. `~/.openclaw`（默认）

也可以手动创建 `manager-config.json`：

```json
{ "dir": "~/.openclaw" }
```

`~` 在所有平台自动展开为用户主目录。

### Shell 别名（可选）

```bash
# 加到 ~/.zshrc 或 ~/.bashrc
alias ocm="bash ~/path/to/ocm/start.sh"
```
