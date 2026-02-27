#!/usr/bin/env bash
# ================================================================
# OpenClaw Manager v0.7.1 — Start Script (macOS / Linux)
#
# Features:
#   - Auto-detect Node.js, show install instructions if missing
#   - Auto-detect ~/.openclaw directory
#   - Auto-create manager-config.json on first run
#   - Auto-kill previous OCM process if port is in use
#   - Supports --dir / --port / --host / --help
# ================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANAGER_JS="$SCRIPT_DIR/openclaw-manager.js"
CONFIG_JSON="$SCRIPT_DIR/manager-config.json"
MIN_NODE_MAJOR=18

# ── Colors ────────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'

banner() {
  echo ""
  echo -e "${CYAN}${BOLD}  🦀 OpenClaw Manager v0.7.1${RESET}"
  echo -e "${DIM}  ─────────────────────────────${RESET}"
  echo ""
}

banner

# ── Check main file ──────────────────────────────────────────
if [ ! -f "$MANAGER_JS" ]; then
  echo -e "${RED}✗ Cannot find openclaw-manager.js${RESET}"
  echo -e "  Expected: ${DIM}$MANAGER_JS${RESET}"
  exit 1
fi

# ── Check Node.js ────────────────────────────────────────────
install_node_hint() {
  echo ""
  echo -e "  ${BOLD}Install Node.js (pick one):${RESET}"
  echo ""
  if [[ "$(uname)" == "Darwin" ]]; then
    echo -e "  ${GREEN}1)${RESET} Homebrew:  ${CYAN}brew install node${RESET}"
    echo -e "  ${GREEN}2)${RESET} Official:  ${CYAN}https://nodejs.org/${RESET}"
    echo -e "  ${GREEN}3)${RESET} nvm:       ${CYAN}curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash${RESET}"
    echo -e "                  ${DIM}then: nvm install --lts${RESET}"
  else
    echo -e "  ${GREEN}1)${RESET} apt:       ${CYAN}sudo apt install -y nodejs npm${RESET}"
    echo -e "  ${GREEN}2)${RESET} Official:  ${CYAN}https://nodejs.org/${RESET}"
    echo -e "  ${GREEN}3)${RESET} nvm:       ${CYAN}curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash${RESET}"
    echo -e "                  ${DIM}then: nvm install --lts${RESET}"
  fi
  echo ""
}

if ! command -v node &>/dev/null; then
  echo -e "${RED}✗ Node.js not found${RESET}"
  install_node_hint
  exit 1
fi

NODE_VER=$(node -e "process.stdout.write(String(process.versions.node.split('.')[0]))")
if [ "$NODE_VER" -lt "$MIN_NODE_MAJOR" ]; then
  echo -e "${YELLOW}⚠ Node.js too old (current $(node -v), need >= v${MIN_NODE_MAJOR})${RESET}"
  install_node_hint
  exit 1
fi
echo -e "  ${GREEN}✓${RESET} Node.js $(node -v)"

# ── Parse arguments ──────────────────────────────────────────
DIR_ARG=""
PORT_ARG=""
HOST_ARG=""
EXTRA_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)   DIR_ARG="$2"; shift 2;;
    --dir=*) DIR_ARG="${1#*=}"; shift;;
    --port)  PORT_ARG="$2"; shift 2;;
    --port=*) PORT_ARG="${1#*=}"; shift;;
    --host)  HOST_ARG="$2"; shift 2;;
    --host=*) HOST_ARG="${1#*=}"; shift;;
    --help|-h)
      echo "Usage: $0 [options]"
      echo ""
      echo "Options:"
      echo "  --dir  <path>   OpenClaw config directory (default: ~/.openclaw)"
      echo "  --port <port>   Listen port (default: 3333)"
      echo "  --host <addr>   Bind address (default: 0.0.0.0)"
      echo "  --help          Show this help"
      exit 0;;
    *) EXTRA_ARGS+=("$1"); shift;;
  esac
done

# ── Detect OpenClaw config directory ─────────────────────────
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
  echo -e "  ${GREEN}✓${RESET} Config dir: ${DIM}$OPENCLAW_DIR${RESET}"
else
  echo -e "  ${YELLOW}⚠${RESET} Config dir not found: ${DIM}$OPENCLAW_DIR${RESET}"
  echo -e "    ${DIM}First time? Run: openclaw onboard${RESET}"
fi

# ── First run: auto-create manager-config.json ───────────────
if [ ! -f "$CONFIG_JSON" ]; then
  echo -e "  ${CYAN}→${RESET} First run, creating ${DIM}manager-config.json${RESET}"
  node -e "require('fs').writeFileSync('$CONFIG_JSON',JSON.stringify({dir:'~/.openclaw'},null,2))"
fi

# ── Port handling: kill old process if occupied ──────────────
PORT="${PORT_ARG:-3333}"

get_port_pid() {
  if command -v lsof &>/dev/null; then
    lsof -ti :"$1" -sTCP:LISTEN 2>/dev/null || true
  elif command -v ss &>/dev/null; then
    ss -tlnp 2>/dev/null | grep ":$1 " | grep -oP 'pid=\K[0-9]+' || true
  fi
}

PORT_PID=$(get_port_pid "$PORT")
if [ -n "$PORT_PID" ]; then
  echo -e "  ${YELLOW}⚠${RESET} Port ${PORT} in use (PID ${PORT_PID}), stopping old process..."
  kill "$PORT_PID" 2>/dev/null || true
  sleep 1
  # Force kill if still alive
  if kill -0 "$PORT_PID" 2>/dev/null; then
    kill -9 "$PORT_PID" 2>/dev/null || true
    sleep 0.5
  fi
  echo -e "  ${GREEN}✓${RESET} Old process stopped"
fi

# ── Build launch command ─────────────────────────────────────
CMD_ARGS=()
[ -n "$DIR_ARG" ]  && CMD_ARGS+=(--dir "$DIR_ARG")
[ -n "$PORT_ARG" ] && CMD_ARGS+=(--port "$PORT_ARG")
[ -n "$HOST_ARG" ] && CMD_ARGS+=(--host "$HOST_ARG")
CMD_ARGS+=("${EXTRA_ARGS[@]}")

echo ""
echo -e "  ${CYAN}▶${RESET} Starting → ${BOLD}http://localhost:${PORT}${RESET}"
echo -e "  ${DIM}Ctrl+C to stop${RESET}"
echo ""

# ── Launch ───────────────────────────────────────────────────
exec node "$MANAGER_JS" "${CMD_ARGS[@]}"
