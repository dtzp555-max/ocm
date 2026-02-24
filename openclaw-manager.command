#!/bin/bash
# ================================================================
# OpenClaw Manager — macOS 双击启动
#
# 在 Finder 中双击此文件即可在 Terminal 里运行 start.sh
# 特性：
#   • 自动 cd 到脚本所在目录（无论从哪里双击）
#   • 如果 start.sh 不存在，给出友好提示
#   • 窗口标题显示 OpenClaw Manager
#   • 运行结束后窗口不会立即关闭
# ================================================================

# 设置窗口标题
printf '\033]0;OpenClaw Manager\007'

# 切换到脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || {
  echo "❌ 无法进入目录: $SCRIPT_DIR"
  echo "按 Enter 关闭..."
  read -r
  exit 1
}

# 检查 start.sh 是否存在
if [ ! -f "./start.sh" ]; then
  echo ""
  echo "  ❌ 找不到 start.sh"
  echo "  当前目录: $SCRIPT_DIR"
  echo ""
  echo "  请确认以下文件在同一目录下："
  echo "    • openclaw-manager.command (本文件)"
  echo "    • start.sh"
  echo "    • openclaw-manager.js"
  echo ""
  echo "按 Enter 关闭..."
  read -r
  exit 1
fi

# 确保 start.sh 有执行权限
chmod +x ./start.sh 2>/dev/null

# 运行
bash ./start.sh "$@"
EXIT_CODE=$?

# 如果异常退出，保持窗口打开
if [ $EXIT_CODE -ne 0 ]; then
  echo ""
  echo "  退出码: $EXIT_CODE"
  echo "  按 Enter 关闭..."
  read -r
fi
