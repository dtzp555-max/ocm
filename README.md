# OpenClaw Manager

> 🦀 A zero-dependency local web UI for managing [OpenClaw](https://github.com/OpenClaw-AI/openclaw) AI agents
>
> 零依赖本地 Web 管理界面，告别手动编辑配置文件

---

[中文](#中文说明) | [English](#english)

---

## 中文说明

### 简介

OpenClaw Manager 是一个运行在本地的轻量级 Web 管理界面，帮助你可视化管理 OpenClaw 的 AI 智能体（Agent）、模型配置和认证信息。**无需安装任何 npm 依赖**，只需要 Node.js 18+。

### 功能

- 🤖 **Agent 管理** — 新建子智能体（含向导）、内联切换模型、查看工作区文件、删除（自动备份）
- 🧠 **模型管理** — 修改全局主模型、编辑 Fallback 链、添加 / 删除自定义模型
- 🔑 **认证管理** — 支持 Anthropic、OpenAI、DeepSeek、Kimi、Groq、Mistral、Together、Perplexity、Google（OAuth）、GitHub Copilot（Device Flow）
- 🔄 **备份 & 回滚** — 每次写入前自动备份 `openclaw.json`，支持一键回滚
- 📋 **网关操作** — 重启 Gateway、实时查看日志
- 🖥️ **跨平台** — macOS / Linux / Windows

### 系统要求

- Node.js **>= 18**（[下载](https://nodejs.org/)）
- 已安装并配置好的 [OpenClaw](https://github.com/OpenClaw-AI/openclaw)

### 安装

```bash
git clone https://github.com/你的用户名/openclaw-manager.git
cd openclaw-manager
```

不需要 `npm install`，直接启动即可。

### 启动方式

#### 方式一：脚本启动（推荐）

```bash
# macOS / Linux
bash start.sh

# Windows
start.bat
```

#### 方式二：macOS 双击启动

在 Finder 中双击 `openclaw-manager.command`（首次可能需要在系统设置 → 隐私与安全 中允许）。

#### 方式三：npm

```bash
npm start
```

#### 方式四：直接运行

```bash
node openclaw-manager.js
```

启动后访问：`http://localhost:3333`

### 指定 OpenClaw 目录

程序按以下优先级查找 `openclaw.json`：

| 优先级 | 方式 |
|--------|------|
| 1 | `--dir` 命令行参数 |
| 2 | `OPENCLAW_DIR` 环境变量 |
| 3 | 同目录下的 `manager-config.json` |
| 4 | `~/.openclaw`（默认） |

**推荐：** 在项目目录下新建 `manager-config.json`，之后无需每次带参数：

```json
{ "dir": "~/.openclaw" }
```

`~` 在所有平台上会自动展开为当前用户主目录，无需手动填写完整路径。也可以写绝对路径：

| 系统 | 示例 |
|------|------|
| macOS / Linux | `{ "dir": "/Users/yourname/.openclaw" }` |
| Windows（正斜杠）| `{ "dir": "C:/Users/yourname/.openclaw" }` |
| Windows（反斜杠）| `{ "dir": "C:\\Users\\yourname\\.openclaw" }` |

或者直接指定：

```bash
# macOS / Linux
bash start.sh --dir ~/.openclaw

# Windows
start.bat --dir C:/Users/yourname/.openclaw
```

`manager-config.json` 已加入 `.gitignore`，不会被提交。

### 关于 Shell alias（可选）

如果想在终端随时一个命令启动，在 `~/.zshrc` 或 `~/.bashrc` 里加一行：

```bash
alias ocm="bash ~/openclaw-manager/start.sh"
```

然后 `source ~/.zshrc`，之后直接敲 `ocm` 即可。

---

## English

### What is this?

OpenClaw Manager is a lightweight, zero-dependency local web UI for [OpenClaw](https://github.com/OpenClaw-AI/openclaw). It lets you visually manage AI agents, model configurations, and auth profiles without editing JSON files by hand.

**No `npm install` needed** — just Node.js 18+.

### Features

- 🤖 **Agent management** — Create subagents (with wizard), switch models inline, browse workspace files, delete with auto-backup
- 🧠 **Model management** — Edit global primary model, manage fallback chain, add/remove custom models
- 🔑 **Auth management** — Anthropic, OpenAI, DeepSeek, Kimi (Moonshot), Groq, Mistral, Together, Perplexity, Google (OAuth), GitHub Copilot (Device Flow)
- 🔄 **Backup & rollback** — Auto-backup `openclaw.json` before every write, one-click restore
- 📋 **Gateway operations** — Restart gateway, tail logs in real time
- 🖥️ **Cross-platform** — macOS / Linux / Windows

### Requirements

- Node.js **>= 18** ([download](https://nodejs.org/))
- A working [OpenClaw](https://github.com/OpenClaw-AI/openclaw) installation

### Install

```bash
git clone https://github.com/your-username/openclaw-manager.git
cd openclaw-manager
# No npm install needed
```

### Start

```bash
# macOS / Linux
bash start.sh

# Windows
start.bat

# macOS: double-click openclaw-manager.command in Finder

# Or directly
node openclaw-manager.js
```

Then open `http://localhost:3333` in your browser.

### Directory configuration

The app resolves the OpenClaw config directory in this order:

1. `--dir` CLI argument
2. `OPENCLAW_DIR` environment variable
3. `manager-config.json` in the same folder as the script
4. `~/.openclaw` (default)

**Recommended:** create `manager-config.json` next to the script so you never need to pass flags:

```json
{ "dir": "/home/yourname/.openclaw" }
```

`manager-config.json` is in `.gitignore` and will not be committed.

### Optional: shell alias

```bash
# Add to ~/.zshrc or ~/.bashrc
alias ocm="bash ~/openclaw-manager/start.sh"
```

### Custom port

```bash
bash start.sh --port 8080
node openclaw-manager.js --port 8080
```

---

## License

MIT
