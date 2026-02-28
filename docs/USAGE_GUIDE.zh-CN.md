# OCM 功能使用说明（含截图）

> 面向：已经在本机安装并跑通 OpenClaw 的用户（至少会用 `openclaw status` / `openclaw gateway logs`）
>
> 目标：用 **OpenClaw Manager (OCM)** 把“创建 Agent / Sub-Agent、绑定 Telegram 群、管理模型/认证、看用量、看 cron”这套流程做成可视化、可回溯、低风险。

---

## 0) 先说痛点：为什么要用 OCM

### 0.1 创建/维护 Agent 的典型痛点

1. **改 `openclaw.json` 容易改错**
   - 字段多、层级深、容易手滑覆盖 token / accountId / bindings。
   - 一次写错可能导致多个 Agent 全挂。

2. **Sub-Agent 的边界和“谁在用哪个 bot token”不直观**
   - 多 Bot / 多 agent / 多群组绑定时，光靠肉眼看 JSON 很难确认拓扑结构是否正确。

3. **模型选择很容易“写了一个不存在的 model-id”**
   - provider/model-id 拼错、或 provider 侧不支持，最后表现就是 Agent 变慢/报错/一直 typing。

4. **统计用量和排查问题耗时**
   - 需要翻 session JSONL / gateway logs 才能知道谁在烧 token、哪里失败。

OCM 的定位：**把配置变更“可视化 + 可检查 + 可回滚（配合备份）”，并把常用运维入口集中起来。**

---

## 1) 为什么用 Telegram group 来建 Sub-Agent 最合适

> 这里讨论的是 OpenClaw 的一种非常实用的工作方式：**“一个 Telegram 群 = 一个 Agent 的工作空间/人格/上下文边界”**。

### 1.1 Telegram group 方案的优势

1. **边界天然清晰**
   - 每个 Agent 只在自己的群里说话，和其他 Agent 隔离。

2. **上下文可控**
   - 一个群的聊天记录就是该 Agent 的输入流；不会和别的任务混在一起。

3. **并发与分工自然**
   - 主 Agent 负责总控/派工，Sub-Agent 负责专项：技术宅/旅行/理财/翻译……

4. **可审计**
   - 群里发生了什么一眼可见；出问题也能定位是哪条消息触发。

### 1.2 为什么“群必须私密”（安全与成本）

- 强烈建议：**每个 Agent 群只留你自己 + 对应 bot（+ 必要时的另一个你自己的账号）**。
- 不要拉别人进来：
  - 成本：别人一句话就触发 token 消耗
  - 安全：可能诱导泄露信息/触发危险操作

---

## 2) 启动与进入 OCM

### 2.1 启动（macOS）

在 OCM 目录：

```bash
bash start.sh
```

默认访问：<http://localhost:3333>

> 需要限制只能本机访问：`bash start.sh --host 127.0.0.1`

### 2.2 Dashboard（先看健康状态）

建议第一步先看 Dashboard，确认：
- 机器资源（CPU/RAM/DISK）
- OpenClaw gateway 是否 Running
- Agents 数量

截图示例：

![](redacted-screenshots/dashboard.jpg)

---

## 3) 创建主 Agent（Main Agent / 独立 Bot）

> 你的 `main` 一般是默认存在的；这里重点讲“新增一个 **拥有独立 Telegram bot 的主 Agent**”。

### 3.1 BotFather 侧准备（必须）

1) 创建 bot
- 在 Telegram 找 **BotFather**
- 发送 `/newbot` → 按提示创建 → 拿到 bot token

2) 允许加群
- BotFather → 你的 bot → Bot Settings
- **Allow Groups = ON**

3) 关闭群隐私（非常关键）
- BotFather → 你的 bot → Bot Settings → Group Privacy
- **Group Privacy = OFF**

> 如果 Group Privacy 没关，bot 在群里看不到普通消息，会表现成“经常 typing 但没输出 / 没反应”。

### 3.2 在 OCM 添加主 Agent

进入 **Agents** 页面：

![](redacted-screenshots/agents.jpg)

点击 `+ Add Agent`，按表单填写：
- Agent id / name
- workspace 路径（建议独立目录）
- 选择模型（下拉来自 `openclaw models list`，更不容易选错）
- 填入刚拿到的 bot token

保存后，OCM 会把这颗主 Agent 写进 `openclaw.json`，并把 bot token 绑定到对应 `accountId`。

---

## 4) 创建 Sub-Agent（最常用）

### 4.1 为什么 Sub-Agent 要用“新群”

- 让每个 Sub-Agent 有自己独立的对话上下文、任务边界
- 出问题直接在该群排查，不污染主 Agent 的对话

### 4.2 Sub-Agent 创建流程（逐步）

进入 **Agents** 页面 → 点击 `+ Add Sub-Agent`，按引导做：

#### Step 1：建 Telegram 群
- 新建群（私密）
- 群里只加：你自己 + 对应的 bot

#### Step 2：拿到群 ID（Peer ID / Group ID）
OpenClaw 通常会在 gateway 日志里打印群的 peer id。

常见拿法：
```bash
openclaw gateway logs --follow
```
然后在 Telegram 群里随便发一句话，观察日志。

> 你会看到类似 `-100xxxxxxxxxx` 这样的 group id。

#### Step 3：回到 OCM 填表
- Parent Agent（选择共享哪个 bot/account）
- 填 Group ID
- workspace（建议单独目录）
- 选择模型

#### Step 4：写 allowlist（推荐）
如果你启用了 Telegram 的 allowlist（例如 `channels.telegram.allowFrom`），
OCM 的表单里可以填 “Your Telegram User ID”，让它自动把你的 user id 加进去，避免 DM/群消息被拒。

---

## 5) 绑定检查（Channels 页）

进入 **Channels**：

![](redacted-screenshots/channels.jpg)

这里能一眼看到：
- 哪个 agent 绑定了哪个 Telegram peer（群）
- main 的“兜底绑定”（any）是否存在

> 如果某个 Sub-Agent 绑定错群/丢 binding，最直观的就是在这里对不上。

---

## 6) 模型管理（Models 页）

进入 **模型**：

![](redacted-screenshots/models.jpg)

关键点：
- 主模型（primary）和 fallback 链
- 下拉列表来自 `openclaw models list`（能减少“选了不存在模型”的问题）

---

## 7) 认证管理（Auth 页）

进入 **认证**：

![](redacted-screenshots/auth.jpg)

这里主要用来：
- 看当前有哪些 provider profile
- 排查某个 provider 是否过期/缺 token

---

## 8) 用量统计（Stats 页）

进入 **Stats**：

![](redacted-screenshots/stats.jpg)

你可以按：
- 按模型聚合
- 按 Agent 聚合
- 按天趋势

> OCM 是从 OpenClaw 的 session JSONL 里解析真实 usage（比“看日志猜”靠谱）。

---

## 9) CLI 终端（内置）

OCM 内置一个 CLI 面板，用来直接运行 OpenClaw 命令（例如：`openclaw status`、`openclaw gateway logs --follow`、`openclaw doctor`）。

入口：点击顶部导航栏的 **⌨️ 终端**，或使用页面底部的 CLI 区域。

功能要点：
- **Tab 补全**：输入命令时按 Tab 进行补全/提示（适合 `openclaw ...` 子命令）
- **常用命令**：可从下拉选择，一键填充常用命令模板
- **收藏（Favorites）**：把常用命令保存为收藏，后续一键执行
- **实时输出**：执行后会流式显示 stdout/stderr，方便排错

截图示例：

![](redacted-screenshots/cli.jpg)

![](redacted-screenshots/cli-output.jpg)

## 9) Actions 菜单（运维快捷入口）

右上角 **⚡ Actions** 下拉菜单提供常用运维操作：
- Restart Gateway（重启网关）
- Live Logs（实时日志）
- Manual Backup / Backups & Rollback（备份/回滚）
- NAS Backup Setup（NAS 备份配置）
- Health Check（健康检查）
- Open Config Dir / Switch OpenClaw Dir（打开/切换配置目录）

截图示例：

![](redacted-screenshots/actions.jpg)

## 9) Cron（定时任务）

进入 **Cron**：

![](redacted-screenshots/cron.jpg)

用途：
- 查看有哪些健康检查/更新/备份任务
- 手动运行
- 观察启用/禁用状态

---

## 10) 常见故障排查（快速）

### 10.1 Telegram 群里“一直 typing 但不回”

优先检查：
1) BotFather 的 **Group Privacy 是否 OFF**
2) OpenClaw gateway 是否健康（`openclaw status`）
3) provider 是否限流/超时（Auth 页 + gateway logs）

### 10.2 模型下拉没有你想要的模型

- 现在下拉是 `openclaw models list` 的真实输出。
- 先确保你在 OpenClaw 里已经注册/可见该模型。

---

## 11) 推荐的“最佳实践”

- 每个 Agent 都用独立 workspace（隔离文件/记忆）
- 每个 Sub-Agent 都用独立 Telegram 群（隔离上下文）
- 群里不要加第三方（成本 + 安全）
- 任何“改配置的大动作”尽量先备份（OCM/脚本/手工都行）

---

## 附：截图说明

本文截图来自 `docs/redacted-screenshots/`，已做脱敏（路径用户名、Telegram 绑定 ID 等均已模糊处理）。
