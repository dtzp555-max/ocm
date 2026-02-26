# OpenClaw Manager (OCM)

A zero-dependency, single-file web dashboard for [OpenClaw](https://github.com/anthropics/openclaw). Manage agents, monitor token usage, and run commands — all from your browser, no `npm install` required.

[中文说明](#中文说明)

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

## Features

**Agent Management** — Add main agents and sub-agents through a guided setup flow. View all agents in a tree structure with model selection, workspace browsing, and inline configuration.

**Usage Statistics** — Real token usage data parsed directly from OpenClaw session files. Breakdown by model, agent, and day with a visual chart.

**Model & Auth** — Configure models from your registered provider list. Follow built-in guides for provider authentication setup.

**Built-in CLI** — Run any `openclaw` command with real-time streaming output. Preset commands, favorites, and tab completion included.

**Ops Panel** — Restart gateway, view logs, run health checks, manage backups (local + NAS via SFTP/rsync), and handle cron tasks.

**Bilingual UI** — English and Chinese interface with one-click language switching.

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

### 配置

启动脚本自动检测 `~/.openclaw` 目录。如需指定其他路径：

```bash
bash start.sh --dir /path/to/.openclaw --port 8080
```

也可手动创建 `manager-config.json`：

```json
{ "dir": "~/.openclaw" }
```
