# OpenClaw Manager (OCM)

> A zero-dependency, single-file local dashboard for [OpenClaw](https://github.com/anthropics/openclaw) — manage sub-agents, run commands in a built-in CLI, and stop hand-editing JSON.

[中文说明](#中文说明)

---

## Quick Start (1 min)

```bash
# Install
git clone https://github.com/dtzp555-max/ocm.git
cd ocm

# Update (existing clone)
git pull --ff-only

# Run (no npm install needed)
bash start.sh   # macOS / Linux
start.bat       # Windows
```

Open [http://localhost:3333](http://localhost:3333).

## Why OCM

- **Single-file + zero dependency**: one `openclaw-manager.js`, no build step
- **Fast daily operations**: agent/model/auth/cron/backup in one local UI
- **Built-in terminal**: run `openclaw` commands with streaming output and presets

## Screenshots

### Landing Page
Choose between Sub-agent mode and Multi-agent mode. Switch language (EN / 中文) anytime.

<!-- Screenshot removed (possible sensitive IDs) -->

### Agent Management
View all agents (main + sub-agents) at a glance. Each card shows model, group binding, and workspace path. Switch models inline, browse files, or delete with auto-backup.

<!-- Screenshot removed (contained sensitive binding IDs) -->

### Built-in CLI Terminal
Run any openclaw command with real-time streaming output. The terminal panel sits at the bottom of the page and expands on demand.

<!-- Screenshot removed (possible sensitive IDs) -->

<details>
<summary>More screenshots</summary>

### New Subagent Wizard
4-step guided wizard to create a sub-agent: basic info → model → personality & memory → confirm. Fully bilingual.

<!-- Screenshot removed (contained sensitive binding IDs) -->

### Model Selector
Rich model dropdown grouped by provider — GitHub Copilot, Anthropic, OpenAI, Google, DeepSeek, Kimi, Groq, Mistral, Together, plus your custom models.

<!-- Screenshot removed (possible sensitive IDs) -->

### Actions Menu
Quick access to gateway operations, backups, health checks, and directory management. Use **"Switch OpenClaw Dir"** to point OCM to your OpenClaw config on first setup.

<!-- Screenshot removed (possible sensitive IDs) -->

### Cron Job Management
View, add, enable/disable, and manually trigger openclaw-related cron tasks. Integrates with NAS backup schedules.

<!-- Screenshot removed (possible sensitive IDs) -->

Preset command menu with built-in commands and your personal favorites — one click to run.

<!-- Screenshot removed (possible sensitive IDs) -->

Command output streams in real-time. Star frequently used commands for quick access, or use the Manage button to organize favorites.

<!-- Screenshot removed (possible sensitive IDs) -->
</details>

## Features

- **Agents & Workspace** — Create sub-agents, switch models inline, and browse/edit workspace files
- **Models & Auth** — Manage primary/fallback models and follow provider auth guides
- **Ops Panel** — Restart gateway, view logs, run health checks, and switch OpenClaw directory
- **Stats & Cron** — Token/cost stats from `gateway.log` plus cron task management
- **Backups** — Local backup/rollback and NAS backup (SFTP/rsync)
- **Built-in CLI** — Real-time command terminal with presets, favorites, and tab completion

## Requirements

- Node.js >= 18 ([download](https://nodejs.org/))
- A working [OpenClaw](https://github.com/anthropics/openclaw) installation

Install/update/run commands are in **Quick Start (1 min)** above.

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

### 1 分钟上手

```bash
# 首次安装
git clone https://github.com/dtzp555-max/ocm.git
cd ocm

# 已安装后更新
git pull --ff-only

# 运行（无需 npm install）
bash start.sh   # macOS / Linux
start.bat       # Windows
```

访问 [http://localhost:3333](http://localhost:3333)。

### 界面预览

#### 模式选择
<!-- Screenshot removed (possible sensitive IDs) -->

#### Agent 管理
<!-- Screenshot removed (contained sensitive binding IDs) -->

#### 内置 CLI 终端
底部终端面板，支持实时流式输出、预设命令、收藏夹、Tab 补全。

<!-- Screenshot removed (possible sensitive IDs) -->

<details>
<summary>更多截图</summary>

#### 新建向导
<!-- Screenshot removed (contained sensitive binding IDs) -->

#### 模型选择 & 操作菜单
首次安装后，通过 **Actions → Switch OpenClaw Dir** 指向你的 OpenClaw 配置目录即可开始使用。

<!-- Screenshot removed (possible sensitive IDs) -->
<!-- Screenshot removed (possible sensitive IDs) -->

#### Cron 定时任务
<!-- Screenshot removed (possible sensitive IDs) -->

<!-- Screenshot removed (possible sensitive IDs) -->
<!-- Screenshot removed (possible sensitive IDs) -->
</details>

### 功能一览

- **Agent 与 Workspace** — 新建子智能体、内联切换模型、浏览/编辑工作区文件
- **模型与认证** — 管理主模型/Fallback 链，按引导完成各 Provider 认证
- **运维操作面板** — 重启网关、查看日志、健康检查、切换 OpenClaw 目录
- **统计与计划任务** — 从 `gateway.log` 汇总 Token/费用，并管理 Cron 任务
- **备份能力** — 本地备份回滚 + NAS 远程备份（SFTP/rsync）
- **内置 CLI 终端** — 实时输出、预设命令、收藏、Tab 补全

安装/更新/运行命令见上方 **1 分钟上手**。

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
