# OpenClaw Manager — 开发日志

> 最后更新：2026-02-27
> 当前版本：v0.7.1

---

## v0.7.1 更新日志（2026-02-27）

### New Features

**Dashboard Guidance Block (Telegram-first usage + safety)**
- Added a concise guidance card under Dashboard explaining OCM's intended Telegram workflow
- Clarifies prerequisites: users should already have basic OpenClaw CLI experience
- Clarifies purpose: OCM mainly helps visualize and update `openclaw.json` for easier main-agent/sub-agent management and multi-tree structures
- Added explicit Telegram security checklist:
  - BotFather `Allow Groups = ON`
  - BotFather `Group Privacy = OFF`
  - Keep each group private (only you + agent/sub-agents), do not invite others

### Improvements

**Model Dropdown Source — only `openclaw models list`**
- Model dropdown options are now sourced from real CLI output (`openclaw models list`) instead of built-in/static lists or config-only additions
- Applies to all relevant selectors: agent/sub-agent creation forms, agent inline model switcher, primary model selector, and fallback picker
- Added warning message when model list loading/parsing fails

### Technical Notes

- Added model ID parser for CLI output and short-term cache for model list fetches
- `GET /api/models` now returns:
  - `knownModels` from CLI
  - `modelListError` for UI warning display
- Startup script banners updated to `v0.7.1` (`start.sh` / `start.bat`)

---

## v0.7.0 更新日志（2026-02-27）

### New Features

**Dashboard Redesign — Circular Gauge System Health**
- CPU%, RAM%, DISK% displayed as SVG circular gauges with colour-coded arcs (green < 70%, amber < 90%, red ≥ 90%)
- System info card: hostname, OS, Node.js, CPU model, cores, uptime, load average (1/5/15 min)
- Agent overview: separate main agent count and sub-agent count (plus total)
- Auto-refresh toggle: when enabled, dashboard polls `/api/dashboard` every 10 seconds
- Backend now measures CPU usage via `os.cpus()` delta sampling (200ms interval) and returns `loadAvg` from `os.loadavg()`

**Sub-Agent Creation Flow — Step-by-Step Guide Rewrite**
- Expanded from 3 steps to 5 detailed steps covering the full BotFather → Telegram Group → OCM workflow
- Step 1: Create new Bot via `/newbot` in BotFather
- Step 2: Disable Group Privacy via `/mybots` → Bot Settings → Group Privacy → Turn off
- Step 3: Create Telegram group, add Bot (with security warning)
- Step 4: Get Group ID from gateway logs
- Step 5: Fill in the form
- New "Your Telegram User ID" input field — auto-writes to `channels.telegram.allowFrom` whitelist on creation
- Security warning banner: "Do NOT add other people to this group" with explanation about API cost risks

**Setup Page — English Localization**
- All Chinese text in the initial directory selection page translated to English
- Includes: title, description, labels, placeholders, error messages, button text

### Bug Fixes

**Agent tree: sub-agents not grouped under main (old config format)**
- **Symptom**: On machines with openclaw.json created before OCM v0.6 multi-bot support, all sub-agents displayed as independent cards instead of nested under main
- **Root cause**: Old-format bindings lack `accountId` field in sub-agent entries. The tree builder relied on `parentAccountId` to match sub-agents to roots, but old bindings only had `channel` + `peer` — no `accountId`. So `parentAccountId` was null and no parent match was found
- **Fix**: Fallback inference — if a sub-agent has a peer binding but no `accountId`, automatically infer `parentAccountId` from main's binding (`accountId`) or fall back to `'default'`

### Technical Notes

- **CPU usage measurement:** Two `os.cpus()` snapshots 200ms apart, calculating idle-to-total ratio across all cores
- **Gauge rendering:** Pure SVG arcs with `stroke-dasharray` animation, no external libraries. 270° arc (gap at bottom), colour transitions via `gaugeColor()` function
- **allowFrom auto-config:** `POST /api/agents` now accepts optional `telegramUserId` field (numeric string), appends to `channels.telegram.allowFrom[]` if not already present
- **Old-config compatibility:** Sub-agent bindings without `accountId` are now auto-assigned to the main agent's bot, maintaining backward compatibility with configs created before multi-bot support

---

## v0.6.6 更新日志（2026-02-27）

### Bug Fixes

**Agent tree: main agent not detected as root**
- **Symptom**: Sub-agents displayed as independent agents instead of under their parent. All agents appeared as orphan roots.
- **Root cause**: `main` agent in OpenClaw is the default catch-all and typically has NO explicit binding in `openclaw.json`. The `hasOwnBot` detection required an explicit binding with `accountId && !peer`, so `main` was classified as a non-root. Without `main` being a root, sub-agents' `parentAccountId` had no matching root to link to.
- **Fix**:
  - `main` is now always treated as a root agent regardless of binding existence
  - `main`'s `accountId` is inferred from `channels.telegram.accounts`: first unclaimed account (not explicitly bound to another agent), or first account as fallback
  - Sub-agents with `parentAccountId` matching `main`'s inferred `accountId` now correctly appear under `main` in the tree

---

## v0.6.5 更新日志（2026-02-26）

### New Features

**Dashboard Tab (🏠 Dashboard)**
- New default landing tab showing system overview at a glance
- **System card**: hostname, OS, Node.js version, CPU model/cores, uptime, memory usage with progress bar
- **Gateway card**: process status indicator (running/stopped/unknown) with coloured dot, port, PID, HTTP ping reachability
- **Agents card**: total agent count, last session activity timestamp (Brisbane time), OCM version, server time
- **Storage card**: OpenClaw dir size, disk usage with progress bar, free space
- New `GET /api/dashboard` endpoint aggregates all info (ps grep + curl ping + fs stat)
- Lazy-loaded on tab switch; auto-loaded on first page load

**Cache-Control + Version-Based Cache Busting**
- All HTTP responses now include `Cache-Control: no-store, no-cache, must-revalidate`
- HTML responses include `ETag: "ocm-<version>"` for version-based cache validation
- All responses include `X-OCM-Version` header
- Browser `api()` function checks `X-OCM-Version` against client version; shows toast notification when server has been updated, prompting user to refresh
- Prevents stale frontend from calling deleted/changed API endpoints after update

### Cleanup

**Old `/api/agents/main` endpoint fully removed** (confirmed via code search — no residual references)

### Technical Notes

- Dashboard gateway detection: `ps aux | grep openclaw.*gateway` for process status, `curl --max-time 2 http://127.0.0.1:<port>` for HTTP ping
- Disk usage: `df -k` for filesystem stats, `du -sk` for OpenClaw dir size
- Agent last activity: scans `~/.openclaw/agents/*/sessions/*.jsonl` mtime
- Version cache busting: `OCM_CLIENT_VERSION` is injected into browser script via template literal `${APP_VERSION}`, compared against `X-OCM-Version` response header on every API call

---

## v0.6.0 更新日志（2026-02-26）

### 重大 Bug 修复

**Add Agent 覆盖已有 Bot Token（数据破坏性 Bug）**
- **症状**：通过 Add Agent 表单添加新 agent 时，直接覆盖 `channels.telegram.botToken`，导致所有已有 agent（包括 sub-agent）全部失效
- **根本原因**：`POST /api/agents/main` 端点无条件覆盖 `channels.telegram.botToken` 字段，没有保护已有配置
- **修复**：
  - 彻底删除 `POST /api/agents/main` 端点
  - 新建 `POST /api/agents/bot` 端点，使用 OpenClaw 的 `channels.telegram.accounts` 多 bot 结构
  - 每个新 agent 获得独立的 `accountId` 和 `botToken`，绝不覆盖已有 token
  - 自动迁移：首次添加新 bot 时，自动将旧格式（顶层 `botToken`）迁移到 `accounts.default`
- **数据恢复**：程序在修改前自动创建 `openclaw.json.create.*` 备份，可通过 `cp` 恢复

**浏览器 Popover API 命名冲突**
- **症状**：点击 "＋ Add Agent" / "＋ Add Sub-Agent" 按钮报错 `NotSupportedError: Failed to execute 'togglePopover' on 'HTMLElement'`
- **根本原因**：自定义函数 `togglePopover()` 与浏览器原生 Popover API 的 `HTMLElement.togglePopover()` 方法冲突
- **修复**：函数重命名为 `showConfigPop()`

### 架构变更

**多 Bot 支持（Multi-Account）**
- 支持 OpenClaw 的 `channels.telegram.accounts` 结构，每个主 agent 可绑定独立的 Telegram bot
- 配置格式：
  ```json
  {
    "channels": { "telegram": { "accounts": {
      "default": { "botToken": "TOKEN_A" },
      "research": { "botToken": "TOKEN_B" }
    }}}
  }
  ```
- `GET /api/agents` 返回 `hasOwnBot` 字段，标识 agent 是否拥有独立 bot
- Sub-Agent 表单新增 "Parent Agent" 下拉，选择共享哪个 bot（不再硬编码 "main"）

**去除 Landing Page，直接进入主程序**
- 移除模式选择首页（Sub-agent / Multi-agent 二选一）
- 启动后直接进入 Agent 管理页面
- 移除 landing page 相关 HTML、CSS、JS、i18n keys

**Agent 页面重设计（popover 配置窗口）**
- 不再使用左右分屏布局
- "＋ Add Agent" / "＋ Add Sub-Agent" 按钮居中显示在 agent 树上方
- 点击按钮弹出浮动配置窗口（popover），包含引导步骤和表单
- Agent 树宽度限制 720px 居中，多个 agent 树纵向排列

### 功能改进

**Stats 重写 — 从 session JSONL 文件解析真实用量**
- 不再从 `gateway.log` 解析（之前一直是 0 数据）
- 改为扫描 `~/.openclaw/agents/*/sessions/*.jsonl`
- 解析 `type: "message"` + `role: "assistant"` 的 `message.usage` 字段
- 新增维度：By Agent（每个 agent 的用量）、Cache Read tokens
- 测试验证：成功解析出 990 条请求、6 个 agent、10 个模型的真实数据

**Model 下拉 — 只显示已注册模型**
- 不再使用硬编码的 KNOWN_MODELS 列表
- 改为从 `openclaw.json` 的 `agents.defaults.models` 读取实际注册的模型

**Agent 树事件委托**
- `renderAgents()` 中的按钮不再使用 `onclick="func('escaped-string')"` 内联写法
- 改用 `data-action` / `data-id` 属性 + 事件委托（`agentTreeAction`），避免 template literal 转义问题

**响应式布局**
- `main` 容器改为 `max-width:100%`，适配不同屏幕宽度
- 新增 `@media (max-width: 600px)` 断点：侧边导航折叠、按钮纵向排列

**备份时间戳改为 Brisbane 时区**
- `brisbaneTimestamp()` 函数，所有备份文件名使用 `Australia/Brisbane` 时区
- 重要：系统所有时间显示统一按 Brisbane 处理

**启动脚本全面重写**
- `start.sh` / `start.bat` 全部英文
- 端口冲突时自动 kill 旧进程，而非报错退出
- 支持 `--host` 参数

**README 重写**
- 移除所有空的 screenshot 占位符（含敏感 ID 的截图已删除）
- 更新功能描述匹配 v0.6
- 精简结构，保留中英文双语

### 新功能 i18n 策略

- v0.6 新增的所有 UI 文案仅提供英文
- 中文翻译推迟到 v1.0 正式版

### 技术备忘

- **Template literal 转义规则**：MAIN_HTML_SCRIPT 是反引号模板字符串
  - `\n` → 真实换行（浏览器 JS 字符串跨行 → SyntaxError），必须写 `\\n`
  - `\'` → `'`（无法用于 onclick 里的引号转义），改用 data 属性 + 事件委托
  - `\`` → `` ` ``（嵌套模板字符串在 evaluated output 中正常工作）
- **`assertBrowserScriptSyntax()`** 在启动时检查 MAIN_HTML_SCRIPT 的 evaluated 值
- **OpenClaw config 多 bot 格式**：`channels.telegram.accounts.<id>.botToken`，binding 用 `accountId` 路由

### 下一步（v0.7+）

- [x] Dashboard 首页 tab（系统信息 + OpenClaw health 状态）— done in v0.6.5
- [x] HTTP 响应加 `Cache-Control: no-store` + version-based cache busting — done in v0.6.5
- [x] 彻底删除旧 `/api/agents/main` 端点残留（确认已清除）— confirmed in v0.6.5
- [x] Agent tree: independent roots per bot + side-by-side layout — done in v0.6.5
- [x] Agent tree: expand/collapse toggle for sub-agents — done in v0.6.5
- [x] Add Agent: creates `agents/<id>/sessions/` runtime dirs + SOUL.md personality — done in v0.6.5
- [x] Agent tree: main agent always root with inferred accountId — done in v0.6.6
- [ ] Dashboard: auto-refresh every 30s when tab is active
- [ ] Dashboard: OpenClaw version display (from `openclaw --version`)
- [ ] Agent page: edit agent name, purpose, personality inline
- [ ] Agent page: restart gateway button with status feedback
- [ ] Settings tab: edit openclaw.json key fields via form (model, workspace defaults)
- [ ] Telegram bot connectivity test button (ping bot API from server)
- [ ] DEVLOG.md 中文 → 逐步迁移为英文

---

## v0.5.2 更新日志（2026-02-25）

### 修复

**远程访问无法连接（ERR_CONNECTION_REFUSED）**
- `server.listen` 原来绑定 `127.0.0.1`（仅本机），远程通过 `http://<IP>:3333` 访问时被直接拒绝
- 改为默认绑定 `0.0.0.0`（所有网卡），远程设备可通过局域网 IP 访问
- 新增 `--host` 命令行参数：需要限制仅本机访问时可用 `--host 127.0.0.1` 覆盖
- 新增 `getLanIP()` 工具函数，自动检测第一个非内部 IPv4 地址

### 改进

**启动日志改为英文**
- 终端启动信息（目录、地址、提示、错误）全部改为英文
- 绑定 `0.0.0.0` 时自动显示局域网地址，方便远程复制：`🌐 LAN: http://192.168.x.x:3333`
- 端口占用、启动失败等错误提示同步改为英文

---

## v0.5.1 更新日志（2026-02-25）

### 修复

**Action 菜单英文模式残留中文**
- 修复 Action 菜单下多处弹窗在 EN 模式仍显示中文的问题（日志、回滚、目录切换、命令输出）
- 统一接入 i18n：标题、按钮、说明文案、加载态、空态、确认框、toast 文案
- 菜单项触发后的交互文案现在与语言切换保持一致

### 工程改进

**1) 嵌入脚本转义/语法防护**
- 新增启动时预检：对前端嵌入脚本执行 `node --check` 语法校验
- 若语法异常（常见为 `MAIN_HTML` 内 `\n` 转义写错），启动阶段直接报错并给出修复提示，避免浏览器白屏后才发现问题

**2) 单文件结构化重构（保持零依赖）**
- 将主页面模板从单一超长 `MAIN_HTML` 拆分为三段常量：
  - `MAIN_HTML_CSS`
  - `MAIN_HTML_BODY`
  - `MAIN_HTML_SCRIPT`
- 最终由 `MAIN_HTML` 组合输出，保持“单文件 + 零依赖”不变，同时降低维护复杂度
- 修复拆分过程中的脚本模板转义问题：`MAIN_HTML_SCRIPT` 使用普通模板字符串（非 `String.raw`），确保前端脚本内的反引号模板语法可被正确还原

### 其他

- 程序头部版本与启动日志版本更新为 `v0.5.1`
- `start.sh` / `start.bat` 启动横幅版本号同步更新为 `v0.5.1`
- `README` 补充 Git 安装/更新流程（`git clone` / `git pull --ff-only`），并精简中英文功能介绍
- `README` 首屏改版：增加「1 分钟上手」命令区（安装/更新/运行同屏），并将开场介绍改为精简版
- `README` 去重：移除中部重复的安装/更新/运行段落，统一引用首屏快速上手
- `README` 截图区改为首屏精简展示（3 张）+ 折叠更多截图（`<details>`）

---

## v0.5 更新日志（2026-02-24）

### 新功能

**认证页简化为引导模式**
- 移除了不稳定的 API Key 提交表单（通过 stdin 管道传 CLI 的方案不可靠）
- 改为引导页：点击 Provider 显示清晰的操作步骤 + 一键复制 CLI 命令
- 已配置的 Provider 在网格中显示 ✅ 标记
- 每个 Provider 指引末尾都提示运行 `openclaw onboard` 注册可用模型
- 删除了 `runWithStdin()` 函数和 `POST /api/auth/run` 端点

**模型页精简**
- 移除「添加模型」和「删除模型」功能（模型应由 `openclaw onboard` 管理）
- 只保留 Primary Model 选择器和 Fallback Chain 编辑
- 删除了 `POST /api/models` 和 `DELETE /api/models/:id` 端点

**API 费用追踪（Token Cost Monitor）— 📊 Stats 标签页**
- 新增 `GET /api/stats` 端点，解析 `logs/gateway.log` 中的 token 用量
- 支持 JSON 日志和文本格式日志（`input_tokens: N, output_tokens: N`）
- 按模型和按天汇总统计，显示 Token 用量和估计成本
- 可视化：四张汇总卡片 + CSS 柱状图（按日） + 模型明细卡片
- 支持自定义模型定价（存 `manager-config.json` 的 `modelPricing` 字段）
- 时间范围过滤：7 / 30 / 90 天
- 点击标签页时懒加载，不影响首屏性能

**Cron 任务管理 — ⏰ Cron 标签页**
- 新增 `GET/POST/PUT/DELETE /api/cron` 四个端点，操作系统 crontab
- 只展示包含 `openclaw` 或 `ocm` 关键词的 cron 条目
- 支持：查看、添加、启用/禁用（注释/取消注释）、手动触发、删除
- 与 NAS 备份的 cron 条目联动（同样显示）
- 添加任务支持自定义 Cron 表达式 + 命令 + 标签

**Workspace 文件浏览器（全文件 + 可编辑）**
- 重写 `GET /api/workspace/:id`：动态扫描 workspace 目录下所有文件（不再硬编码 4 个文件名）
- 每个文件显示大小和最后修改时间
- 默认只读视图（`<pre>` 代码块），点击「编辑」按钮切换为 `<textarea>` 编辑模式
- 编辑后可保存或取消，保存调用已有的 `PUT /api/workspace/:id/:file`
- 大文件（> 512KB）只显示 stat 不加载内容，防止页面卡顿

**CLI Tab 补全**
- 在 CLI 终端输入框按 Tab 键触发前缀匹配自动补全
- 补全源：OpenClaw 子命令词表 + 预设命令列表 + 历史命令
- 单一匹配时直接补全；多个匹配时先补全公共前缀，同时弹出候选列表
- 候选列表最多 12 项，点击即选中；按 Escape 关闭
- 支持多词命令的最后一个词补全

**国际化（i18n）补全**
- 新增 30+ 个 i18n key（zh + en）覆盖 Stats、Cron、Workspace、Auth 引导等所有新功能
- 删除了不再使用的 `models.add`、`models.registered`、`auth.select` 等 key

### 移除

- `POST /api/auth/run` — API Key 提交端点（不可靠）
- `POST /api/models` — 添加模型端点
- `DELETE /api/models/:id` — 删除模型端点
- `runWithStdin()` — stdin 管道传值工具函数
- 前端：API Key 输入表单、添加模型弹窗、注册模型列表、删除模型按钮

### 技术说明

- **Stats 日志解析**：同时支持 JSON 格式（`{"input_tokens":N, "output_tokens":N}`）和文本格式（`input_tokens: N`），按时间戳过滤，按模型名和日期聚合
- **Cron 管理**：通过 `crontab -l` 读取和 `crontab -` 管道写入，不依赖任何外部库。启用/禁用通过添加/移除行首 `#` 注释实现
- **Tab 补全实现**：纯前端 JS，不需要 PTY。维护子命令词表 + 预设列表 + 历史记录三层候选源，使用最长公共前缀算法
- **Workspace 文件扫描**：使用 `fsp.readdir()` + `fsp.stat()` 动态列出，512KB 以上文件只返回 stat 不读内容

---

## v0.4 更新日志（2026-02-21）

### 新功能

**安全状态指示器**
- Header 区域新增健康 badge（🔴/🟡），定期运行 `openclaw doctor` 自动检测问题
- 鼠标悬停展开 tooltip，显示全部 warning/error 详情
- 每 60 秒自动轮询，若后台问题消失，badge 自动隐藏
- 新增服务端 `GET /api/health` 端点，解析 doctor 输出中的 error / warn / missing / fail 关键词

**CLI 终端面板改进**
- **预设下拉菜单移至 header 区域**（Clear 按钮左侧），符合操作习惯，自然向上展开
- **默认命令扩充至 15 条**：新增 `gateway start/stop/logs`、`models auth list`、`agents sync`、`backup create/list`、`config validate`、`update`
- 修正 `openclaw version` → `openclaw --version`

**备份模块完全重设计**
- 旧的 3 步向导替换为**单页表单**：主机/端口、用户名、认证方式、路径、一键操作
- **认证方式**：密码（直接填，不存储）或 SSH Key（可一键生成）可切换
- **老设备兼容复选框**：勾选后自动附加 Legacy CBC 加密参数，解决老款 Synology 等 NAS cipher 协商失败问题（`aes128-cbc`、`diffie-hellman-group14-sha1` 等）
- **备份内容选择**：全量（整个 `.openclaw`，约 55MB）或仅重要数据（配置+API Key+记忆，不含日志/对话历史，约 10MB）
- 备份产物改为 tarball（`openclaw-full-TIMESTAMP.tar.gz`），通过 rsync 传输，比直接 rsync 目录更安全、可校验
- 新增端口字段（默认 22），支持自定义 SSH 端口
- 定时备份支持自定义时间（时间选择器），不再写死 3:00

**国际化（i18n）补全**
- `renderAgents` 全面接入 i18n：主 Agent / subagent 标签、已绑群、保存模型、查看文件、删除，切换语言立即生效
- `renderChannels` 全面接入 i18n：无绑定提示、匹配所有、绑定索引、删除绑定
- `buildModelOpts` 接入 i18n：「使用全局默认」→「Use Global Default」；「自定义」→「custom」

### 修复

- Agents / Channels 页面切英文后按钮仍显示中文（根本原因：`renderAgents` / `renderChannels` 模板字符串内使用硬编码中文）
- 备份旧流程 UX 混乱（步骤2填用户名，步骤1填密码）

### 技术说明

- **老 NAS 密文兼容**：`-o Ciphers=aes128-cbc,aes256-cbc,aes192-cbc,3des-cbc -o KexAlgorithms=diffie-hellman-group14-sha1,diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-rsa,+ssh-dss`
- **重要数据定义**：`openclaw.json` + `.env` + `credentials/` + `agents/*/agent/`（含 API Key，排除 sessions）+ `memory/main.sqlite`
- **全量备份排除**：`logs/`（运行时重建）、`ocm/*.bak.js`（旧版本备份文件）
- 服务端新增 `GET /api/health` 端点，使用 `spawnSync` 同步运行 `openclaw doctor`，3 秒超时，解析 error/warn 行返回结构化 JSON

---

## v0.4.1 热修复（2026-02-21）

### 修复

**SSH Key 生成界面崩溃（MAIN_HTML `\n` 转义错误）**
- **症状**：首页点击无响应，F12 报 `Uncaught SyntaxError: Invalid or unexpected token at line 1785`，随后 `enterApp is not defined`
- **根本原因**：`nasGenKey()` 函数中 `box.textContent = '公钥...：\n' + r.pubKey` 的 `\n` 在 Node.js 评估 MAIN_HTML 模板字符串时被转为真实换行符，浏览器收到的 JS 里字符串字面量跨行 → SyntaxError → 整段脚本解析失败
- **修复**：`'\n'` → `'\\n'`，源码里双反斜杠，Node 模板字符串评估后浏览器收到 `\n` 合法转义
- **规律**：MAIN_HTML 模板字符串内所有 JS 字符串字面量里的 `\n` 都必须写成 `\\n`；每次新加代码后用 `node --check` 验证服务端，再提取 browser script 单独 `node --check` 验证浏览器端

---

## v0.4.2 热修复（2026-02-22）

### 修复

**NAS 备份失败：sshpass 位置错误（直接原因）**
- **症状**：SSH 连接测试通过，但"立即备份"返回 `Permission denied, please try again` + rsync `unexpected end of file`
- **根本原因**：旧代码把 `sshpass -p "pwd"` 塞入 rsync 的 `-e` 参数内，双引号与外层引号互相冲突，导致 sshpass 无法正确读取密码
  ```bash
  # ❌ 旧：引号冲突，password 被 shell 当作单独的 token
  rsync -avz -e "sshpass -p "password" ssh -p 22 ..." ...
  # ✅ 新：sshpass 包裹整个 rsync 命令，-e 里只有干净的 ssh
  sshpass -p 'password' rsync -avz -e "ssh -p 22 ..." ...
  ```
- **修复位置**：`nas-now`、`nas-cron`、`nas-test` 三处均修正
- **附加**：新增 `mkdir -p REMOTE_PATH` 预建远端目录步骤（避免因目录不存在导致 rsync 失败）；密码改用单引号包裹 + `'\\''` 转义

**NAS SSH 兼容模式完全重设计**
- **旧问题**：兼容模式只强制 CBC 加密（`aes128-cbc,3des-cbc` 等），而新款 NAS（Synology DSM 7.x 等）已默认**禁用** CBC，导致勾选后反而无法连接
- **旧问题 2**：`-o HostKeyAlgorithms=+ssh-rsa,+ssh-dss` 在新版 OpenSSH 上语法无效（`+` 前缀不能用于逗号分隔的多值列表），报 `Bad key types`
- **新策略**：兼容模式同时列出**现代算法 + 旧算法**，SSH 自动选双方都支持的最强项：
  - Ciphers：`aes256-gcm, aes128-gcm, chacha20-poly1305, aes256-ctr, aes192-ctr, aes128-ctr`（现代）+ `aes256-cbc, aes192-cbc, aes128-cbc, 3des-cbc`（旧款）
  - KexAlgorithms：`curve25519-sha256, ecdh-sha2-nistp256, dh-group14-sha256`（现代）+ `dh-group14-sha1, dh-group1-sha1`（旧款）
  - HostKeyAlgorithms：`ssh-ed25519, ecdsa-sha2-nistp256, rsa-sha2-256, rsa-sha2-512, ssh-rsa`（去掉 `+` 前缀）
- **结论**：兼容模式现在对新旧服务器均有效；新服务器默认关闭即可（SSH 自动协商）

**NAS 备份 Modal 全面 i18n**
- 所有标签、按钮、提示文字接入 `t()` + `data-i18n` 属性，切换语言立即生效
- 新增 21 个 i18n key（zh + en）：`nas.title`, `nas.host`, `nas.user`, `nas.authLabel`, `nas.pwLabel`, `nas.pwHint`, `nas.keyLabel`, `nas.genKey`, `nas.pubkeyHint`, `nas.remotePath`, `nas.compat`, `nas.content`, `nas.full`, `nas.essential`, `nas.btnTest/Now/Cron/Close`, `nas.cronTime`, `nas.btnSaveCron`, `nas.testing/testOk/testFail`, `nas.backing/backupOk/backupFail`, `nas.keyGenOk/Fail`, `nas.cronOk/Toast`, `nas.backupToast`, `nas.errNoHost`
- `applyLang()` 新增 `data-i18n-placeholder` 属性支持，密码输入框提示也随语言切换
- Checkbox 文字从「老设备兼容模式（Legacy CBC...）」改为「兼容模式（添加旧版 SSH 加密方案，适用于旧款 NAS / 旧服务器）」，更准确描述用途

### 技术说明

- **sshpass 用法规范**：密码认证时，`sshpass -p 'pwd' rsync -e "ssh ..."` 是正确形式；`rsync -e "sshpass ... ssh ..."` 是错误形式（所有三处：test / now / cron 均已修正）
- **密码安全转义**：`password.replace(/'/g, "'\\''")` 处理密码中含单引号的情况
- **PreferredAuthentications=password,PubkeyAuthentication=no**：密码认证时明确禁用公钥，防止 SSH 在无 key 时尝试公钥认证导致不必要的交互提示

---

## v0.5 规划（竞品分析后）

> 调研了 GitHub 上 7 个同类项目后，提炼出最值得借鉴、且与 OCM"零依赖+单文件"哲学兼容的三个方向。

### 优先级 1 — API 费用追踪（Token Cost Monitor）

**来源**：tugcantopaloglu/openclaw-dashboard、mudrii/openclaw-dashboard、adamevers/openclaw-dashboard 均有此功能，说明这是 power user 高频需求。

**实现思路**（零依赖）：
- 解析 `logs/gateway.log`，提取各 session 的 token 用量行（OpenClaw 日志里已有 token 计数）
- 在内存中汇总（按模型、按天）—— 无需 SQLite，用 JS 对象即可
- 新增「Stats」浮层或在 header 右侧加费用小数字，点击展开明细
- 可选：支持自定义各模型单价（存 manager-config.json）

**预计新增代码量**：约 100 行服务端（日志解析）+ 150 行前端（展示）

---

### 优先级 2 — Cron Job 管理页面

**来源**：actionagentai/openclaw-dashboard（12 页布局之一）、tugcantopaloglu/openclaw-dashboard 均有完整 cron 管理。

**实现思路**（零依赖）：
- 在「操作」菜单或独立标签页列出系统 crontab（`crontab -l`）里所有 `openclaw` 相关的条目
- 支持：查看 / 启用 / 禁用 / 手动触发（直接 spawn 命令）/ 修改时间
- 读写通过 `crontab -l` + `crontab -` 管道实现，不依赖任何库
- 也可显示 OCM 自己设置的备份 cron，与 NAS 备份模块联动

**预计新增代码量**：约 80 行服务端（crontab CRUD）+ 120 行前端

---

### 优先级 3 — Memory 文件浏览器

**来源**：tugcantopaloglu/openclaw-dashboard 支持浏览和编辑 MEMORY.md / HEARTBEAT.md 等 Agent 记忆文件。

**实现思路**（零依赖）：
- 在 Agents 卡片的「查看文件」按钮旁，或在文件浏览 modal 里增加编辑模式（`<textarea>`）
- 保存时直接写回文件（已有 `writeFile` 工具函数）
- 可选：显示文件大小和最后修改时间

**预计新增代码量**：约 20 行服务端（`PUT /api/agent/:id/file`）+ 60 行前端

---

### 竞品没有的 OCM 独特优势（保持并强化）

| OCM 特性 | 状态 |
|---------|------|
| 真单文件 / 零 npm 依赖 | ✅ 保持 |
| 内置 CLI 终端（实时流、预设、收藏） | ✅ 独有 |
| NAS SFTP 备份（含老设备密文兼容） | ✅ 独有 |
| 中英文 i18n | ✅ 独有 |
| Windows + macOS 双平台一键启动 | ✅ 独有 |
| Health Badge（openclaw doctor 可视化） | ✅ 独有 |

---

## 一、项目概述

**OpenClaw Manager** 是一个零依赖本地 Web 管理界面，用于可视化管理 OpenClaw AI 助理的 Agent、模型、认证配置等，免去手动编辑 JSON 文件。

- 运行方式：`node openclaw-manager.js`，浏览器访问 `http://localhost:3333`
- 依赖：仅 Node.js >= 18 内置模块（`http`、`fs`、`path`、`os`、`child_process`），零 npm 依赖
- 平台：macOS / Linux / Windows

---

## 零、v0.3 更新日志（2026-02-21）

### 新功能

**Landing 页面 + 语言切换**
- 首次进入显示模式选择页，两个入口：Sub-agent 模式（可用）和 Multi-agent 模式（占位，敬请期待）
- 语言切换（中文/English），存储在 localStorage，刷新记忆
- 每个模式卡片显示简介和所需条件
- 点击 Logo 可随时返回选择页

**Channels 管理页面**
- 新增「Channels」标签页，显示 openclaw.json 里所有 bindings
- 支持添加绑定（选 Agent、频道类型、Peer 类型、Peer ID）
- 支持删除绑定
- 创建/删除 Agent 后自动刷新 Channel 列表

**主 Agent 模型选择**
- main agent 卡片现在也显示模型选择器和「保存模型」按钮
- 可以为 main agent 独立设置模型，不再只能跟随全局默认

**认证页面重做**
- 修正了所有 Provider 的 CLI 命令（原命令 `openclaw auth add` 是错误的）
- 正确命令：`openclaw models auth paste-token --provider <provider>`
- 新增 Provider 选择网格，点击选中后显示操作区
- Token 类 Provider：可在界面直接输入 API Key，由后台通过 stdin 管道传给 CLI 执行（Key 不存储到配置文件）
- OAuth 类（Google）：显示正确命令和复制按钮
- Device Flow 类（GitHub Copilot）：显示分步操作指引
- 底部仍显示已配置认证列表

**重启 GW 交互优化**
- 横幅新增「稍后」按钮：点击后横幅消失，页面左下角出现常驻橙色「重启 Gateway」浮动按钮
- 执行重启后浮动按钮消失
- 「忽略」按钮：直接关闭横幅，不显示浮动按钮

**NAS 备份设置**
- 「操作」菜单新增「NAS 备份设置」入口
- 三步引导界面：SSH Key 生成 → NAS 连接配置 → 备份操作
- SSH Key：一键生成专用 Key，公钥可复制，支持一次性密码部署（密码不存储）
- 配置：NAS 主机 IP、用户名、SSH Key 路径、远端备份目录，保存到 manager-config.json
- 操作：测试连接、立即备份（rsync）、配置每日 3:00 Cron 任务

**默认 SOUL.md 更新**
- 新建 Subagent 时，留空性格关键词则使用新的默认成长型提示词，体现"你是我生活中的客人"理念
- 性格关键词有值时，仍使用关键词列表模式

### 修复

- AUTH_PROVIDERS 的所有 `docCmd` 字段已修正为正确的 `openclaw models auth paste-token --provider X` 格式
- 新增 `spawn` 到 require（用于 stdin 管道传入 API Key）

---

## 二、文件结构

```
~/ocm/                             ← 项目目录（用户自选位置）
├── openclaw-manager.js            ← 主程序（服务端 + 前端 HTML 全合一，~2360行）
├── start.sh                       ← macOS/Linux 启动脚本
├── start.bat                      ← Windows 启动脚本
├── openclaw-manager.command       ← macOS Finder 双击启动
├── manager-config.json            ← 本地路径配置（已 .gitignore，不上传）
├── package.json                   ← GitHub 项目元数据
├── .gitignore                     ← 排除 manager-config.json、*.bak* 等
├── README.md                      ← 中英双语说明文档
└── DEVLOG.md                      ← 本文件
```

**OpenClaw 配置目录**（独立，不在项目里）：

```
~/.openclaw/
├── openclaw.json                  ← OpenClaw 主配置（程序读写的核心文件）
├── agents/                        ← 各 Agent 的 config.json
├── workspaces/                    ← Agent 工作区（SOUL.md、MEMORY.md 等）
├── logs/gateway.log               ← 网关日志
└── openclaw.json.bak.*            ← 自动备份文件
```

---

## 三、目录解析优先级

程序启动时按以下顺序确定 OpenClaw 配置目录：

1. `--dir` 命令行参数
2. `OPENCLAW_DIR` 环境变量
3. 同目录下的 `manager-config.json`（`{ "dir": "~/.openclaw" }`）
4. 默认值 `~/.openclaw`

`~` 在所有平台会自动展开（`os.homedir()`），Windows 用户填 `~/.openclaw` 即可。

---

## 四、已实现功能

### 🤖 Agents 标签页
- 列出所有 Agent（含 main）
- 每个 Agent 卡片显示：模型、群组绑定状态、Workspace 路径
- **内联模型切换**：每个 Agent 有独立下拉菜单，直接保存不需要重建
- 4 步向导新建 Subagent：群组ID → 名称/描述 → 选模型 → 确认创建
  - 自动创建 workspace 目录、SOUL.md、MEMORY.md
  - 自动在 openclaw.json 添加 agent + binding（插入在 main 之前）
  - 创建前自动备份 openclaw.json
- 删除 Agent（自动备份，可回滚）
- 查看 Workspace 文件（SOUL.md / MEMORY.md）

### 🧠 模型标签页
- 显示当前全局主模型，可下拉修改
- Fallback 链可视化编辑（增删 tag）
- 列出所有已配置模型，可添加自定义模型 ID
- 移除模型

### 🔑 认证标签页
支持的认证方式：
| Provider | 模式 |
|---|---|
| Anthropic | API Token |
| OpenAI | API Token |
| DeepSeek | API Token |
| Kimi (Moonshot) | API Token |
| Groq | API Token |
| Mistral | API Token |
| Together AI | API Token |
| Perplexity | API Token |
| Google | OAuth |
| GitHub Copilot | Device Flow |
| 自定义 | API Token |

### ⚡ 顶部工具栏（下拉菜单）
- 重启 Gateway（调用 `openclaw gateway restart`）
- 实时日志（每 2 秒刷新，查看 `logs/gateway.log`）
- 手动备份
- 备份回滚（列出最近 20 个备份，一键恢复，恢复前自动保存当前状态）
- 健康检查（`openclaw doctor`）
- 打开配置目录（调用系统文件管理器）
- 切换 OpenClaw 目录（运行时切换，写入 manager-config.json）

### 其他
- 配置修改后顶部显示橙色"建议重启 Gateway"横幅
- Toast 通知（成功/失败提示）
- 深色主题 UI（`#0f1117` 背景，`#6c63ff` 强调色）

---

## 五、已修复的 Bug

### Bug 1：浏览器 SyntaxError（启动即崩溃）
- **症状**：页面打开后"加载中..."一直卡着，F12 控制台显示 `Uncaught SyntaxError: Invalid or unexpected token`
- **根本原因**：`MAIN_HTML` 是服务端的模板字符串（反引号），里面有一行：
  ```javascript
  document.getElementById('cmdOutput').textContent='❌ '+e.message+'\n\n请在终端手动运行:\nopenclaw gateway restart';
  ```
  Node.js 在评估模板字符串时把 `\n` 变成了真实换行符，浏览器收到的 JS 里单引号字符串跨行，导致解析失败。
- **修复**：将 `'\n\n...\n...'` 改为 `'\\n\\n...\\n...'`，让浏览器收到正确的 `\n` 转义序列。
- **位置**：`openclaw-manager.js` 约第 1473 行。

### Bug 3：MAIN_HTML 模板字符串 `\n` 转义（反复出现）

- **症状**：首页点击无响应，`Uncaught SyntaxError: Invalid or unexpected token` + `enterApp is not defined`
- **根本原因**：在 `const MAIN_HTML = \`...\`` 模板字符串内，JS 字符串字面量里的 `\n`（如 `'msg\n'`）会被 Node.js 在求值模板字符串时转成真实换行符，导致浏览器 JS 解析失败
- **修复模式**：MAIN_HTML 里所有字符串字面量中的 `\n` 必须写成 `\\n`
- **已出现次数**：v0.3（`cmdOutput` 错误文本）、v0.4 末尾（`cliAppend` 命令行前后缀）、v0.4.1（`nasGenKey` 公钥显示）
- **预防**：每次修改后运行 `node --check` + 提取 browser script 再 `node --check`；用扫描脚本检测 MAIN_HTML 内所有单反斜杠 `\n`

### Bug 2：Agent 模型下拉菜单只有"使用全局默认"
- **症状**：Agents 页面每个 Agent 的模型选择器里只有一个选项
- **根本原因**：`loadAgents()` 和 `loadModels()` 并行执行（`Promise.all`），`renderAgents()` 先跑完时 `S.knownModels` 还是空数组，`buildModelOpts()` 只能生成默认选项。`buildModelDropdowns()` 函数本来用于在模型加载完后重填下拉菜单，但实现为空函数 `{}`。
- **修复**：补全 `buildModelDropdowns()` 实现，遍历所有 Agent，用当时已填充的 `S.knownModels` 重建每个 `msel-{id}` select 元素的选项。
- **位置**：`openclaw-manager.js` 约第 1458 行。

---

## 六、重要技术细节

### openclaw.json 结构要点
- `peer.id` 在 bindings 里必须是**字符串**（`"-1003893176648"`），不是整数
- `"main"` 是保留 agent ID，不能用作自定义 agent
- 文件修改后 300ms 内自动热重载，大多数情况不需要重启 gateway
- 新 agent 的 binding 要插入在 `main` 的 catch-all binding **之前**

### 备份命名规则
```
openclaw.json.bak.{label}.{timestamp}
```
label 可以是：`create` / `edit` / `delete` / `models` / `auth` / `manual` / `before-restore`

### 跨平台注意
- 启动浏览器：`open`（macOS）、`start ""`（Windows）、`xdg-open`（Linux）
- 运行 openclaw 命令：Windows 用 `openclaw.cmd`，其他用 `openclaw`
- `manager-config.json` 路径支持 `~` 前缀，所有平台通用

### KNOWN_MODELS 列表（代码内置）
GitHub Copilot、Anthropic、OpenAI、Google、DeepSeek、Kimi、Groq、Mistral、Together AI 共约 20 个模型。

---

## 七、待改进 / 已知问题

### 功能增强（用户提出过，暂未做）
- [ ] SOUL.md 可视化编辑器（当前只能查看，不能在界面里修改内容）
- [ ] 工作区文件内容在浏览器里直接编辑保存
- [ ] Agent 热切换模型（不重建，只改配置）
- [ ] 多 Bot 账号支持
- [ ] SSH 远程服务器管理
- [ ] 从零引导安装 OpenClaw 的向导

### 代码质量
- [ ] 前端代码目前全部内嵌在 `MAIN_HTML` 模板字符串里，文件较长（~1650行），后续可考虑拆分或构建步骤
- [ ] 模型下拉菜单在 `renderAgents` 之后才由 `buildModelDropdowns` 修复，可以改成串行加载（先 `loadModels` 再 `loadAgents`）以更优雅地解决时序问题

### 部署体验
- [ ] `manager-config.json` 目前需要用户手动创建，可以考虑首次启动时通过 UI 向导引导创建（setup wizard 已有框架）
- [ ] README 中加入截图

---

## 八、GitHub 上传准备清单

- [x] `.gitignore` 已排除 `manager-config.json`、`*.bak*`、`.DS_Store` 等
- [x] `package.json` 的 `author` 字段为空（不含个人信息）
- [x] `README.md` 中英双语
- [x] 主程序无硬编码个人信息（API Key、路径、Token 等均运行时读取）
- [ ] 在 `package.json` 的 `author` 填上你的名字/GitHub 用户名（可选）
- [ ] GitHub 新建仓库，`git init → git add . → git commit → git push`

---

## 九、启动方式快速参考

```bash
# 直接启动（自动读取 manager-config.json 或 ~/.openclaw）
bash ~/ocm/start.sh

# 指定目录
bash ~/ocm/start.sh --dir /path/to/.openclaw

# 指定端口（默认 3333）
bash ~/ocm/start.sh --port 8080

# macOS Finder 双击
openclaw-manager.command

# Windows
start.bat
```

访问 `http://localhost:3333`
