#!/usr/bin/env bash
# ================================================================
# OpenClaw Manager v0.5 — 跨平台启动脚本 (macOS / Linux)
#
# 特性：
#   • 自动检测 Node.js，未安装时给出安装指引
#   • 自动检测 ~/.openclaw 目录，不存在时提示
#   • 首次运行自动创建 manager-config.json
#   • 自动检测端口占用并建议替代端口
#   • 支持 --dir / --port / --help 参数
# ================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANAGER_JS="$SCRIPT_DIR/openclaw-manager.js"
CONFIG_JSON="$SCRIPT_DIR/manager-config.json"
MIN_NODE_MAJOR=18

# ── 颜色 ─────────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'

banner() {
  echo ""
  echo -e "${CYAN}${BOLD}  🦀 OpenClaw Manager v0.5${RESET}"
  echo -e "${DIM}  ─────────────────────────────${RESET}"
  echo ""
}

banner

# ── 检查主文件 ────────────────────────────────────────────────
if [ ! -f "$MANAGER_JS" ]; then
  echo -e "${RED}✗ 找不到 openclaw-manager.js${RESET}"
  echo -e "  期望路径: ${DIM}$MANAGER_JS${RESET}"
  exit 1
fi

# ── 检查 Node.js ─────────────────────────────────────────────
install_node_hint() {
  echo ""
  echo -e "  ${BOLD}安装方式（选一种即可）：${RESET}"
  echo ""
  if [[ "$(uname)" == "Darwin" ]]; then
    echo -e "  ${GREEN}1)${RESET} Homebrew:  ${CYAN}brew install node${RESET}"
    echo -e "  ${GREEN}2)${RESET} 官网下载:  ${CYAN}https://nodejs.org/${RESET}"
    echo -e "  ${GREEN}3)${RESET} nvm:       ${CYAN}curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash${RESET}"
    echo -e "                  ${DIM}然后 nvm install --lts${RESET}"
  else
    echo -e "  ${GREEN}1)${RESET} apt:       ${CYAN}sudo apt install -y nodejs npm${RESET}"
    echo -e "  ${GREEN}2)${RESET} 官网下载:  ${CYAN}https://nodejs.org/${RESET}"
    echo -e "  ${GREEN}3)${RESET} nvm:       ${CYAN}curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash${RESET}"
    echo -e "                  ${DIM}然后 nvm install --lts${RESET}"
  fi
  echo ""
}

if ! command -v node &>/dev/null; then
  echo -e "${RED}✗ 未找到 Node.js${RESET}"
  install_node_hint
  exit 1
fi

NODE_VER=$(node -e "process.stdout.write(String(process.versions.node.split('.')[0]))")
if [ "$NODE_VER" -lt "$MIN_NODE_MAJOR" ]; then
  echo -e "${YELLOW}⚠ Node.js 版本过低（当前 v$(node -v)，需要 >= v${MIN_NODE_MAJOR}）${RESET}"
  install_node_hint
  exit 1
fi
echo -e "  ${GREEN}✓${RESET} Node.js $(node -v)"

# ── 解析参数 ─────────────────────────────────────────────────
DIR_ARG=""
PORT_ARG=""
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)   DIR_ARG="$2"; shift 2;;
    --dir=*) DIR_ARG="${1#*=}"; shift;;
    --port)  PORT_ARG="$2"; shift 2;;
    --port=*) PORT_ARG="${1#*=}"; shift;;
    --help|-h)
      echo "用法: $0 [选项]"
      echo ""
      echo "选项:"
      echo "  --dir  <路径>   OpenClaw 配置目录（默认 ~/.openclaw）"
      echo "  --port <端口>   监听端口（默认 3333）"
      echo "  --help          显示帮助"
      exit 0;;
    *) EXTRA_ARGS+=("$1"); shift;;
  esac
done

# ── 检测 OpenClaw 配置目录 ───────────────────────────────────
# 优先级: --dir 参数 > manager-config.json > 环境变量 > 默认
OPENCLAW_DIR=""
if [ -n "$DIR_ARG" ]; then
  OPENCLAW_DIR="${DIR_ARG/#\~/$HOME}"
elif [ -f "$CONFIG_JSON" ]; then
  OPENCLAW_DIR=$(node -e "try{const c=JSON.parse(require('fs').readFileSync('$CONFIG_JSON','utf8'));const d=c.openclawDir||c.dir||'';process.stdout.write(d.replace(/^~/,require('os').homedir()))}catch{}" 2>/dev/null)
fi
if [ -z "$OPENCLAW_DIR" ] && [ -n "$OPENCLAW_DIR_ENV" ]; then
  OPENCLAW_DIR="$OPENCLAW_DIR_ENV"
fi
[ -z "$OPENCLAW_DIR" ] && OPENCLAW_DIR="$HOME/.openclaw"

if [ -d "$OPENCLAW_DIR" ]; then
  echo -e "  ${GREEN}✓${RESET} 配置目录: ${DIM}$OPENCLAW_DIR${RESET}"
else
  echo -e "  ${YELLOW}⚠${RESET} 配置目录不存在: ${DIM}$OPENCLAW_DIR${RESET}"
  echo -e "    ${DIM}首次使用？请先运行 openclaw onboard 初始化。${RESET}"
fi

# ── 首次运行：自动创建 manager-config.json ────────────────────
if [ ! -f "$CONFIG_JSON" ]; then
  echo -e "  ${CYAN}→${RESET} 首次运行，创建 ${DIM}manager-config.json${RESET}"
  node -e "require('fs').writeFileSync('$CONFIG_JSON',JSON.stringify({dir:'~/.openclaw'},null,2))"
fi

# ── 检查端口可用性 ───────────────────────────────────────────
PORT="${PORT_ARG:-3333}"

check_port() {
  if command -v lsof &>/dev/null; then
    lsof -i :"$1" -sTCP:LISTEN >/dev/null 2>&1 && return 1
  elif command -v ss &>/dev/null; then
    ss -tlnp 2>/dev/null | grep -q ":$1 " && return 1
  elif command -v netstat &>/dev/null; then
    netstat -tlnp 2>/dev/null | grep -q ":$1 " && return 1
  fi
  return 0
}

if ! check_port "$PORT"; then
  echo -e "  ${YELLOW}⚠${RESET} 端口 ${PORT} 已被占用"
  # 尝试找一个可用端口
  for ALT in 3334 3335 3336 8080 8888; do
    if check_port "$ALT"; then
      echo -e "    ${DIM}尝试备用端口 ${ALT}...${RESET}"
      PORT="$ALT"
      PORT_ARG="$ALT"
      break
    fi
  done
fi

# ── 构建启动命令 ─────────────────────────────────────────────
CMD_ARGS=()
[ -n "$DIR_ARG" ]  && CMD_ARGS+=(--dir "$DIR_ARG")
[ -n "$PORT_ARG" ] && CMD_ARGS+=(--port "$PORT_ARG")
CMD_ARGS+=("${EXTRA_ARGS[@]}")

echo ""
echo -e "  ${CYAN}▶${RESET} 启动中 → ${BOLD}http://localhost:${PORT}${RESET}"
echo -e "  ${DIM}Ctrl+C 停止${RESET}"
echo ""

# ── 启动 ─────────────────────────────────────────────────────
exec node "$MANAGER_JS" "${CMD_ARGS[@]}"
